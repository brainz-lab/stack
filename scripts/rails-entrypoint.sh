#!/bin/bash
set -e

# Brainz Lab - Rails Service Entrypoint
# Ensures database schemas are properly set up before starting the server.
#
# Strategy:
#   Primary DB: Load structure.sql via psql + populate schema_migrations
#               to prevent DuplicateTable errors and migration ordering issues.
#   Queue/Cache/Cable DBs: Use migration files (create directories if missing).
#   Schema dump files for secondary DBs are removed to prevent conflicts.

echo "==> Preparing environment..."

# Fix permission issues for brainzlab_ui asset symlinks.
if [ "$(id -u)" = "0" ]; then
  chown -R 1000:1000 app/assets/tailwind 2>/dev/null || true
fi
if [ -f config/initializers/brainzlab_ui_assets.rb ]; then
  GEM_PATH=$(find /usr/local/bundle -path "*/brainzlab-ui-*/app/assets/stylesheets/brainzlab_ui" -type d 2>/dev/null | head -1)
  if [ -n "$GEM_PATH" ] && [ ! -e app/assets/tailwind/brainzlab_ui ]; then
    ln -sf "$GEM_PATH" app/assets/tailwind/brainzlab_ui 2>/dev/null || true
  fi
fi

# If running as root, switch to the rails user for the rest of the script
if [ "$(id -u)" = "0" ]; then
  exec su -m rails -s /bin/bash -c "HOME=/home/rails bash /rails/entrypoint.sh"
fi

echo "==> Preparing database..."

# Remove schema dump files for secondary databases to prevent conflicts
# with our migration files for queue/cache/cable.
rm -f db/queue_schema.rb db/queue_structure.sql
rm -f db/cache_schema.rb db/cache_structure.sql
rm -f db/cable_schema.rb db/cable_structure.sql

# Create queue_migrate directory and migration if missing
if [ ! -d db/queue_migrate ]; then
  echo "    Creating db/queue_migrate/..."
  mkdir -p db/queue_migrate
  cat > db/queue_migrate/20250101000001_create_solid_queue_tables.rb << 'MIGRATION'
class CreateSolidQueueTables < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string :concurrency_key
      t.timestamps
      t.index :active_job_id
      t.index :class_name
      t.index :finished_at
      t.index [:queue_name, :finished_at], name: "index_solid_queue_jobs_for_filtering"
      t.index [:scheduled_at, :finished_at], name: "index_solid_queue_jobs_for_alerting"
    end
    create_table :solid_queue_recurring_tasks do |t|
      t.string :key, null: false
      t.string :schedule, null: false
      t.string :command, limit: 2048
      t.string :class_name
      t.text :arguments
      t.string :queue_name
      t.integer :priority, default: 0
      t.boolean :static, default: true, null: false
      t.text :description
      t.timestamps
      t.index :key, unique: true
      t.index :static
    end
    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.bigint :supervisor_id
      t.integer :pid, null: false
      t.string :hostname
      t.text :metadata
      t.datetime :created_at, null: false
      t.string :name, null: false
      t.index :last_heartbeat_at
      t.index [:name, :supervisor_id], unique: true
      t.index :supervisor_id
    end
    create_table :solid_queue_ready_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :created_at, null: false
      t.index :job_id, unique: true
      t.index [:priority, :job_id], name: "index_solid_queue_poll_all"
      t.index [:queue_name, :priority, :job_id], name: "index_solid_queue_poll_by_queue"
    end
    create_table :solid_queue_scheduled_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :created_at, null: false
      t.index :job_id, unique: true
      t.index [:scheduled_at, :priority, :job_id], name: "index_solid_queue_dispatch_all"
    end
    create_table :solid_queue_claimed_executions do |t|
      t.bigint :job_id, null: false
      t.bigint :process_id
      t.datetime :created_at, null: false
      t.index :job_id, unique: true
      t.index [:process_id, :job_id]
    end
    create_table :solid_queue_blocked_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string :concurrency_key, null: false
      t.datetime :expires_at, null: false
      t.datetime :created_at, null: false
      t.index [:concurrency_key, :priority, :job_id], name: "index_solid_queue_blocked_executions_for_release"
      t.index [:expires_at, :concurrency_key], name: "index_solid_queue_blocked_executions_for_maintenance"
      t.index :job_id, unique: true
    end
    create_table :solid_queue_failed_executions do |t|
      t.bigint :job_id, null: false
      t.text :error
      t.datetime :created_at, null: false
      t.index :job_id, unique: true
    end
    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.datetime :created_at, null: false
      t.index :queue_name, unique: true
    end
    create_table :solid_queue_recurring_executions do |t|
      t.bigint :job_id, null: false
      t.string :task_key, null: false
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false
      t.index :job_id, unique: true
      t.index [:task_key, :run_at], unique: true
    end
    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false
      t.timestamps
      t.index :expires_at
      t.index [:key, :value]
      t.index :key, unique: true
    end
    add_foreign_key :solid_queue_blocked_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_claimed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_failed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_ready_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_recurring_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_scheduled_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
MIGRATION
fi

# Create cache_migrate directory and migration if missing
if [ ! -d db/cache_migrate ]; then
  echo "    Creating db/cache_migrate/..."
  mkdir -p db/cache_migrate
  cat > db/cache_migrate/20250101000001_create_solid_cache_tables.rb << 'MIGRATION'
class CreateSolidCacheTables < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_cache_entries do |t|
      t.binary :key, null: false, limit: 1024
      t.binary :value, null: false, limit: 536870912
      t.datetime :created_at, null: false
      t.integer :key_hash, null: false, limit: 8
      t.integer :byte_size, null: false, limit: 4
      t.index :key_hash, unique: true
      t.index [:key_hash, :byte_size], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    end
  end
end
MIGRATION
fi

# Create cable_migrate directory and migration if missing
if [ ! -d db/cable_migrate ]; then
  echo "    Creating db/cable_migrate/..."
  mkdir -p db/cable_migrate
  cat > db/cable_migrate/20250101000001_create_solid_cable_tables.rb << 'MIGRATION'
class CreateSolidCableTables < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_cable_messages do |t|
      t.text :channel, null: false
      t.text :payload, null: false
      t.datetime :created_at, null: false
      t.integer :channel_hash, null: false, limit: 8
      t.index :channel
      t.index :channel_hash
      t.index :created_at
    end
  end
end
MIGRATION
fi

# Primary database: load schema and mark all migrations as complete.
# This avoids DuplicateTable errors from migration ordering issues in the images.
# Supports both structure.sql (SQL format) and schema.rb (Ruby format).
SCHEMA_FILE=""
if [ -f db/structure.sql ]; then
  SCHEMA_FILE="structure.sql"
elif [ -f db/schema.rb ]; then
  SCHEMA_FILE="schema.rb"
fi

if [ -n "$SCHEMA_FILE" ]; then
  echo "==> Setting up primary database from $SCHEMA_FILE..."
  bin/rails runner "
    needs_setup = begin
      !ActiveRecord::Base.connection.table_exists?(\"schema_migrations\") ||
      ActiveRecord::Base.connection.select_value(\"SELECT COUNT(*) FROM schema_migrations\").to_i == 0
    rescue
      true
    end

    if needs_setup
      schema_file = \"$SCHEMA_FILE\"
      if schema_file == \"structure.sql\"
        puts \"    Loading structure.sql...\"
        config = ActiveRecord::Base.connection_db_config
        ActiveRecord::Tasks::DatabaseTasks.structure_load(config, Rails.root.join(\"db/structure.sql\").to_s)

        puts \"    Populating schema_migrations...\"
        versions = Dir.glob(Rails.root.join(\"db/migrate/*.rb\")).map { |f|
          File.basename(f).split(\"_\", 2).first
        }
        versions.each do |v|
          ActiveRecord::Base.connection.execute(
            \"INSERT INTO schema_migrations (version) VALUES ('#{v}') ON CONFLICT DO NOTHING\"
          )
        end
        puts \"    Marked #{versions.size} migrations as complete.\"
      else
        puts \"    Loading schema.rb...\"
        load Rails.root.join(\"db/schema.rb\")
        puts \"    Schema loaded (includes schema_migrations).\"
      end
    else
      puts \"    Primary database already set up.\"
    end
  " 2>&1 || echo "    Warning: schema loading had issues, falling back to db:prepare..."

  # Remove schema files so db:prepare doesn't try to load them again
  rm -f db/structure.sql db/schema.rb
fi

# Run db:prepare for remaining setup:
# - Any primary DB migrations not covered by schema load
# - Queue/cache/cable database setup via migration files
# - Seeds
echo "==> Running db:prepare..."
bin/rails db:prepare || echo "    Warning: db:prepare had errors (seeds may have failed, continuing...)"

echo "==> Starting server..."
exec ./bin/thrust ./bin/rails server

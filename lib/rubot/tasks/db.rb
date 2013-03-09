# ZOMG
MIGRATION_TEMPLATE = <<MIG
Sequel.migration do
  up do
    # up code
  end

  down do
    # down code
  end
end
MIG

desc "database related stuff"
namespace :db do
  require "fileutils"
  require "sequel"

  Sequel.extension :migration

  # rake argument passing sucks. let's see if we can do something about that
  desc "migrate the database"
  task :migrate, :version do |t, args|
    version = args[:version].to_i if args[:version]
    DB = Sequel.sqlite("db/development.db")
    migrate_dir = File.join "db", "migrations"
    Sequel::Migrator.apply(DB, migrate_dir, version)
  end

  # this will be moved into the framework bin file, probably similar to rails' generators
  #   rubot generate migration <name>
  desc "generate a new migration"
  task :migration, :name do |t, args|
    raise "No name given" unless args[:name]

    dir = File.join("db", "migrations")
    FileUtils.mkdir_p dir

    stamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    filename = File.join(dir, "#{stamp}_#{args[:name]}.rb")

    File.open(filename, "w") do |file|
      file.puts MIGRATION_TEMPLATE
    end
  end
end

db = ActiveRecord::Base.connection

puts '#!/bin/bash'
puts ""
puts "COMMAND='dry-run'"
puts ""
puts ""

# Rails runner task for generating columns conversions

db.tables.each do |table|
  column_conversions = []
  db.columns(table).each do |column|
    case column.sql_type
      when /([a-z])*text/i
        default = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
        null = (column.null) ? '' : 'NOT NULL'
        column_conversions << "MODIFY COLUMN  \\`#{column.name}\\` #{column.sql_type.upcase} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci #{default} #{null}"
      when /varchar\(([0-9]+)\)/i
        sql_type = column.sql_type.upcase
        default = (column.default.blank?) ? '' : "DEFAULT '#{column.default}'"
        null = (column.null) ? '' : 'NOT NULL'
        column_conversions << "MODIFY COLUMN \\`#{column.name}\\`  #{sql_type} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci #{default} #{null}".strip
    end
  end

  puts "# #{table}"
  if column_conversions.empty?
    puts "# NO CONVERSIONS NECESSARY FOR #{table}"
  else
   column_conversions.each do |column_conv|
  	puts "echo \"ALTER TABLE #{table} #{column_conv}\"| mysql --host mariadb -uroot #{db.current_database}".strip
    end
  end
  puts ""
end

puts ""

puts "echo \"Script finished successfully\""

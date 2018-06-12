#!/usr/bin/env ruby
puts "event: #{ARGV[0]}"
puts "context: #{ARGV[1]}"

require'aws-sdk'

rds = Aws::RDS::Client.new(region:'ap-northeast-1')

desc_instance = rds.describe_db_instances().to_h

desc_instance[:db_instances].each do |desc_db|

  desc_snapshot = rds.describe_db_snapshots({
                                                db_instance_identifier: desc_db[:db_instance_identifier],
                                                snapshot_type: "automated"
                                            }).to_h

  #get latest snapshot
  max_snapshot_create_time  = Time.utc(2008, 7, 8, 9, 10)
  db_snapshots_index  = nil

  desc_snapshot[:db_snapshots].each_with_index do |dbSnapshot,index|

    if dbSnapshot[:snapshot_create_time] > max_snapshot_create_time
      max_snapshot_create_time = dbSnapshot[:snapshot_create_time]
      db_snapshots_index = index
    end

  end

  target_name = desc_snapshot[:db_snapshots][db_snapshots_index][:db_snapshot_identifier].gsub(":","-")

  puts target_name

  # copy auto snapshot to manual
  manual_snapshot = rds.copy_db_snapshot({
                                             source_db_snapshot_identifier: desc_snapshot[:db_snapshots][db_snapshots_index][:db_snapshot_identifier],
                                             target_db_snapshot_identifier: target_name,
                                         }).to_h

  end



  
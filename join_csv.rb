require 'csv'

project = ARGV[0]
analyze_dir = "analyze/"
merged_file = analyze_dir + project + "_merged.csv"
analyze_file = analyze_dir + project + ".csv"
output_file = analyze_dir + project + "_full.csv"

merged = CSV.read(merged_file).drop(1)
analyze = CSV.read(analyze_file).drop(1)

pr_table = {}
analyze.each do |row|
  # row[5] is column of lines_modified_open
  # row[9] is column of branch_commits
  next if row[5].to_i <= 0 || row[9].to_i <= 0
  pr_table[row[0]] = row
end

header = <<-HEADER
pull_req_id
github_id
useful
requester
created_at
num_commits_open
lines_modified_open
files_modified_open
commits_on_files_touched
branch_hotness
branch_commits
branch
HEADER

CSV.open(output_file, 'w') do |io|
  io << header.split("\n")
  merged.each do |row|
    next unless pr_table[row[0]]
    row[2] = row[2] == "unknown" || row[2] == "merged_in_comments" ? "useless" : "useful"
    io << row + pr_table[row[0]][3..-1]
  end
end


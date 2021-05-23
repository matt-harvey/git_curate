require "rugged"

repo = Rugged::Repository.new(".")

current_branch_name = repo.head.name.sub(/^refs\/heads\//, '')

repo.branches.each_name(:local) do |branch_name|
  branch_reference = repo.references["refs/heads/#{branch_name}"]
  branch = repo.branches[branch_name]
  is_current = current_branch_name == branch_name
  target_id = branch.target_id
  top_commit = branch_reference.log.first
  commit = repo.lookup(target_id)

  target = branch.resolve.target
  merged = repo.merge_base(repo.head.target, target) == target.oid

  puts "Branch: #{is_current ? '* ' + branch_name : branch_name}"
  puts "date: #{commit.time}"
  puts "hash: #{target_id}"
  puts "author: #{top_commit[:committer][:name]}"
  puts "subject: #{commit.message.split($/, -1)[0]}"
  if branch.upstream
    puts "upstream: #{branch.upstream.name}"
    ahead, behind = repo.ahead_behind(target_id, branch.upstream.target_id)
    puts "ahead: #{ahead}"
    puts "behind: #{behind}"
  end
  puts "merged: #{merged ? 'Merged' : 'Not merged'}"
  puts "*****************"
end

{spawn} = require 'child_process'
path    = require 'path'

runExternal = (cmd, args) ->
  child = spawn(cmd, args, stdio: 'inherit')
  child.on('error', console.error)
  child.on('close', process.exit)

task 'build', 'Build from src/', ->
  runExternal 'coffee', ['-c', '-o', './', 'src/']

task 'watch', 'Watch src/ for changes', ->
  runExternal 'coffee', ['-w', '-c', '-o', './', 'src/']
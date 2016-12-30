
function PluginName()
  return 'TestName'
end

function PluginVersion()
  return '0.1'
end

function PluginAbout()
  return 'This is test plugin. PluginExecute function return nothing, exept execution status 0 or 1'
end

function PluginExecute()
  return 0
end

function PluginAddFunc()
  LOut {}
  LOut.TestPlugFunc = 1 -- 1 if it is necessary to add to the menu system, 0 otherwise
  return 'SomeFunction'
end

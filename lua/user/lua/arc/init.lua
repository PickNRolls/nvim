local arc = {};


-- Define a function that spawns a new process in the background
function background_process(command, ...)
  local stdout = vim.loop.new_pipe(true)
  if (!stdout) then
    return;
  end
  local handle, pid = vim.loop.spawn(command, {
    args = { ... },
    stdio = { nil, stdout }
  }, function(code)
    print(string.format("Process exited with code %d", code))
    stdout:read_stop()
    stdout:close()
  end)
  vim.loop.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      -- Do something with the data here (e.g., save it to a file or display it in Neovim)
      print(data)
    end
  end)
end

arc.status = function()
  background_process('arc status');
end

return arc;

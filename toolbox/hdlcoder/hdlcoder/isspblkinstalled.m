function status=isspblkinstalled






    status=builtin('license','test','Signal_Blocks')&&...
    (~isempty(ver('dsp')));

end

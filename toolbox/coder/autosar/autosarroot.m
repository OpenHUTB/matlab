function root_dir=autosarroot()






    persistent autosarroot_dir
    if isempty(autosarroot_dir)
        function_at_root=which('autosarroot');
        autosarroot_dir=fileparts(function_at_root);
    end
    root_dir=autosarroot_dir;
end

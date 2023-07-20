function openModelFromReport(model)




    try
        open_system(model);
    catch ME
        hf=errordlg(ME.message);

        set(hf,'tag','Simulink_cache_error_dialog');
        setappdata(hf,'MException',ME);
    end
end
function valid=checkUploadedFileNameValidity(this,filename)
    valid=1;
    [~,~,ext]=fileparts(filename);
    [~,name,~]=fileparts(filename);
    if~CloneDetectionUI.internal.DDGViews.AddLibrary.checkFileName(name)
        valid=0;
        return;
    end

    if(~strcmpi(ext,'.slx')&&~strcmpi(ext,'.mdl'))
        this.libFilenamesText='';
        valid=0;
        disp(DAStudio.message('sl_pir_cpp:creator:IllegalName4_lib'));
        return;
    end


    if~Simulink.MDLInfo(filename).IsLibrary
        disp(DAStudio.message('sl_pir_cpp:creator:notALibFile',filename));
        valid=0;
    end

end


function pInterfaceSaveCallback(modelHandle,saveOptions,part,bdAccessMethod)





    try

        filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,part.name);
        m3iModelToSave=bdAccessMethod(get_param(modelHandle,'Name'));


        s=M3I.XmiWriterSettings;
        s.WriteModelObject=true;
        xwf=M3I.XmiWriterFactory;
        xw=xwf.createXmiWriter(s);

        xw.write(filename,m3iModelToSave);
        saveOptions.writerHandle.writePartFromFile(part,filename);

    catch ME %#ok<NASGU>


        warning('Simulink:SlSystemArchitecture:SaveFailure',...
        DAStudio.message('Simulink:SlSystemArchitecture:SaveFailure'))
    end

end


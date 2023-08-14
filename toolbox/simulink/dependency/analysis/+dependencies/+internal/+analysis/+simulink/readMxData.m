function data=readMxData(handler,tag)





    file=handler.ModelInfo.ResavedPath;


    origWarn=warning('off');
    cleanup=onCleanup(@()warning(origWarn));


    if handler.ModelInfo.IsSLX
        reader=Simulink.loadsave.SLXPackageReader(file);


        if reader.hasPart('/simulink/bdmxdata.mat')
            allData=dependencies.internal.analysis.simulink.readMatData(...
            reader,'/simulink/bdmxdata.mat',@load);
            data=allData.(tag);


        else
            data=reader.readPartToVariable(['/simulink/bdmxdata/',tag,'.mxarray']);
        end


    else
        match=Simulink.loadsave.findAll(file,['/MatData/DataRecord[Tag="',tag,'"]/Data']);
        data=sls_uudecode(match{1}(1).Value);
    end

end


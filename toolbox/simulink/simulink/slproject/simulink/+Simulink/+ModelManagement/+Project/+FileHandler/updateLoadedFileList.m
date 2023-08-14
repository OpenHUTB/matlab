function fileList=updateLoadedFileList()




    if isSimulinkStarted
        bds=Simulink.allBlockDiagrams;

        fileName=get_param(bds,'Name');
        filePath=get_param(bds,'FileName');
        simulating=~strcmp(get_param(bds,'SimulationStatus'),'stopped');
        dirtyFlag=strcmp(get_param(bds,'Dirty'),'on');

        fileList=horzcat(cellstr(fileName),cellstr(filePath),num2cell(simulating),num2cell(dirtyFlag));
    else
        fileList={};
    end

end

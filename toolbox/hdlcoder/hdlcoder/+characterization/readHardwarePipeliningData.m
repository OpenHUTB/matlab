function readHardwarePipeliningData(ctx,fullfileName)


    if nargin<2
        fullfileName='';
    end

    try
        if isempty(fullfileName)||strcmpi(fullfileName,'')
            fullPath=characterization.getAdaptivePipeliningDataPath();
            charFile='hardwarepipelining.mat';
            fullfileName=fullfile(fullPath,charFile);
        end
        data=load(fullfileName);
        ctx.buildHardwarePipeliningData(data.pipeline_data);
    catch e
        e.getReport()
    end

end

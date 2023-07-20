function cleanUpInSessionModel(modelFile,cleanupScript,isLoaded)
    if~isempty(cleanupScript)
        [~,filename,~]=fileparts(cleanupScript);
        evalin('base',['run ',filename]);
    end
    [~,model,~]=fileparts(modelFile);
    if(~isLoaded)
        close_system(model,0);
    end
end

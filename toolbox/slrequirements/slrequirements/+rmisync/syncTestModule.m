function surrCellArray=syncTestModule(modelH)








    surrCellArray={};
    [~,dirName]=rmisync.syncTestMode();

    modelName=get_param(modelH,'Name');
    fileName=fullfile(dirName,[modelName,'_surrogate.csv']);
    if exist(fileName,'file')
        disp(['Reading from ',fileName]);
        surrCellArray=reqmgt('csvRead',fileName);
    end
end


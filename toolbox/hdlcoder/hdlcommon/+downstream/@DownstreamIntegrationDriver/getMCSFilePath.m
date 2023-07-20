function mcsFilePath=getMCSFilePath(obj)


    if obj.isSLRTWorkflow
        mcsFilePath=fullfile(obj.getProjectPath,obj.getMCSFileName);
    else
        mcsFilePath='';
    end
end

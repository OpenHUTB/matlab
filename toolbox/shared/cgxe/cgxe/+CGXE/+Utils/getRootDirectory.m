function rootDirectory=getRootDirectory(model,currentDirPath)

    if isempty(model)
        rootDirectory=currentDirPath;
        return;
    end
    modelFullName=get_param(model,'filename');
    if(isempty(modelFullName))
        [isSubsys,rootModel]=isSubsystemBuild(model);
        if isSubsys
            rootDirectory=CGXE.Utils.getRootDirectory(rootModel,currentDirPath);
        elseif strcmpi(get_param(model,'IsHarness'),'on')

            origModel=Simulink.harness.internal.getHarnessOwnerBD(model);
            origModelPath=get_param(origModel,'FileName');
            rootDirectory=fileparts(origModelPath);
        else
            rootDirectory=currentDirPath;
        end
    else

        if(contains(modelFullName,filesep))



            if(isequal(get_param(model,'ModelReferenceMultiInstanceNormalModeCopy'),'on'))
                origModel=get_param(model,'ModelReferenceNormalModeOriginalModelName');
                origModelPath=get_param(origModel,'FileName');
                rootDirectory=fileparts(origModelPath);
            else
                rootDirectory=fileparts(modelFullName);
            end
        else

            rootDirectory=currentDirPath;
        end
    end

    function[isSubsys,rootModel]=isSubsystemBuild(model)
        isSubsys=false;
        rootModel='';
        try
            sourceSubsys=rtwprivate('getSourceSubsystemName',model);
            isSubsys=~isempty(sourceSubsys);
            if isSubsys
                rootModel=bdroot(sourceSubsys);
            end
        catch ME
        end

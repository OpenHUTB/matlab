function success=setInstallConfiguration(varargin)









    success=false;


    if nargin>0
        forceUpdate=strcmpi(varargin{1},'refresh');
    else
        forceUpdate=false;
    end

    PrefFile=fullfile(prefdir,'mdladvprefs.mat');
    alreadyCreated=false;
    prefFileExist=exist(PrefFile,'file');
    if prefFileExist
        mdladvprefs=load(PrefFile);
        if isfield(mdladvprefs,'InstallConfiguration')&&...
            isfield(mdladvprefs.InstallConfiguration,'CheckID')
            alreadyCreated=true;
        end
    end

    if alreadyCreated&&~forceUpdate
        return
    end

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    if~strcmp(mdladvObj.CustomTARootID,'_modeladvisor_')
        return;
    end


    if isa(mdladvObj,'Simulink.ModelAdvisor')
        [CheckID,checkTitle]=createConfig(mdladvObj.TaskAdvisorRoot,{},{});
        [CheckID,sortIdx]=unique(CheckID);
        checkTitle=checkTitle(sortIdx);

        InstallConfiguration.CheckID=CheckID;
        InstallConfiguration.CheckTitle=checkTitle;%#ok<STRNU>

        if prefFileExist
            save(PrefFile,'InstallConfiguration','-append');
        else
            save(PrefFile,'InstallConfiguration');
        end
        success=true;
    end

    function[checkIDList,checkTitle]=createConfig(currentNode,checkIDList,checkTitle)
        if isempty(currentNode)
            return;
        end
        if isa(currentNode,'ModelAdvisor.Task')
            checkIDList=[checkIDList,currentNode.MAC];
            if~isempty(currentNode.MAC)&&isempty(currentNode.DisplayName)
                checkTitle=[checkTitle,{''}];
            else
                checkTitle=[checkTitle,currentNode.DisplayName];
            end
        else
            for i=1:length(currentNode.ChildrenObj)
                [checkIDList,checkTitle]=createConfig(currentNode.ChildrenObj{i},checkIDList,checkTitle);
            end
        end



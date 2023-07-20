








function varargout=copySlCustomizationData(obj,stage,varargin)

    PerfTools.Tracer.logMATLABData('MAGroup','Copy Objects',true);

    obj.updateCacheIfNeeded;

    switch stage
    case 'Check'
        varargout{1}=obj.slCustomizationDataStructure.checkCellArray;
        varargout{2}=make_a_copy(obj.slCustomizationDataStructure,'GroupedrecordTree');
        varargout{3}=make_a_copy(obj.slCustomizationDataStructure,'taskCellArray');
        varargout{4}=make_a_copy(obj.slCustomizationDataStructure,'callbackFuncInfoStruct');
    case 'GUI'
        maobj=varargin{1};
        mp=ModelAdvisor.Preferences;
        ForceRunOnLibrary=modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary');
        NeedSupportLib=maobj.IsLibrary&&modeladvisorprivate('modeladvisorutil2','FeatureControl','SupportLibrary');


        if isfield(obj.slCustomizationDataStructure,'APIConfigFilePath')
            maobj.APIConfigFilePath=obj.slCustomizationDataStructure.APIConfigFilePath;
        end

        applicationObj=obj.getActiveApp;
        configFile=modeladvisorprivate('modeladvisorutil2','GetConfigFileName',maobj);
        applicationObj.TaskManager.setConfigFilePath(configFile);

        if~isempty(configFile)&&~strcmp(configFile,'shipping')

            modeladvisorprivate('modeladvisorutil2','loadConfigPref',maobj);
        end

        if strcmp(configFile,'shipping')
            needLoadInputparamFromConfigUICellArray=false;


            customizationData=obj.slCustomizationDataStructure;

            if isfield(customizationData,'DefaultCustomizationData')
                customizationData=customizationData.DefaultCustomizationData;
                UseDefaultCustomizationData=true;
            else
                UseDefaultCustomizationData=false;
            end

            TaskAdvisorCellArray=Advisor.Utils.connectTree(make_a_copy(customizationData,'TaskAdvisorCellArray'),UseDefaultCustomizationData);

            topLevelWorkFlows=customizationData.topLevelWorkFlows;
            for i=1:length(topLevelWorkFlows)
                topLevelWorkFlows{i}=TaskAdvisorCellArray{topLevelWorkFlows{i}};
            end

        elseif~isempty(maobj.ConfigFilePath)&&(isa(maobj.ConfigUIRoot,'ModelAdvisor.ConfigUI')||isstruct(maobj.ConfigUIRoot))

            needLoadInputparamFromConfigUICellArray=true;
            configrecordCellArray=cell(1,length(maobj.ConfigUICellArray));
            for i=1:length(maobj.ConfigUICellArray)
                configrecordCellArray{i}=ModelAdvisor.ConfigUI.convertTaskAdvisor(maobj.ConfigUICellArray{i});
            end
            [topLevelWorkFlows,TaskAdvisorCellArray]=linknodes(configrecordCellArray,maobj.ConfigUIRoot);
            for i=1:length(topLevelWorkFlows)
                topLevelWorkFlows{i}=TaskAdvisorCellArray{topLevelWorkFlows{i}};
            end
            TaskAdvisorCellArray=Advisor.Utils.connectTree(TaskAdvisorCellArray,false);
        else
            needLoadInputparamFromConfigUICellArray=false;
            topLevelWorkFlows=obj.slCustomizationDataStructure.topLevelWorkFlows;
            if mp.MinimizeTree
                objectsCopied=[];
                if strcmp(maobj.CustomTARootID,'_modeladvisor_')
                    TaskAdvisorCellArray={};
                    for i=1:numel(topLevelWorkFlows)
                        rootObj=obj.slCustomizationDataStructure.TaskAdvisorCellArray{topLevelWorkFlows{i}};
                        [tempTAArray,objectsCopied]=Advisor.Utils.copyTree(rootObj,numel(TaskAdvisorCellArray),objectsCopied);
                        TaskAdvisorCellArray=[TaskAdvisorCellArray,tempTAArray];%#ok<AGROW>
                        topLevelWorkFlows{i}=tempTAArray{1};
                        tempTAArray{1}.ParentIndex=[];
                    end
                else
                    rootObj=obj.slCustomizationDataStructure.TaskAdvisorCellArray{obj.slCustomizationDataStructure.TaskAdvisorIDMap(maobj.CustomTARootID)};
                    [TaskAdvisorCellArray,objectsCopied]=Advisor.Utils.copyTree(rootObj,0,objectsCopied);
                    topLevelWorkFlows=TaskAdvisorCellArray{1};
                    TaskAdvisorCellArray{1}.ParentIndex=[];
                end

                [unique_objects,unique_indices]=unique(objectsCopied);
                if numel(objectsCopied)>numel(unique_objects)
                    duplicate_indices=setdiff(1:numel(objectsCopied),unique_indices);
                    duplicate_tasks='';
                    for i=1:numel(duplicate_indices)
                        duplicate_tasks=[duplicate_tasks,TaskAdvisorCellArray{duplicate_indices(i)}.Id];
                    end
                    DAStudio.error('Advisor:engine:DuplicateTasksInCheckTree',duplicate_tasks);
                end
            else
                TaskAdvisorCellArray=make_a_copy(obj.slCustomizationDataStructure,'TaskAdvisorCellArray');
                for i=1:length(topLevelWorkFlows)
                    topLevelWorkFlows{i}=TaskAdvisorCellArray{topLevelWorkFlows{i}};
                end
            end
            TaskAdvisorCellArray=Advisor.Utils.connectTree(TaskAdvisorCellArray,false);
        end



        skippedElements=true(1,length(obj.slCustomizationDataStructure.checkCellArray));
        maobj.CheckCellArray=[];


        CheckCellArray=cell(1,length(obj.slCustomizationDataStructure.checkCellArray));
        maobj.FastCheckAccessTable=zeros(length(CheckCellArray),1);
        amCheckCellArray=obj.slCustomizationDataStructure.checkCellArray;

        [TaskAdvisorCellArray,CheckCellArray,skippedElements]=Advisor.Utils.createCheckObjForTree(maobj,TaskAdvisorCellArray,CheckCellArray,skippedElements,needLoadInputparamFromConfigUICellArray,NeedSupportLib,ForceRunOnLibrary);

        skippedElements=find(skippedElements);

        for i=1:length(skippedElements)
            CheckCellArray{skippedElements(i)}=...
            copy(amCheckCellArray{skippedElements(i)});

            if NeedSupportLib
                if~CheckCellArray{skippedElements(i)}.SupportLibrary&&~ForceRunOnLibrary
                    CheckCellArray{skippedElements(i)}.Selected=false;
                    CheckCellArray{skippedElements(i)}.SelectedByTask=false;
                    CheckCellArray{skippedElements(i)}.Enable=false;
                end
            end
        end
        maobj.CheckCellArray=CheckCellArray;

        varargout{1}=topLevelWorkFlows;
        varargout{2}=TaskAdvisorCellArray;
    case 'LibTaskAdvisorCellArray'
        maobj=varargin{1};
        maobj.LibTaskAdvisorCellArray=Advisor.Utils.connectTree(make_a_copy(obj.slCustomizationDataStructure,'LibTaskAdvisorCellArray'),false);
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Copy Objects',false);
end

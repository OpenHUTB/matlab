function taskObj=getTaskObj(this,Identifier,varargin)



































    opts.Identifier=Identifier;
    opts.regexp=false;
    opts.type='TaskID';
    opts.CreateObjectIfNotFound=true;
    opts=slprivate('parseArgs',opts,varargin{:});

    am=Advisor.Manager.getInstance;
    tempDB=this.TaskAdvisorCellarray;
    if isfield(am.slCustomizationDataStructure,'TaskAdvisorCellArray')
        fullDB=am.slCustomizationDataStructure.TaskAdvisorCellArray;
    else
        fullDB={};
    end

    switch opts.type
    case{'TaskID','ID'}
        opts.field='ID';
        taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);

        if isempty(taskObj)
            newID=ModelAdvisor.convertCheckID(Identifier,'TaskID');
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',Identifier,newID);
                opts.Identifier=newID;
                taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
                if isempty(taskObj)&&opts.CreateObjectIfNotFound
                    taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts);
                end
            else

                if opts.CreateObjectIfNotFound
                    taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts);
                end
            end
        end
    case 'CheckID'
        opts.field='MAC';
        taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);

        if isempty(taskObj)
            newID=ModelAdvisor.convertCheckID(Identifier);
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',Identifier,newID);
                opts.Identifier=newID;
                taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
                if isempty(taskObj)&&opts.CreateObjectIfNotFound
                    taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts);
                end
            else

                if opts.CreateObjectIfNotFound
                    taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts);
                end
            end
        end
    case{'TaskTitle','DisplayLabel'}
        opts.field='DisplayName';
        taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
        if isempty(taskObj)&&opts.CreateObjectIfNotFound
            taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts);
        end
    otherwise
        DAStudio.error('Simulink:tools:MAInvalidType',opts.type);
    end






    if(isempty(varargin)||~opts.CreateObjectIfNotFound)&&~isempty(taskObj)
        taskObj=taskObj{1};
    end
end

function taskObj=searchInFullDatabase_and_addIntoCurrentDatabase(this,fullDB,tempDB,opts)
    taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',fullDB,opts);
    if~isempty(taskObj)
        tempDB=loc_add_tree_into_taskadvisorcellarray(this,tempDB,taskObj{1});
        this.TaskAdvisorCellarray=tempDB;
        taskObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
    end
end

function TaskAdvisorCellArray=loc_add_tree_into_taskadvisorcellarray(maobj,TaskAdvisorCellArray,rootObj)
    am=Advisor.Manager.getInstance;

    tac=am.slCustomizationDataStructure.TaskAdvisorCellArray;
    while~isempty(rootObj.ParentIndex)
        rootObj=tac{rootObj.ParentIndex};
    end

    tempTAArray=Advisor.Utils.copyTree(rootObj,numel(TaskAdvisorCellArray),[]);


    if~isempty(maobj.ConfigFilePath)&&isa(maobj.ConfigUIRoot,'ModelAdvisor.ConfigUI')
        needLoadInputparamFromConfigUICellArray=true;
    else
        needLoadInputparamFromConfigUICellArray=false;
    end
    ForceRunOnLibrary=modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary');
    NeedSupportLib=maobj.IsLibrary&&modeladvisorprivate('modeladvisorutil2','FeatureControl','SupportLibrary');
    [tempTAArray,maobj.CheckCellArray]=Advisor.Utils.createCheckObjForTree(maobj,tempTAArray,...
    maobj.CheckCellArray,true(1,length(maobj.CheckCellArray)),...
    needLoadInputparamFromConfigUICellArray,NeedSupportLib,ForceRunOnLibrary);
    for i=1:numel(tempTAArray)
        tempTAArray{i}.MAObj=maobj;
    end

    TaskAdvisorCellArray=[TaskAdvisorCellArray,tempTAArray];
    Advisor.Utils.connectTree(tempTAArray,false,TaskAdvisorCellArray);
end

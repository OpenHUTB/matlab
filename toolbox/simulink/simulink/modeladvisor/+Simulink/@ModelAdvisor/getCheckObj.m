function checkObj=getCheckObj(this,Identifier,varargin)
































    opts.Identifier=Identifier;
    opts.regexp=false;
    opts.type='CheckID';
    opts=slprivate('parseArgs',opts,varargin{:});

    switch opts.type
    case{'CheckID','ID'}
        tempDB=this.CheckCellarray;
        opts.field='ID';
        if opts.regexp||isnumeric(opts.Identifier)
            checkObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
        else
            if this.CheckIDMap.isKey(opts.Identifier)
                checkObj=this.CheckCellarray(this.CheckIDMap(opts.Identifier));
            else
                checkObj={};
            end
        end

        if isempty(checkObj)
            newID=ModelAdvisor.convertCheckID(Identifier);
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',Identifier,newID);
                opts.Identifier=newID;
                checkObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
            end
        end
    case 'TaskID'
        tempDB=this.TaskAdvisorCellarray;
        opts.field='ID';
        checkObj=task2Check(this,...
        modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts));
    case{'TaskTitle','DisplayLabel'}
        tempDB=this.TaskAdvisorCellArray;
        opts.field='DisplayName';
        checkObj=task2Check(this,...
        modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts));
    otherwise
        DAStudio.error('Simulink:tools:MAInvalidType',opts.type);
    end





    if isempty(varargin)&&~isempty(checkObj)
        checkObj=checkObj{1};
    end


    function checkObj=task2Check(this,taskObj)
        checkObj={};
        if~isempty(taskObj)
            checkObjIndex=[];
            for i=1:length(taskObj)
                if isprop(taskObj{i},'MACIndex')
                    checkObjIndex(end+1)=taskObj{i}.MACIndex;
                end
            end

            checkObjIndex=unique(checkObjIndex);

            if length(checkObjIndex)>1
                checkObj=this.CheckCellArray(checkObjIndex(:));
            else
                checkObj=this.CheckCellArray{checkObjIndex(:)};
            end
        end

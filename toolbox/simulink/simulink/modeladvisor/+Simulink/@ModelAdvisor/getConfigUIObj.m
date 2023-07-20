function configuiObj=getConfigUIObj(this,Identifier,varargin)

































    opts.Identifier=Identifier;
    opts.regexp=false;
    opts.from='ConfigUICellArray';
    opts.type='CheckID';
    opts=slprivate('parseArgs',opts,varargin{:});

    switch opts.from
    case 'CheckLibrary'
        tempDB=this.CheckLibrary;
    case 'ConfigUICellArray'
        tempDB=this.ConfigUICellArray;
    otherwise
        DAStudio.error('Simulink:tools:MAGetConfigObjInvalidSource');
    end

    if isempty(tempDB)
        DAStudio.error('Simulink:tools:MAGetConfigObjArrayNotPopulated','getConfigUIObj');
    end

    switch opts.type
    case 'CheckID'
        opts.field='MAC';
        configuiObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);

        if isempty(configuiObj)
            newID=ModelAdvisor.convertCheckID(Identifier);
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',Identifier,newID);
                opts.Identifier=newID;
                configuiObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
            end
        end
    case{'ConfigUIID','ID'}
        opts.field='ID';
        configuiObj=modeladvisorprivate('modeladvisorutil2','CellArrayFinder',tempDB,opts);
    otherwise
        DAStudio.error('Simulink:tools:MAInvalidType',opts.type);
    end





    if isempty(varargin)&&~isempty(configuiObj)
        configuiObj=configuiObj{1};
    end

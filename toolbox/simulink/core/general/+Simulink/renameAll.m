function renameAll(context,oldname,newname,scope,varargin)















    narginchk(4,inf);


    if isequal(oldname,newname)
        return;
    end


    if~isvarname(newname)
        DAStudio.error('Simulink:Data:RenameAllInvalidName',newname);
    end

    if strcmpi(scope,'model workspace')
        assert(~iscell(context),'Context must be a single model for searching in ''Model Workspace''');
        Simulink.data.internal.renameAllApply(context,'Variable',...
        oldname,newname,...
        'Source',context,...
        'Regexp','on',...
        varargin{:});
    else
        str=split(scope,':');
        assert(length(str)==2,'Scope must be either ''Model Workspace'', ''Global Workspace:Design'', or ''Global Workspace:Configurations''.');
        source=str(1);
        assert(strcmpi(source,'global workspace'),'Scope must be either ''Model Workspace'', ''Global Workspace:Design'', or ''Global Workspace:Configurations''.');
        scopeType=str(2);
        assert(strcmpi(scopeType,'design')||strcmpi(scopeType,'configurations'),'Scope must be either ''Model Workspace'', ''Global Workspace:Design'', or ''Global Workspace:Configurations''.');

        if strcmpi(scopeType,'Configurations')
            scopeType='Configurations';
        else
            scopeType='Design';
        end

        [sources,~]=Simulink.data.internal.renameAllAnalyze(context,...
        true,[],oldname,...
        'Scope',scopeType,...
        'SourceType','data dictionary',...
        varargin{:});

        sources=join(sources,'|');

        Simulink.data.internal.renameAllApply(context,'Variable',...
        oldname,newname,...
        'Regexp','on',...
        'Source',sources{1},...
        'Scope',scopeType,...
        varargin{:});
    end
end

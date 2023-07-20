function[sources,varUsage]=renameAllAnalyze(model,globalScope,objScope,oldname,varargin)







    if globalScope
        varUsage=loc_getGlobalVarUsage(model,objScope,oldname,varargin{:});
    else

        varUsage=Simulink.findVars(model,...
        'Name',oldname,...
        'Regexp','on',...
        varargin{:});

        assert(numel(varUsage)<2);
    end


    sources={};
    for i=1:numel(varUsage)
        sources{end+1}=['^',varUsage(i).Source,'$'];
    end

    index=find(strcmpi(varargin,'Source'));
    if~isempty(index)
        sources=union({varargin{index+1}},sources);
    end

end

function result=loc_isObjConfigSet(scope,oldname)
    if isempty(scope)
        result=loc_isBWSVarConfigSet(oldname);
    else
        result=strcmp(scope,'Configurations');
    end
end

function result=loc_isDesignData(varUsage)
    assert(numel(varUsage)==1);
    switch(varUsage.SourceType)
    case 'base workspace'
        result=~loc_isBWSVarConfigSet(varUsage.Name);
    case 'data dictionary'
        result=strcmp(varUsage.Scope,'Design');
    otherwise
        result=false;
    end
end

function result=loc_isConfigSet(varUsage)
    assert(numel(varUsage)==1);
    switch(varUsage.SourceType)
    case 'base workspace'
        result=loc_isBWSVarConfigSet(varUsage.Name);
    case 'data dictionary'
        result=strcmp(varUsage.Scope,'Configurations');
    otherwise
        result=false;
    end
end

function isCfgSet=loc_isBWSVarConfigSet(varname)
    assert(evalin('base',['exist(''',varname,''', ''var'')'])==1);
    isCfgSet=evalin('base',['isa(',varname,', ''Simulink.ConfigSet'')']);
end

function varUsageCollected=loc_collectVarUsage(varUsage,filter,varUsageCollected)
    for i=1:numel(varUsage)
        usage=varUsage(i);
        if filter(usage)
            if isempty(varUsageCollected)
                varUsageCollected=usage;
            else
                varUsageCollected(end+1)=usage;
            end
        end
    end
end

function varUsage=loc_getGlobalVarUsage(model,objScope,oldname,varargin)

    varUsed=Simulink.findVars(model,...
    'Name',oldname,...
    'Regexp','on',...
    varargin{:});

    try
        index=find(strcmpi(varargin,'SearchMethod'));
        if~isempty(index)
            varargin{index+1}='cached';
        else
            varargin{end+1}='SearchMethod';
            varargin{end+1}='cached';
        end
        varNotUsed=Simulink.findVars(model,...
        'Name',oldname,...
        'Regexp','on',...
        'FindUsedVars',false,...
        varargin{:});
    catch

        varNotUsed=[];
    end


    if~isempty(objScope)
        scope=objScope;
    else
        index=find(strcmpi(varargin,'Scope'));
        if~isempty(index)
            scope=varargin{index+1};
        else
            scope='';
        end
    end

    if loc_isObjConfigSet(scope,oldname)
        filter=@loc_isConfigSet;
    else
        filter=@loc_isDesignData;
    end

    varUsage=loc_collectVarUsage(varUsed,filter,[]);
    varUsage=loc_collectVarUsage(varNotUsed,filter,varUsage);
end

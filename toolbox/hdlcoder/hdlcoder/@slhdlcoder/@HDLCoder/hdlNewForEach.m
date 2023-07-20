function[defaultStmt,implchoices,implpvpairs,currentstmt]=hdlNewForEach(this,block)




    defaultStmt='';
    implchoices={};
    implpvpairs={};
    currentstmt='';

    if ischar(block)
        block={block};
    end


    for ii=1:length(block)
        if isempty(this)
            return;
        end

        if isempty(this.ImplDB)
            this.buildDatabase;
        end

        slBlockPath=getSLBlockPath(block{ii});
        blockLibPath=getBlockLibPath(block{ii});
        configManager=this.getConfigManager;

        if isempty(configManager)
            return;
        end

        try
            defaultImpl=configManager.getDefaultImplementation(blockLibPath);
            currentImpl=configManager.getImplementationForBlock(slBlockPath);
        catch me

            return;
        end

        implDB=this.ImplDB;
        [newImpls,newPVPairs]=implDB.getPublishedImplementations(blockLibPath);

        for jj=1:length(newImpls)
            toCheck=newImpls{jj};
            if isDefaultImpl(toCheck,class(defaultImpl))

                newImpls{jj}='default';
            end
        end

        implchoices={implchoices{:},newImpls};%#ok<CCAT>
        implpvpairs={implpvpairs{:},newPVPairs{:}};%#ok<CCAT>

        if isempty(defaultImpl)||...
            shouldIgnoreBlock(blockLibPath)
            continue;
        end

        if isSubsystemSpecialCase(defaultImpl,blockLibPath)
            return;
        end

        relativePath=configManager.slPathToRelativePath(slBlockPath);
        defaultArchName=defaultImpl.getPreferredArchitectureName();

        if~strcmp(defaultArchName,class(defaultImpl))
            endComment=sprintf(' %% Default architecture is ''%s''',defaultArchName);
        else
            endComment='';
        end

        defaultStmt=[defaultStmt,sprintf('c.forEach(''%s'',...\n ''%s'', {},...\n ''%s'', {});%s\n\n',...
        relativePath,...
        blockLibPath,...
        'default',...
        endComment)];%#ok<AGROW>

        ipstr=getImplParamsString(currentImpl);

        if isDefaultImpl(class(currentImpl),class(defaultImpl))
            currentArchName='default';
        else
            currentArchName=class(currentImpl);
            endComment='';
        end
        currentstmt=[currentstmt,sprintf('c.forEach(''%s'',...\n ''%s'', {},...\n ''%s'', %s);%s\n\n',...
        relativePath,...
        blockLibPath,...
        currentArchName,...
        ipstr,...
        endComment)];%#ok<AGROW>

    end
end


function blockLibPath=getBlockLibPath(block)
    [blockLibPath,isInvalid]=hdlgetblocklibpath(block);
    blockLibPath=strrep(blockLibPath,char(10),' ');

    if isInvalid
        error(message('hdlcoder:engine:invalid',block));
    end
end

function slBlockPath=getSLBlockPath(block)
    blkObj=get_param(block,'Object');

    slBlockPath=[blkObj.path,'/',blkObj.name];
    slBlockPath=strrep(slBlockPath,char(10),' ');
end

function configManager=getConfigManager(hdlCoder)
    configManager=[];
    try
        if isempty(hdlCoder.ConfigManager)
            hdlCoder.createConfigManager;
            hdlCoder.ConfigManager.parseDefaultConfigs(hdlCoder.ImplDB);
        end
    catch me %#ok<*NASGU>
        warning(message('hdlcoder:engine:NoConfigManager'))
        return;
    end
    configManager=hdlCoder.ConfigManager;
end

function specialCase=isSubsystemSpecialCase(defaultImpl,blockLibPath)
    specialCase=isempty(defaultImpl)&&...
    any(strmatch(blockLibPath,...
    {'built-in/SubSystem'},'exact'));
end

function ignore=shouldIgnoreBlock(blockLibPath)
    ignore=any(strmatch(blockLibPath,...
    {'built-in/Inport',...
    'built-in/Outport'},...
    'exact'));
end


function paramString=getImplParamsString(implInstance)
    ip=implInstance.implParams;
    paramString='{';
    for jj=1:length(ip)
        if ischar(ip{jj})
            paramString=[paramString,'''',ip{jj},''', '];%#ok<AGROW>
        elseif isnumeric(ip{jj})
            paramString=[paramString,int2str(ip{jj}),', '];%#ok<AGROW>
        end
    end
    if length(paramString)>1
        paramString=paramString(1:end-2);
    end
    paramString=[paramString,'}'];
end

function isDefault=isDefaultImpl(toCheck,defaultImpl)
    assert(isa(toCheck,'char'));
    assert(isa(defaultImpl,'char'));
    isDefault=strcmp(toCheck,defaultImpl);
end


function parseUserBlockSettings(this,hImplDatabase,startNodeName)




    configStmts=convertBlockSettingsToConfigStmts(this,startNodeName);
    if~isempty(configStmts)
        this.parseConfigStatements(hImplDatabase,configStmts,false);
        updateMergeConfigContainter(this,configStmts);
    end
end

function updateMergeConfigContainter(this,stmts)
    cc=slhdlcoder.ConfigurationContainer;
    cc.statements=stmts;
    this.MergedConfigContainer.merge(cc);
end


function configStmts=convertBlockSettingsToConfigStmts(this,startNodeName)

    configStmts=getStmtFromHDLBlkInfo(this,startNodeName);

    configStmts=updateBlocksWithHDLImplParams(this,startNodeName,configStmts);
end


function stmts=updateBlocksWithHDLImplParams(this,ssPath,stmts)




    blockList=find_system(ssPath,'SearchDepth',1,...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'LookUnderMasks','all','FollowLinks','on');

    blockList(strcmp(ssPath,ssPath))=[];

    blockHandles=get_param(blockList,'Handle');
    blockHandles=cell2mat(blockHandles);

    for k=1:length(blockHandles)
        slbh=blockHandles(k);
        blkPath=getfullname(slbh);
        typ=get_param(blkPath,'BlockType');
        newStmt=getStmtFromHDLBlkInfo(this,slbh);
        stmts=[stmts,newStmt];%#ok<AGROW>

        if strcmpi(typ,'SubSystem')
            stmts=updateBlocksWithHDLImplParams(this,blkPath,stmts);
        end
    end
end

function stmt=getStmtFromHDLBlkInfo(this,slbh)
    stmt=[];
    unsupportedParams={};
    try
        block=hdlgetblocklibpath(slbh);
        hd=get_param(slbh,'HDLData');

        if~isempty(hd)
            stmt=getStmt(this,slbh,hd);
        end

        if strcmpi(block,'built-in/SubSystem')...
            &&(isempty(hd)||strcmpi(hd.archSelection,'Module'))

            if targetcodegen.xilinxsysgendriver.isXsgVivado
                isXSG=targetcodegen.xilinxvivadosysgendriver.isXSGSubsystem(slbh);
            else
                isXSG=targetcodegen.xilinxisesysgendriver.isXSGSubsystem(slbh);
            end
            isDSPBA=targetcodegen.alteradspbadriver.isDSPBASubsystem(slbh);

            if(isXSG||isDSPBA)
                if isempty(stmt)
                    stmt=getStmt(this,slbh,hd);
                end
                if(isXSG)
                    if targetcodegen.xilinxsysgendriver.isXsgVivado
                        stmt.Implementation='XilinxVivadoSystemGeneratorSubsystem';
                        supportedParams=implParamNames(hdldefaults.XilinxVivadoSystemGeneratorSubsystem);
                    else
                        stmt.Implementation='XilinxSystemGeneratorSubsystem';
                        supportedParams=implParamNames(hdldefaults.XilinxSystemGeneratorSubsystem);
                    end
                elseif(isDSPBA)
                    stmt.Implementation='AlteraDSPBASubsystem';
                    supportedParams=implParamNames(hdldefaults.AlteraDSPBASubsystem);
                end
                actParams=hd.archImplInfo(1:2:end);
                for i=1:length(actParams)
                    param=actParams{i};
                    if isempty(find(strcmpi(supportedParams,param),1))
                        unsupportedParams{end+1}=param;%#ok<AGROW>
                    end
                end
            end
        elseif strcmpi(block,'built-in/ModelReference')&&~isempty(hd)&&...
            ~strcmpi(hd.archSelection,'ModelReference')&&...
            ~strcmpi(hd.archSelection,'BlackBox')&&...
            ~strcmpi(hd.archSelection,'default')


            stmt.Implementation='ModelReference';


        elseif strcmpi(block,'simulink/Discrete/Discrete PID Controller')&&~isempty(hd)&&...
            ~strcmpi(hd.archSelection,'default')
            stmt.Implementation='default';
        elseif strcmp(block,'nesl_utility/SolverConfiguration')
            if isempty(stmt)
                stmt=getStmt(this,slbh,[]);
            end
            stmt.Implementation='hdldefaults.NoHDL';
        end
    catch me %#ok<NASGU>
    end
    for i=1:length(unsupportedParams)
        param=unsupportedParams{i};
        if isempty(find(strcmpi(supportedParams,param),1))
            error(message('hdlcoder:validate:dspbaxsgunsupportedparam',param,[get_param(slbh,'parent'),'/',get_param(slbh,'name')]));
        end
    end
end

function stmt=getStmt(this,slbh,hd)
    blkFullPath=getfullname(slbh);
    mdlName=bdroot(blkFullPath);
    scope=regexprep(blkFullPath,['^',mdlName,'/'],'./');

    block=hdlgetblocklibpath(slbh);
    blockparams=[];

    if~isempty(hd)
        impl=hd.getCurrentArch;
        implparams=hd.getCurrentArchImplParams;
    else
        impl=this.getDefaultImplementation(block);
        implparams=[];
    end

    blkip{1}=block;
    for ii=1:length(implparams)
        blkip{end+1}=implparams{ii};%#ok<AGROW>
    end

    stmt=struct(...
    'Scope',scope,...
    'BlockType',block,...
    'BlockParams',blockparams,...
    'Implementation',impl,...
    'ImplParams',{blkip});
end


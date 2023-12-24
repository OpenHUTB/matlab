function injSSData=InjectorPrototypeCompileHelper(topMdlH,operation)

    persistent cachedInjectorData;

    if operation==1
        injSSData=cachedInjectorData;
        return;
    end

    warning('off','Simulink:Engine:InputNotConnected');
    warning('off','Simulink:Engine:OutputNotConnected');
    warning('off','Simulink:Engine:LineWithoutSrc');
    warning('off','Simulink:Engine:LineWithoutDst');

    injRefHdls=Simulink.injector.internal.getInjectorRefBlocksInBD(topMdlH);
    topMdlName=get_param(topMdlH,'Name');
    injSSData=[];


    for j=1:numel(injRefHdls)
        injRefHdl=injRefHdls(j);
        injMdlName=get_param(injRefHdl,'InjectorModelName');
        open_system(injRefHdl);
        injMdlHdl=get_param(injMdlName,'Handle');
        injSSHdls=Simulink.injector.internal.getInjectorSubsystemsInBD(injMdlHdl);


        for k=1:numel(injSSHdls)
            injSSHdl=injSSHdls(k);
            injSSName=getfullname(injSSHdl);
            injInHdls=Simulink.injector.internal.getGrInjectorInportsInInjectorSubsystem(injSSHdl);
            injOutHdls=Simulink.injector.internal.getGrInjectorOutportsInInjectorSubsystem(injSSHdl);
            nInjIn=numel(injInHdls);
            nInjOut=numel(injOutHdls);
            accPts=zeros(nInjIn,1);


            for l=1:nInjIn
                injInHdl=injInHdls(l);
                blkH=Simulink.injector.internal.getInjectedBlock(injInHdl);
                prtIdx=Simulink.injector.internal.getInjectedPortIndex(injInHdl);
                prtHdls=get_param(blkH,'PortHandles');
                accPts(l)=prtHdls.Outport(prtIdx+1);
            end
            injPts=zeros(nInjOut,1);
            injPtDsts=cell(nInjOut,1);
            for l=1:nInjOut
                injOutHdl=injOutHdls(l);
                blkH=Simulink.injector.internal.getInjectedBlock(injOutHdl);
                prtIdx=Simulink.injector.internal.getInjectedPortIndex(injOutHdl);
                prtHdls=get_param(blkH,'PortHandles');
                injPts(l)=prtHdls.Outport(prtIdx+1);
                linH=get_param(injPts(l),'Line');
                injPtDsts{l}=get_param(linH,'DstPortHandle');
            end



            injSSNewHdl=add_block(injSSName,[topMdlName,'/Injector Subsystem'],'MakeNameUnique','on','Position',[0,0,0,0],'ShowName','off');
            set_param(injSSNewHdl,'TreatAsAtomicUnit','off');
            set_param(injSSNewHdl,'Selected','off');
            injSSNewName=getfullname(injSSNewHdl);



            injInDsts=cell(nInjIn,1);
            for l=1:nInjIn
                injInNewName=[injSSNewName,'/',get_param(injInHdls(l),'Name')];
                prtHdls=get_param(injInNewName,'PortHandles');
                injInOpHdl=prtHdls.Outport;
                linH=get_param(injInOpHdl,'Line');
                injInDsts{l}=get_param(linH,'DstPortHandle');
                delete_block(injInNewName);
            end
            injOutSrcs=zeros(nInjOut,1);
            for l=1:nInjOut
                injOutNewName=[injSSNewName,'/',get_param(injOutHdls(l),'Name')];
                prtHdls=get_param(injOutNewName,'PortHandles');
                injOutIpHdl=prtHdls.Inport;
                linH=get_param(injOutIpHdl,'Line');
                injOutSrcs(l)=get_param(linH,'SrcPortHandle');
                delete_block(injOutNewName);
            end
            renameBlocks(injSSNewHdl);
            injSSNewName=getfullname(injSSNewHdl);


            trigPt=-1;
            constBlk=-1;
            relOpBlk=-1;
            orBlk=-1;
            unitDelayBlk=-1;
            clockBlk=-1;
            switchBlks=repmat(-1,nInjOut,1);

            trigOnType=Simulink.injector.internal.getInjectorSubsystemTriggerOnType(injSSHdl);
            trigOnParams=Simulink.injector.internal.getInjectorSubsystemTriggerOnParams(injSSHdl);
            if strcmp(trigOnType,'Always')

            elseif strcmp(trigOnType,'Manual')
                constBlk=addBlockWithRandomName('Constant',injSSNewName);
                toggleSwitchSID=trigOnParams{1};
                blkH=Simulink.ID.getHandle(toggleSwitchSID);
                bindHMI(blkH,constBlk);
                for l=1:nInjOut
                    switchBlks(l)=addBlockWithRandomName('Switch',injSSNewName);
                    set_param(switchBlks(l),'Threshold','0.5');
                end
            elseif strcmp(trigOnType,'Signal')
                relOpType=trigOnParams{2};
                threshold=trigOnParams{3};
                trigPt=Simulink.injector.internal.getInjectorSubsystemTriggerOnSignal(injSSHdl);
                constBlk=addBlockWithRandomName('Constant',injSSNewName);
                set_param(constBlk,'Value',threshold);
                relOpBlk=addBlockWithRandomName('RelationalOperator',injSSNewName);
                switch relOpType
                case 'gt'
                    set_param(relOpBlk,'Operator','>');
                case 'lt'
                    set_param(relOpBlk,'Operator','<');
                otherwise

                end
                orBlk=addBlockWithRandomName('Logic',injSSNewName);
                set_param(orBlk,'Operator','OR');
                unitDelayBlk=addBlockWithRandomName('UnitDelay',injSSNewName);
                for l=1:nInjOut
                    switchBlks(l)=addBlockWithRandomName('Switch',injSSNewName);
                    set_param(switchBlks(l),'Threshold','0.5');
                end
            elseif strcmp(trigOnType,'Timed')
                threshold=trigOnParams{1};
                constBlk=addBlockWithRandomName('Constant',injSSNewName);
                set_param(constBlk,'Value',threshold);
                relOpBlk=addBlockWithRandomName('RelationalOperator',injSSNewName);
                set_param(relOpBlk,'Operator','>');
                orBlk=addBlockWithRandomName('Logic',injSSNewName);
                set_param(orBlk,'Operator','OR');
                unitDelayBlk=addBlockWithRandomName('UnitDelay',injSSNewName);
                clockBlk=addBlockWithRandomName('Clock',injSSNewName);
                for l=1:nInjOut
                    switchBlks(l)=addBlockWithRandomName('Switch',injSSNewName);
                    set_param(switchBlks(l),'Threshold','0.5');
                end
            end

            currData=struct('injRefHdl',injRefHdl,'injMdlHdl',injMdlHdl,'injSSHdl',injSSHdl,'injSSNewHdl',injSSNewHdl,...
            'nInjIn',nInjIn,'nInjOut',nInjOut,'injInDsts',{injInDsts},'injOutSrcs',injOutSrcs,'injPtDsts',{injPtDsts},...
            'accPts',accPts,'injPts',injPts,'trigPt',trigPt,'constBlk',constBlk,'relOpBlk',relOpBlk,'orBlk',orBlk,...
            'unitDelayBlk',unitDelayBlk,'clockBlk',clockBlk,'switchBlks',switchBlks);
            injSSData=[injSSData;currData];%#ok<AGROW>
        end
    end

    if operation==0
        cachedInjectorData=injSSData;
    end
    injSSData=[];

end

function blkH=addBlockWithRandomName(blockName,injSSNewName)

    suffix=sprintf('%.12f',rand());
    blkH=add_block(['built-in/',blockName],[injSSNewName,'/',blockName,suffix],'MakeNameUnique','on');

end

function renameBlocks(injSSHdl)



    blks=find_system(injSSHdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    for j=1:numel(blks)
        suffix=sprintf('%.12f',rand());
        oldName=get_param(blks(j),'Name');
        set_param(blks(j),'Name',[oldName,suffix]);
    end

end

function bindHMI(blkH,constBlk)

    suffix=sprintf('%.12f',rand());
    varName=['Const',suffix(3:end)];
    assignin('base',varName,0);
    set_param(constBlk,'Value',varName);
    paramBinding=Simulink.HMI.ParamSourceInfo;
    paramBinding.VarName=varName;
    paramBinding.WksType='base';
    paramBinding.BlockPath=Simulink.BlockPath(getfullname(constBlk));
    set_param(getfullname(blkH),'Binding',paramBinding);

end




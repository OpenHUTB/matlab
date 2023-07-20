function setupAndInitModel(this,configManager)





    startNodeName=this.SimulinkConnection.System;
    modelName=this.SimulinkConnection.ModelName;
    hdldisp(sprintf('Begin PIR Model Setup and Initialization for : %s',startNodeName),3);


    if strcmp(hdlgetparameter('SubsystemReuse'),'Atomic and Virtual')


        updateBlocksWithHDLImplParams(this,startNodeName,configManager,@setupHDLParams);


        this.SimulinkConnection.initModel;


        tmp=this.SimulinkConnection.Model.getCompiledBlockList;
        nameChecksums=HDLComputeSSChecksumMex(tmp(1));


        checkNetworkReuse(this,startNodeName,modelName,configManager,nameChecksums);


        computeCheckSumForTheModel(this);


        updateBlocksWithHDLImplParams(this,startNodeName,configManager,@cleanupHDLParams);

    else

        handleReusable=findReusableSubsystems(this,startNodeName);

        incrForTop=incrementalcodegen.IncrementalCodeGenDriver.topModelPredicate(bdroot(startNodeName));
        gp=pir;
        guidedRetiming=this.HDLCoder.resolveGuidedRetiming(gp);

        compilechanged=strcmp(hdlgetparameter('compilestrategy'),'CompileChanged');
        needStructuralChecksum=handleReusable||incrForTop||guidedRetiming||compilechanged;
        if(needStructuralChecksum)

            updateBlocksWithHDLImplParams(this,startNodeName,configManager,@setupHDLParams);
        end


        this.SimulinkConnection.initModel;

        if(needStructuralChecksum)


            computeCheckSumForTheModel(this);


            updateBlocksWithHDLImplParams(this,startNodeName,configManager,@cleanupHDLParams);
        end

    end



    this.ReusedSSBlks=containers.Map;

end


function computeCheckSumForTheModel(this)

    if this.HandleReusableSubsystem&&strcmp(hdlgetparameter('subsystemreuse'),'Atomic and Virtual')

        reusable_blks=this.ReusableSSBlks;
        if~isempty(reusable_blks)

            csMap=containers.Map;
            this.CheckSumInfo=csMap;

            for ii=1:height(reusable_blks)
                key=getfullname(reusable_blks.name{ii});
                csMap(key)=reusable_blks.checksum{ii};
            end



            this.CheckSumNtwkMap=containers.Map;
        end

    elseif this.HandleReusableSubsystem

        reusable_blks=this.ReusableSSBlks;
        if~isempty(reusable_blks)

            actives=logical(reusable_blks);
            for ii=1:length(reusable_blks)
                variantInfo=get_param(reusable_blks(ii),'CompiledVariantInfo');
                if strcmp(variantInfo.IsActive,'off')
                    actives(ii)=false;
                end
            end
            reusable_blks=reusable_blks(actives);
            this.ReusableSSBlks=reusable_blks;


            csInfo=get_param(reusable_blks,'StructuralChecksum');


            csMap=containers.Map;
            this.CheckSumInfo=csMap;

            for ii=1:length(reusable_blks)
                h=reusable_blks(ii);

                if strcmp(get_param(h,'Permissions'),'ReadOnly')
                    this.NoReuseReadOnlySubsystems=[h,this.NoReuseReadOnlySubsystems];
                    continue;
                end

                if iscell(csInfo)
                    csi=csInfo{ii};
                else
                    csi=csInfo;
                end

                if~csi.MarkedUnique


                    cs=csi.Value;


                    csMap(getfullname(h))=[int2str(cs(1)),int2str(cs(2)),...
                    int2str(cs(3)),int2str(cs(4))];
                end
            end



            this.CheckSumNtwkMap=containers.Map;
        end

    end


    this.ModelCheckSum=get_param(bdroot(this.SimulinkConnection.System),...
    'StructuralChecksum');
end


function handleReusable=findReusableSubsystems(this,startNodeName)

    atomic_ss_blocks=findActiveBlocks(get_param(startNodeName,'handle'),...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'TreatAsAtomicUnit','on',...
    'LinkData','',...
    'BlockType','SubSystem',...
    'CompiledIsActive','on');

    if hdlgetparameter('maskparameterasgeneric')

        this.ReusableSSBlks=atomic_ss_blocks;
    else


        for ii=1:numel(atomic_ss_blocks)
            atomic_ss=atomic_ss_blocks(ii);


            if strcmp(get_param(atomic_ss,'Mask'),'on')
                tunableParams=get_param(atomic_ss,'MaskTunableValues');
                if any(strcmp(tunableParams,'on'))
                    continue;
                end
            end


            if isempty(this.ReusableSSBlks)
                this.ReusableSSBlks=atomic_ss;
            else
                this.ReusableSSBlks(end+1)=atomic_ss;
            end
        end
    end



    handleReusable=~isempty(this.ReusableSSBlks)&&...
    strcmp(hdlgetparameter('subsystemreuse'),'Atomic only');




    if handleReusable&&numel(this.ReusableSSBlks)>1&&...
        ~strcmp(get_param(this.HDLCoder.ModelName,'InlineParams'),'on')
        if hdlcoderui.isSimulinkCoderInstalled
            inline_param_msg=message('hdlcoder:validate:optDefaultParamBehaviorName').getString();
            msgobj=message('hdlcoder:engine:ReuseRequiresInvariantConstants',...
            inline_param_msg);
        else
            msgobj=message('hdlcoder:engine:ReuseRequiresInlineParams');
        end
        this.updateChecks(startNodeName,'model',msgobj,'Warning');
        handleReusable=false;
    end

    this.HandleReusableSubsystem=handleReusable;

end



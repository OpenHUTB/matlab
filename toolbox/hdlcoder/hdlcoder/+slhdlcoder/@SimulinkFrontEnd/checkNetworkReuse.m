function checkNetworkReuse(this,startNodeName,modelName,configManager,nameChecksums)






    nameChecksums=pruneNonExistentBlocks(nameChecksums);

    nameChecksums=pruneReadOnlyBlocks(this,nameChecksums);


    hdlChecksumTable=struct2table(nameChecksums,'AsArray',true);
    hdlChecksumTable.checksum=join(string(hdlChecksumTable.checksum),2);
    hdlChecksumTable=sortrows(hdlChecksumTable,{'checksum','name'});


    this.NoReuseInlineParamsOff=false;
    this.NoReuseTunableMaskParams=[];


    clones=findDup(hdlChecksumTable);
    if isempty(clones)
        noCloneFound(this);
        return
    end


    hdlChecksumTable=hdlChecksumTable(startsWith(hdlChecksumTable.name,startNodeName),:);


    hdlChecksumTable=checkInlineParams(this,hdlChecksumTable,modelName,startNodeName);


    hdlChecksumTable=keepDuplicatesOnly(hdlChecksumTable);


    hdlChecksumTable=removeRecurseSubsystems(hdlChecksumTable,configManager);


    hdlChecksumTable=excludeTunableMaskedParameters(this,hdlChecksumTable,startNodeName);


    hdlChecksumTable=removeConditionalSubsystems(hdlChecksumTable,startNodeName);




    hdlChecksumTable=keepDuplicatesOnly(hdlChecksumTable);


    if~isempty(hdlChecksumTable)
        this.ReusableSSBlks=hdlChecksumTable;
        this.HandleReusableSubsystem=true;
    else
        noCloneFound(this);
    end


    updateNoReuseTunableMaskParams(this);

end

function nameChecksums_out=pruneNonExistentBlocks(nameChecksums)
    blockHandles=getSimulinkBlockHandle({nameChecksums.name});
    nameChecksums_out=nameChecksums(blockHandles>0);
end

function nameChecksums_out=pruneReadOnlyBlocks(this,nameChecksums)
    blockHandles=getSimulinkBlockHandle({nameChecksums.name});
    check=logical(blockHandles);
    for ii=1:length(blockHandles)
        h=blockHandles(ii);

        if strcmp(get_param(h,'BlockType'),'SubSystem')&&...
            strcmp(get_param(h,'Permissions'),'ReadOnly')

            this.NoReuseReadOnlySubsystems=[h,this.NoReuseReadOnlySubsystems];
            check(ii)=false;
        end
    end
    nameChecksums_out=nameChecksums(check);
end

function noCloneFound(this)
    this.ReusableSSBlks={};
    this.HandleReusableSubsystem=false;
end

function clones=findDup(mytable)
    if isempty(mytable)
        clones=[];
        return;
    end


    [~,ia,~]=unique(mytable.checksum);
    ia=vertcat(ia,length(mytable.checksum)+1);

    clones={};
    for i=2:length(ia)
        a=ia(i-1);
        b=ia(i);
        if b-a>1
            clones{end+1}=mytable.name(a:(b-1));
        end
    end
end

function updateNoReuseTunableMaskParams(this)


    this.NoReuseTunableMaskParams=keepDuplicatesOnly(this.NoReuseTunableMaskParams);
end

function newtable=removeRecurseSubsystems(mytable,configManager)
    if isempty(mytable)
        newtable=[];
        return;
    end


    recurseSS={};
    recurseSSIdx=false(height(mytable),1);

    SSnames=mytable.name;
    for k=1:length(SSnames)
        impl=configManager.getImplementationForBlock(SSnames{k});
        if slhdlcoder.SimulinkFrontEnd.isIPBlockRecurseSS(impl)
            recurseSS{end+1}=SSnames{k};
            recurseSSIdx(k)=true;
        end
    end


    recurseNestedSSIdx=false(height(mytable),1);
    for i=1:length(recurseSS)
        re=startsWith(SSnames,recurseSS{i});
        recurseNestedSSIdx=recurseNestedSSIdx|re;
    end



    newtable=mytable(~xor(recurseNestedSSIdx,recurseSSIdx),:);
end

function newtable=excludeTunableMaskedParameters(this,mytable,startNodeName)
    if isempty(mytable)
        newtable=[];
        return;
    end


    if hdlgetparameter('maskparameterasgeneric')
        newtable=mytable;
        return;
    end






    ss_blocks=find_system(get_param(startNodeName,'handle'),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'LinkData','',...
    'BlockType','SubSystem',...
    'CompiledIsActive','on');

    SSnames=mytable.name;
    exclubits=false(numel(SSnames),1);
    for ii=1:numel(ss_blocks)
        ss=ss_blocks(ii);


        if strcmp(get_param(ss,'Mask'),'on')
            tunableParams=get_param(ss,'MaskTunableValues');
            if any(strcmp(tunableParams,'on'))

                n=strrep(getfullname(ss),newline,' ');
                exclubits=exclubits|strcmp(n,SSnames);
            end
        end
    end


    this.NoReuseTunableMaskParams=mytable(exclubits,:);


    newtable=mytable(~exclubits,:);
end

function newtable=checkInlineParams(this,mytable,modelName,startNodeName)
    if isempty(mytable)
        newtable=[];
        return;
    end



    if~strcmp(get_param(modelName,'InlineParams'),'on')
        if hdlcoderui.isSimulinkCoderInstalled
            inline_param_msg=message('hdlcoder:validate:optDefaultParamBehaviorName').getString();
            msgobj=message('hdlcoder:engine:ReuseRequiresInvariantConstants',...
            inline_param_msg);
        else
            msgobj=message('hdlcoder:engine:ReuseRequiresInlineParams');
        end
        this.updateChecks(startNodeName,'model',msgobj,'Warning');

        newtable=[];
        this.NoReuseInlineParamsOff=true;
    else
        newtable=mytable;
    end
end

function newtable=removeConditionalSubsystems(mytable,startNodeName)




    if isempty(mytable)
        newtable=[];
        return;
    end



    enbblk=find_system(get_param(startNodeName,'handle'),'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','EnablePort');
    trgblk=find_system(get_param(startNodeName,'handle'),'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','TriggerPort');
    rstblk=find_system(get_param(startNodeName,'handle'),'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','ResetPort');
    condBlocks=strrep(getfullname([enbblk;trgblk;rstblk]),newline,' ');
    if~iscell(condBlocks)
        condBlocks={condBlocks};
    end

    if isempty(condBlocks)
        newtable=mytable;
        return;
    end



    condSSIdx=false(height(mytable),1);
    for k=1:length(condBlocks)


        CBparent=get_param(condBlocks{k},'parent');
        if isempty(CBparent)
            continue;
        end
        mask=startsWith(mytable.name,CBparent);

        grps=findgroups(mytable.checksum);
        grps(~mask)=0;





        uaa=unique(grps(mask));
        for l=1:length(uaa)
            bb=grps==uaa(l);
            if sum(bb)==1
                condSSIdx=condSSIdx|bb;
            elseif sum(bb)>1
                newchk=mytable.checksum(bb)+sprintf(" %d%d",k,l);
                mytable.checksum(bb)=newchk;
            end
        end
    end

    newtable=mytable(~condSSIdx,:);
end

function newtable=keepDuplicatesOnly(mytable)
    if isempty(mytable)
        newtable=[];
        return;
    end

    groups=findgroups(mytable.checksum);
    clonesIdx=false(height(mytable),1);
    for ii=1:max(groups)
        cc=groups==ii;
        if sum(cc)>1
            clonesIdx=clonesIdx|cc;
        end
    end
    newtable=mytable(clonesIdx,:);
end



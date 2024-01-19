function varargout=vnv_assert_mgr(method,objHandle,varargin)

    persistent RefreshEnabled;

    if isempty(RefreshEnabled)
        RefreshEnabled=true;
    end

    if strcmp(method(1:3),'mdl')
        modelH=objHandle;
        blockH=[];
        if(util_is_library(modelH))
            return;
        end
    else
        blockH=objHandle;
        modelH=bdroot(blockH);
    end

    mdlInfoStruct=get_param(modelH,'VnvToolData');
    if isempty(mdlInfoStruct)
        mdlInfoStruct=create_mdl_info(modelH);
    end

    switch(method)
    case 'disableRefresh'
        RefreshEnabled=false;
        return;
    case 'enableRefresh'
        RefreshEnabled=true;
        return;

    case 'mdlPostLoad'
        preserve_dirty_flag=Simulink.PreserveDirtyFlag(...
        mdlInfoStruct.modelH,'blockDiagram');
        mdlInfoStruct=mdl_refresh_sigbuild_list(mdlInfoStruct);
        mdlInfoStruct=mdl_post_load(mdlInfoStruct);
        set_param(modelH,'VnvDirty','on');

        delete(preserve_dirty_flag);

    case 'mdlPostLoadSigb'
        mdlInfoStruct=mdl_post_load_sigb(mdlInfoStruct);

    case 'mdlPreSave'

        if isempty(mdlInfoStruct.sigbuildHandles)
            return;
        end
        mdlInfoStruct=mdl_pre_save(mdlInfoStruct);
        set_param(modelH,'VnvDirty','on');

    case 'mdlInit'
        if~isempty(mdlInfoStruct.sigbuildHandles)
            mdlInfoStruct=mdl_force_update_if_needed(mdlInfoStruct);
        end
        mdl_update_primitive_asserts(mdlInfoStruct);

    case 'mdlReloadAsserts'

        mdlInfoStruct=mdl_refresh_all(mdlInfoStruct);
        mdlInfoStruct=mdl_update_display_info(mdlInfoStruct);
        set_param(modelH,'VnvDirty','off');

    case 'mdlForceRefresh'

        if RefreshEnabled
            for blkH=mdlInfoStruct.sigbuildHandles
                vnv_panel_mgr('sbForceRefresh',blkH);
            end
        end

    case 'mdlVnvDirty'

        for blkH=mdlInfoStruct.sigbuildHandles
            vnv_panel_mgr('sbEnableRefresh',blkH);
        end

    case 'sbBlkLoad'
        if~ismember(blockH,mdlInfoStruct.sigbuildHandles)
            mdlInfoStruct.sigbuildHandles(end+1)=blockH;
        else
            return;
        end

    case 'sbBlkCopy'

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo)
            blkInfo=create_blk_info(blockH,mdlInfoStruct.modelH);
        else
            if(blkInfo.modelH==modelH)
                mdlInfoStruct=sigb_add_overide_counts(mdlInfoStruct,blkInfo);
                blkInfo.blockH=blockH;
            else
                origGrpReqCnts=[];
                if isfield(blkInfo,'groupReqCnt')...
                    &&~isempty(blkInfo.groupReqCnt)...
                    &&~rmidata.isExternal(modelH)
                    origGrpReqCnts=blkInfo.groupReqCnt;
                end
                blkInfo=create_blk_info(blockH,mdlInfoStruct.modelH);
                if~isempty(origGrpReqCnts)
                    blkInfo.groupReqCnt=origGrpReqCnts;
                end
            end
        end
        if isempty(blkInfo.groupCnt)
            blkInfo=sigb_update_group_info(blkInfo);
        end
        mdlInfoStruct.sigbuildHandles(end+1)=blockH;
        sigb_write_info(blkInfo);

    case 'sbBlkDelete'

        blkInfo=sigb_get_info(blockH);
        origOveride=mdlInfoStruct.overideCnts;
        mdlInfoStruct=sigb_subtract_overide_counts(mdlInfoStruct,blkInfo);
        sigbuilds=mdlInfoStruct.sigbuildHandles;
        sigbuilds(sigbuilds==blockH)=[];
        mdlInfoStruct.sigbuildHandles=sigbuilds;
        update_changed_blocks(mdlInfoStruct,origOveride)

    case 'sbBlkGroupChange'
        vnv_assert_mgr('disableRefresh',blockH);
        newGroupIdx=varargin{1};
        mdlInfoStruct=sigb_group_change(mdlInfoStruct,blockH,newGroupIdx);
        vnv_assert_mgr('enableRefresh',blockH);

    case 'sbBlkGroupAdd'

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
            blkInfo=sigb_update_group_info(blkInfo);
            sigb_write_info(blkInfo);
            return;
        end

        if util_is_library(mdlInfoStruct.modelH)
            blkInfo.blockH=blockH;
            blkInfo.modelH=mdlInfoStruct.modelH;
        end

        newIdx=varargin{1};
        origIdx=1:(blkInfo.groupCnt);
        remapIndex=origIdx+(origIdx>newIdx);
        blkInfo.groupCnt=blkInfo.groupCnt+1;
        blkInfo=sigb_remap_groups(blkInfo,remapIndex,origIdx);
        sigb_write_info(blkInfo);

    case 'sbBlkUpdateGroupInfo'
        blkInfo=sigb_get_info(blockH);
        blkInfo=sigb_update_group_info(blkInfo);
        sigb_write_info(blkInfo);
        return;

    case 'sbBlkGroupDelete'

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
            blkInfo=sigb_update_group_info(blkInfo);
            sigb_write_info(blkInfo);
            return;
        end

        if util_is_library(mdlInfoStruct.modelH)
            blkInfo.blockH=blockH;
            blkInfo.modelH=mdlInfoStruct.modelH;
        end

        deleteIdx=varargin{1};
        origIdx=1:(blkInfo.groupCnt);
        origIdx(deleteIdx)=[];
        blkInfo.groupCnt=blkInfo.groupCnt-1;
        newIdx=1:(blkInfo.groupCnt);
        blkInfo=sigb_remap_groups(blkInfo,newIdx,origIdx,deleteIdx);
        sigb_write_info(blkInfo);

    case 'sbBlkGroupMove'

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
            blkInfo=sigb_update_group_info(blkInfo);
            sigb_write_info(blkInfo);
            return;
        end

        if util_is_library(mdlInfoStruct.modelH)
            blkInfo.blockH=blockH;
            blkInfo.modelH=mdlInfoStruct.modelH;
        end

        old2newIdx=varargin{1};
        newGroupIdx=varargin{2};
        origIdx=1:(blkInfo.groupCnt);

        blkInfo.activeGroup=newGroupIdx;

        blkInfo=sigb_remap_groups(blkInfo,old2newIdx,origIdx);
        sigb_write_info(blkInfo);

    case 'sbGetDoorsLabel'
        if util_is_a_link(blockH)
            varargout{1}=[];
            return
        end

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo)
            blkInfo=create_blk_info(blockH,mdlInfoStruct.modelH);
        else

            if util_is_library(mdlInfoStruct.modelH)
                blkInfo.blockH=blockH;
                blkInfo.modelH=mdlInfoStruct.modelH;
            end

            if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
                blkInfo=sigb_update_group_info(blkInfo);
            end
        end

        if isempty(blkInfo.groupDOORSid)
            blkInfo.groupDOORSid=cell(1,blkInfo.groupCnt);
            if~util_is_library(mdlInfoStruct.modelH)||...
                strcmp(get_param(mdlInfoStruct.modelH,'Lock'),'off')
                sigb_write_info(blkInfo);
            end
        end

        if nargin>3
            idx=varargin{2};
            varargout{1}=blkInfo.groupDOORSid{idx};
        else
            varargout{1}=blkInfo.groupDOORSid;
        end

    case 'sbSetDoorsLabel'
        if util_is_a_link(blockH)
            return;
        end

        blkInfo=sigb_get_info(blockH);
        if isempty(blkInfo)
            blkInfo=create_blk_info(blockH,mdlInfoStruct.modelH);
        else

            if util_is_library(mdlInfoStruct.modelH)
                blkInfo.blockH=blockH;
                blkInfo.modelH=mdlInfoStruct.modelH;
            end

            if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
                blkInfo=sigb_update_group_info(blkInfo);
            end
        end

        if isempty(blkInfo.groupDOORSid)
            blkInfo.groupDOORSid=cell(1,blkInfo.groupCnt);
        end

        if nargin>3
            idx=varargin{2};
            blkInfo.groupDOORSid{idx}=varargin{1};
        else
            blkInfo.groupDOORSid=varargin{1};
        end

        if util_is_library(mdlInfoStruct.modelH)&&...
            strcmp(get_param(mdlInfoStruct.modelH,'Lock'),'on')
            return;
        end

        sigb_write_info(blkInfo);

    case 'sbAssertHier'
        varargout{1}=mdlInfoStruct.dispHierarchy;
        varargout{2}=mdlInfoStruct.dispDepth;
        varargout{3}=(mdlInfoStruct.dispAssertIdx~=-1);
        varargout{4}=mdlInfoStruct.assertHandles;

    case 'sbGroupValues'

        blkInfo=sigb_get_info(blockH);

        visibleBlocks=mdlInfoStruct.parentMasks;
        primBlks=(visibleBlocks==-1);
        visibleBlocks(primBlks)=mdlInfoStruct.assertHandles(primBlks);
        staticEnabled=strcmp(get_param(visibleBlocks,'Enabled'),'on');
        groupValue=zeros(1,length(primBlks));

        if~isempty(blkInfo.vnvMgrIdx)
            groupValue(blkInfo.vnvMgrIdx)=...
            blkInfo.overideSettings(:,blkInfo.activeGroup);
        end

        varargout{1}=mdlInfoStruct.assertDispIdx;
        varargout{2}=staticEnabled;
        varargout{3}=groupValue;

    case 'sbBlkEdit'

        visibleBlkH=varargin{1};
        newValue=varargin{2};
        blkInfo=sigb_get_info(blockH);
        [mdlInfoStruct,blkInfo]=sigb_assert_set(mdlInfoStruct,blkInfo,visibleBlkH,newValue);
        sigb_write_info(blkInfo);

    case 'asBlkHasOveride'
        out=assert_mask_has_overide(mdlInfoStruct,blockH);
        varargout{1}=out;

    case 'asBlkIsOveride'
        out=assert_mask_is_overide(mdlInfoStruct,blockH);
        varargout{1}=out;

    otherwise
    end
    if(util_is_library(mdlInfoStruct.modelH))
        return;
    end
    set_param(modelH,'VnvToolData',mdlInfoStruct);

end


function mdl_update_primitive_asserts(mdlInfoStruct)

    handleVect=mdlInfoStruct.assertHandles;
    overideFlags=(mdlInfoStruct.overideCnts>0);
    isPrimitive=(mdlInfoStruct.parentMasks==-1);
    isvalid=ishandle(handleVect);
    isvalid=isvalid&isPrimitive;
    handleVect(~isvalid)=[];
    overideFlags(~isvalid)=[];

    if isempty(overideFlags)
        return;
    end

    for i=1:length(handleVect)
        if(overideFlags(i))
            set_param(handleVect(i),'Overide','on');
        else
            set_param(handleVect(i),'Overide','off');
        end
    end
end


function mdlInfoStruct=sigb_add_overide_counts(mdlInfoStruct,blkInfo,ignoreTot)
    if isempty(blkInfo)||isempty(blkInfo.overideSettings)
        return;
    end

    if nargin<3
        ignoreTot=0;
    end

    blkGroupOverides=blkInfo.overideSettings(:,blkInfo.activeGroup);

    delta=zeros(1,length(mdlInfoStruct.overideCnts));
    delta(blkInfo.vnvMgrIdx)=blkGroupOverides;

    mdlInfoStruct.overideCnts=mdlInfoStruct.overideCnts+delta;

    if~ignoreTot
        delta(blkInfo.vnvMgrIdx)=sum(blkInfo.overideSettings,2);
        mdlInfoStruct.crossGroupCnts=mdlInfoStruct.crossGroupCnts+delta;
    end
end


function mdlInfoStruct=sigb_subtract_overide_counts(mdlInfoStruct,blkInfo,ignoreTot)
    if isempty(blkInfo)||isempty(blkInfo.overideSettings)
        return;
    end

    if nargin<3
        ignoreTot=0;
    end

    blkGroupOverides=blkInfo.overideSettings(:,blkInfo.activeGroup);
    delta=zeros(1,length(mdlInfoStruct.overideCnts));
    delta(blkInfo.vnvMgrIdx)=blkGroupOverides;

    mdlInfoStruct.overideCnts=mdlInfoStruct.overideCnts-delta;

    if~ignoreTot
        delta(blkInfo.vnvMgrIdx)=sum(blkInfo.overideSettings,2);
        mdlInfoStruct.crossGroupCnts=mdlInfoStruct.crossGroupCnts-delta;
    end
end


function reqOffset=util_req_cnts_to_offset(reqCnts)
    reqOffset=[1,1+cumsum(reqCnts(1:(end-1)))];
end


function blkInfo=sigb_remap_groups(blkInfo,remapIndex,origIdx,deletedGrp)
    grpCnt=blkInfo.groupCnt;
    if~isempty(blkInfo.overideSettings)
        [existRows,~]=size(blkInfo.overideSettings);
        overideSettings=zeros(existRows,grpCnt);
        overideSettings(:,remapIndex)=blkInfo.overideSettings(:,origIdx);
        blkInfo.overideSettings=overideSettings;
    end

    if rmidata.isExternal(blkInfo.modelH)
        if rmidata.bdHasExternalData(blkInfo.modelH,true)

            if nargin==4
                sigb_group_delete_external(blkInfo.blockH,deletedGrp);
            else
                sigb_group_remap_external(blkInfo.blockH,remapIndex);
            end
        end

    elseif~isempty(blkInfo.groupReqCnt)
        reqCnt=blkInfo.groupReqCnt;
        reqOffset=util_req_cnts_to_offset(reqCnt);
        oldReqCnt=sum(reqCnt);
        newReqCnt=zeros(1,grpCnt);
        oldOffset=zeros(1,grpCnt);
        newReqCnt(remapIndex)=reqCnt(origIdx);
        oldOffset(remapIndex)=reqOffset(origIdx);

        remapIdx=[];
        for idx=1:grpCnt
            if newReqCnt(idx)>=1
                remapIdx=[remapIdx,(1:newReqCnt(idx))+oldOffset(idx)-1];
            end
        end

        blkInfo.groupReqCnt=newReqCnt;

        if~isequal(remapIdx,1:oldReqCnt)
            if(length(remapIdx)<oldReqCnt)

                rmi('set',blkInfo.blockH,[],deletedGrp);
            else

                sigb_write_info(blkInfo);
                rmi('permute',blkInfo.blockH,remapIdx);
            end
        end
    end
end


function sigb_group_remap_external(sigbH,remapIndex)
    slreq.remapSigbGroups(sigbH,remapIndex);
end


function sigb_group_delete_external(sigbH,deletedGroup)
    [groupReqCnt,origGroups]=slreq.getSigbGrpData(sigbH,true);

    if any(origGroups==deletedGroup)
        slreq.setReqs(sigbH,[],deletedGroup);
    end

    if deletedGroup<length(groupReqCnt)&&any(origGroups>deletedGroup)
        remapIdx=1:length(groupReqCnt);
        remapIdx(deletedGroup)=[];
        slreq.remapSigbGroups(sigbH,remapIdx);
    end
end


function mdlInfoStruct=sigb_group_change(mdlInfoStruct,blockH,newGroupIdx)

    if util_is_library(mdlInfoStruct.modelH)
        return;
    end

    origOveride=mdlInfoStruct.overideCnts;
    blkInfo=sigb_get_info(blockH);
    mdlInfoStruct=sigb_subtract_overide_counts(mdlInfoStruct,blkInfo,1);
    blkInfo.activeGroup=newGroupIdx;
    mdlInfoStruct=sigb_add_overide_counts(mdlInfoStruct,blkInfo,1);
    sigb_write_info(blkInfo);

    update_changed_blocks(mdlInfoStruct,origOveride);
end


function update_changed_blocks(mdlInfoStruct,origOveride)
    displayChanged=find((origOveride~=0)~=(mdlInfoStruct.overideCnts~=0));
    if~isempty(displayChanged)

        set_param(mdlInfoStruct.modelH,'VnvToolData',mdlInfoStruct);
        for idx=displayChanged
            maskH=mdlInfoStruct.parentMasks(idx);
            primH=mdlInfoStruct.assertHandles(idx);
            overide=mdlInfoStruct.overideCnts(idx)~=0;
            try
                util_update_mask(maskH,primH,overide);
            catch UpdateMaskEx
            end
        end
    end
end


function mdlInfoStruct=mdl_post_load(mdlInfoStruct)

    sigbuildH=mdlInfoStruct.sigbuildHandles;
    if isempty(sigbuildH)
        return;
    end

    if isfield(mdlInfoStruct,'initialized')&&mdlInfoStruct.initialized
        return;
    end

    for blkH=sigbuildH
        blkInfo=sigb_get_info(blkH);
        if isempty(blkInfo)
            blkInfo=create_blk_info(blkH,mdlInfoStruct.modelH);
        else
            blkInfo.blockH=blkH;
            blkInfo.modelH=mdlInfoStruct.modelH;
            if~isempty(blkInfo.verifyBlkPaths)
                blkInfo=sigb_prune_stale_asserts(blkInfo);
            end
        end
        sigb_write_info(blkInfo);
    end

    if isempty(sigbuildH)
        return;
    end

    allBlocks=[];
    for blkH=mdlInfoStruct.sigbuildHandles
        blkInfo=sigb_get_info(blkH);
        if~isempty(blkInfo.verifyBlkHandles)
            allBlocks=union(allBlocks,blkInfo.verifyBlkHandles);
        end
    end

    if isempty(allBlocks)
        return;
    end

    allBlocks=allBlocks(:)';

    mdlInfoStruct.assertHandles=allBlocks;
    mdlInfoStruct.parentMasks=assert_parent_masks(allBlocks);
    mdlInfoStruct.overideCnts=zeros(1,length(allBlocks));
    mdlInfoStruct.crossGroupCnts=zeros(1,length(allBlocks));

    for sigBuildH=mdlInfoStruct.sigbuildHandles
        blkInfo=sigb_get_info(sigBuildH);
        if~isempty(blkInfo.verifyBlkHandles)
            [common,vnvMgrIdx,transformMap]=intersect(allBlocks,...
            blkInfo.verifyBlkHandles);
            if(length(common)~=length(blkInfo.verifyBlkHandles))
                error(message('Slvnv:vnv_assert_mgr:UnableToFindBlockIndice'));
            end
            blkInfo.verifyBlkHandles=common;
            blkInfo.vnvMgrIdx=vnvMgrIdx;
            blkInfo.overideSettings=blkInfo.overideSettings(transformMap,:);
            sigb_write_info(blkInfo);
            mdlInfoStruct=sigb_add_overide_counts(mdlInfoStruct,blkInfo);
        end
    end

    mdlInfoStruct.initialized=true;
end


function mdlInfoStruct=mdl_post_load_sigb(mdlInfoStruct)
    preserve_dirty_flag=Simulink.PreserveDirtyFlag(...
    mdlInfoStruct.modelH,'blockDiagram');

    for blkH=mdlInfoStruct.sigbuildHandles
        blkInfo=sigb_get_info(blkH);
        if isempty(blkInfo)
            blkInfo=create_blk_info(blkH,mdlInfoStruct.modelH);
        else
            blkInfo.blockH=blkH;
            blkInfo.modelH=mdlInfoStruct.modelH;
        end
        sigb_write_info(blkInfo);
    end

    delete(preserve_dirty_flag);
end


function mdlInfoStruct=mdl_pre_save(mdlInfoStruct)
    mdlInfoStruct=mdl_force_update_if_needed(mdlInfoStruct);

    if isempty(mdlInfoStruct.sigbuildHandles)
        return;
    end

    for i=length(mdlInfoStruct.sigbuildHandles):-1:1
        sigBuildH=mdlInfoStruct.sigbuildHandles(i);
        try
            blkInfo=sigb_get_info(sigBuildH);
        catch ex

            if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjSpecifier')
                mdlInfoStruct=mdl_refresh_all(mdlInfoStruct);
                mdlInfoStruct=mdl_update_display_info(mdlInfoStruct);
                set_param(mdlInfoStruct.modelH,'VnvToolData',mdlInfoStruct);
                mdlInfoStruct=mdl_pre_save(mdlInfoStruct);
                return;
            else
                rethrow(ex);
            end
        end
        removeIdx=~ishandle(blkInfo.verifyBlkHandles);
        blkInfo.verifyBlkHandles(removeIdx)=[];
        blkInfo.vnvMgrIdx(removeIdx)=[];
        blkInfo.overideSettings(removeIdx,:)=[];
        blkInfo.verifyBlkPaths=util_relative_full_names(blkInfo.verifyBlkHandles);
        sigb_write_info(blkInfo,true);
    end

    if isfield(mdlInfoStruct,'initialized')
        mdlInfoStruct=rmfield(mdlInfoStruct,'initialized');
    end
end


function mdlInfoStruct=mdl_refresh_all(mdlInfoStruct)
    mdlInfoStruct=mdl_refresh_sigbuild_list(mdlInfoStruct);
    needsRemap=~isempty(mdlInfoStruct.assertHandles);

    newAssertList=assert_find_blks(mdlInfoStruct.modelH);
    overideCnts=zeros(1,length(newAssertList));
    groupCnts=zeros(1,length(newAssertList));

    if needsRemap
        [~,newIdx,oldIdx]=intersect(newAssertList,mdlInfoStruct.assertHandles);

        remap=-1*ones(1,length(mdlInfoStruct.assertHandles));
        remap(oldIdx)=newIdx;

        overideCnts(newIdx)=mdlInfoStruct.overideCnts(oldIdx);
        groupCnts(newIdx)=mdlInfoStruct.crossGroupCnts(oldIdx);
    end

    mdlInfoStruct.assertHandles=newAssertList;
    mdlInfoStruct.parentMasks=assert_parent_masks(newAssertList);
    mdlInfoStruct.overideCnts=overideCnts;
    mdlInfoStruct.crossGroupCnts=groupCnts;

    if needsRemap
        mdlInfoStruct=sigb_transform_index(mdlInfoStruct,remap);
    end
end


function mdlInfoStruct=mdl_refresh_sigbuild_list(mdlInfoStruct)
    opts=Simulink.FindOptions('LoadFullyIfNeeded',false);
    opts.SkipLinks=true;
    sigbuildH=Simulink.findBlocksOfType(mdlInfoStruct.modelH,'SubSystem',...
    'PreSaveFcn','sigbuilder_block(''preSave'');',...
    opts);
    mdlInfoStruct.sigbuildHandles=sigbuildH(:)';
    preserve_dirty=Simulink.PreserveDirtyFlag(mdlInfoStruct.modelH,'blockDiagram');
    for blkH=sigbuildH
        if~util_is_a_link(blkH)
            blkInfo=sigb_get_info(blkH);
            if isempty(blkInfo)
                blkInfo=create_blk_info(blkH,mdlInfoStruct.modelH);
            else
                blkInfo.blockH=blkH;
                blkInfo.modelH=mdlInfoStruct.modelH;
                if~isempty(blkInfo.verifyBlkPaths)
                    blkInfo=sigb_prune_stale_asserts(blkInfo);
                end
            end
            sigb_write_info(blkInfo);
        end
    end
end


function mdlInfoStruct=mdl_force_update_if_needed(mdlInfoStruct)
    if~strcmp(get_param(mdlInfoStruct.modelH,'VnvDirty'),'on')
        return;
    end
    mdlInfoStruct=mdl_refresh_all(mdlInfoStruct);
    mdlInfoStruct=mdl_update_display_info(mdlInfoStruct);
    set_param(mdlInfoStruct.modelH,'VnvDirty','off');
    set_param(mdlInfoStruct.modelH,'VnvToolData',mdlInfoStruct);


    for blkH=mdlInfoStruct.sigbuildHandles
        vnv_panel_mgr('sbForceRefresh',blkH);
    end
end


function blkInfo=sigb_prune_stale_asserts(blkInfo)

    modelName=get_param(blkInfo.modelH,'Name');
    handles=util_relative_paths_2_handles(modelName,blkInfo.verifyBlkPaths);
    removeFlag=(handles==-1);
    handles(removeFlag)=[];
    blkInfo.verifyBlkHandles=handles;
    blkInfo.overideSettings(removeFlag,:)=[];
    blkInfo.verifyBlkPaths(removeFlag)=[];
    blkInfo.vnvMgrIdx(removeFlag)=[];
end


function[mdlInfoStruct,blkInfo]=sigb_assert_set(mdlInfoStruct,blkInfo,visibleH,newValue)

    if isempty(blkInfo.activeGroup)||isempty(blkInfo.groupCnt)
        blkInfo=sigb_update_group_info(blkInfo);
    end
    thisIdx=find(visibleH==mdlInfoStruct.assertHandles);
    primitiveH=visibleH;
    if isempty(thisIdx)
        thisIdx=find(primitiveH==mdlInfoStruct.parentMasks);
        primitiveH=mdlInfoStruct.assertHandles(thisIdx);
    end
    overideRow=find(thisIdx==blkInfo.vnvMgrIdx);
    groupIdx=blkInfo.activeGroup;
    updateIcon=-1;

    if isempty(overideRow)
        if isempty(blkInfo.overideSettings)
            blkInfo.overideSettings=zeros(1,blkInfo.groupCnt);
            overideRow=1;
        else
            [rowCnt,colCnt]=size(blkInfo.overideSettings);
            overideRow=rowCnt+1;
            blkInfo.overideSettings(rowCnt+1,:)=zeros(1,colCnt);
        end
        blkInfo.verifyBlkHandles(overideRow)=primitiveH;
        blkInfo.vnvMgrIdx(overideRow)=thisIdx;
    end
    if(blkInfo.overideSettings(overideRow,groupIdx)==newValue)

    else
        blkInfo.overideSettings(overideRow,groupIdx)=newValue;
        if(newValue)
            mdlInfoStruct.overideCnts(thisIdx)=...
            mdlInfoStruct.overideCnts(thisIdx)+1;
            mdlInfoStruct.crossGroupCnts(thisIdx)=...
            mdlInfoStruct.crossGroupCnts(thisIdx)+1;
            if mdlInfoStruct.overideCnts(thisIdx)==1
                updateIcon=1;
            end
        else
            mdlInfoStruct.overideCnts(thisIdx)=...
            mdlInfoStruct.overideCnts(thisIdx)-1;
            mdlInfoStruct.crossGroupCnts(thisIdx)=...
            mdlInfoStruct.crossGroupCnts(thisIdx)-1;
            if mdlInfoStruct.overideCnts(thisIdx)==0
                updateIcon=0;
            end
        end
    end

    if(updateIcon~=-1)

        set_param(mdlInfoStruct.modelH,'VnvToolData',mdlInfoStruct);
        util_update_mask(visibleH,primitiveH,newValue);
    end
end


function util_update_mask(maskBlockH,primitiveH,newValue)

    if(maskBlockH==-1||maskBlockH==primitiveH)
        if~util_is_implicit_link(primitiveH)

            if newValue
                set_param(primitiveH,'Overide','on');
            else
                set_param(primitiveH,'Overide','off');
            end
        end
    else
        if~util_is_implicit_link(maskBlockH)
            if strcmp(get_param(maskBlockH,'Enabled'),'off')

                set_param(maskBlockH,'Enabled','on')
                set_param(maskBlockH,'Enabled','off')
            end
        end
    end

end


function mdlInfoStruct=mdl_update_display_info(mdlInfoStruct)

    assertblkH=mdlInfoStruct.assertHandles;
    treeDispH=mdlInfoStruct.parentMasks;
    primitiveBlk=(treeDispH==-1);
    treeDispH(primitiveBlk)=assertblkH(primitiveBlk);
    [dispHierarchy,depth,dispAssertIdx]=util_block_list_tree(treeDispH);

    [idx,sortMap]=sort(dispAssertIdx);
    assertDispIdx=sortMap(idx~=-1);

    mdlInfoStruct.dispHierarchy=dispHierarchy;
    mdlInfoStruct.dispDepth=depth;
    mdlInfoStruct.dispAssertIdx=dispAssertIdx;
    mdlInfoStruct.assertDispIdx=assertDispIdx;
end



function mdlInfoStruct=create_mdl_info(modelH)

    sigbuildH=find_system(modelH,...
    'LoadFullyIfNeeded','off',...
    'FollowLinks','off',...
    'SkipLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','SubSystem',...
    'PreSaveFcn','sigbuilder_block(''preSave'');');
    sigbuildH=sigbuildH(:)';

    mdlInfoStruct=struct('assertHandles',[],...
    'modelH',modelH,...
    'parentMasks',[],...
    'overideCnts',[],...
    'crossGroupCnts',[],...
    'dispHierarchy',[],...
    'dispDepth',[],...
    'dispAssertIdx',[],...
    'assertDispIdx',[],...
    'sigbuildHandles',sigbuildH);
end


function blkInfo=create_blk_info(blockH,modelH)
    if nargin<2
        modelH=bdroot(blockH);
    end

    blkInfo=struct('verifyBlkPaths',[]...
    ,'verifyBlkHandles',[]...
    ,'vnvMgrIdx',[]...
    ,'activeGroup',[]...
    ,'reqDispPrcnt',[]...
    ,'blkDispMode',[]...
    ,'groupCnt',[]...
    ,'groupReqCnt',[]...
    ,'groupDOORSid',[]...
    ,'modelH',modelH...
    ,'blockH',blockH...
    ,'overideSettings',[]);
end


function blkInfo=sigb_update_group_info(blkInfo)
    [activeGroup,groupCnt]=sigbuilder('assertApi',blkInfo.blockH,'groupIndex');
    blkInfo.activeGroup=activeGroup;
    blkInfo.groupCnt=groupCnt;
end


function blkInfo=sigb_get_info(blkHandle)

    fromWsH=find_system(blkHandle,...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'IncludeCommented','on',...
    'BlockType','FromWorkspace');
    blkInfo=get_param(fromWsH,'VnvData');

    if~isempty(blkInfo)
        blkInfo.blockH=blkHandle;
        blkInfo.modelH=bdroot(blkHandle);
        if~isempty(blkInfo.activeGroup)&&isempty(blkInfo.groupCnt)

            [~,blkInfo.groupCnt]=sigbuilder('assertApi',blkHandle,'groupIndex');
        end
        if~isfield(blkInfo,'groupDOORSid')
            blkInfo.groupDOORSid=[];
        end
        if~isfield(blkInfo,'reqDispPrcnt')
            blkInfo.blkDispMode=[];
            blkInfo.reqDispPrcnt=[];
        end
    end
end


function sigb_write_info(blkInfo,shouldClearHandles)

    fromWsH=find_system(blkInfo.blockH,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on',...
    'BlockType','FromWorkspace');
    if~strcmp(get_param(fromWsH,'StaticLinkStatus'),'implicit')

        blkInfo.blockH=[];
        blkInfo.modelH=[];
        if nargin>1&&shouldClearHandles
            blkInfo.verifyBlkHandles=-ones(size(blkInfo.verifyBlkPaths));
        end
        if~isequal(get_param(fromWsH,'VnvData'),blkInfo)
            set_param(fromWsH,'VnvData',blkInfo);
        end
    end
end


function parentMasks=assert_parent_masks(assertBlks)
    masks=get_param(assertBlks,'ShadowObject');
    if iscell(masks)
        parentMasks=[masks{:}];
    else
        parentMasks=masks;
    end

    primIdx=(parentMasks==-1);
    if~isempty(primIdx)
        modelH=bdroot(assertBlks(1));
        mayBePrimitive=assertBlks(primIdx);
        parents=get_param(mayBePrimitive,'Parent');
        parentsH=get_param(parents,'Handle');

        if iscell(parentsH)
            parentsH=[parentsH{:}];
        end

        topLevel=(parentsH==modelH);
        if(length(find(~topLevel))==1)
            maskInitStrs(~topLevel)=...
            {get_param(parentsH(~topLevel),'MaskInitialization')};
        else
            maskInitStrs(~topLevel)=...
            get_param(parentsH(~topLevel),'MaskInitialization');
        end

        isMasked=strncmp(maskInitStrs,'update_assert_sys(gcbh);',17);
        if any(isMasked)
            parentsH(~isMasked)=-1;
            parentMasks(primIdx)=parentsH;
        end
    end

    parentMasks(parentMasks==assertBlks)=-1;
end


function blks=assert_find_blks(modelH)
    blks=[];

    paths=find_system(modelH,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'BlockType','Assertion');

    if isempty(paths)
        return;
    end

    if isnumeric(paths)
        blks=paths(:)';
    end
    blks=get_param(paths,'Handle');
    if length(blks)>1
        blks=[blks{:}];
    end
end


function out=assert_mask_has_overide(mdlInfoStruct,blockH)
    blkIdx=find(blockH==mdlInfoStruct.parentMasks);
    if isempty(blkIdx)
        out=0;
    else
        out=(mdlInfoStruct.crossGroupCnts(blkIdx)>0);
    end
end


function out=assert_mask_is_overide(mdlInfoStruct,blockH)
    blkIdx=find(blockH==mdlInfoStruct.parentMasks);
    if isempty(blkIdx)
        out=0;
    else
        out=(mdlInfoStruct.overideCnts(blkIdx)>0);
    end
end


function out=util_relative_paths_2_handles(modelName,paths)
    if~iscell(paths)
        try
            out=get_param([modelName,paths],'Handle');
        catch Mex %#ok<*NASGU>
            out=util_load_lib_path([modelName,paths]);
        end
    else
        out=zeros(1,length(paths));
        for idx=1:length(paths)
            try
                out(idx)=get_param([modelName,paths{idx}],'Handle');
            catch Mex
                out(idx)=util_load_lib_path([modelName,paths{idx}]);
            end
        end
    end
end


function blockH=util_load_lib_path(blockPath)
    blockH=-1;
    mustBreak=0;
    slashIdx=find(blockPath=='/');
    slashIdx=[slashIdx,length(blockPath)+1];
    for idx=slashIdx(2:end)
        try
            incPath=find_system(blockPath(1:(idx-1)),'SearchDepth',0,'LoadFullyIfNeeded','on');
        catch Mex
            return
        end
    end
    blockH=get_param(blockPath,'Handle');
end


function paths=util_relative_full_names(handles)
    if isempty(handles)
        paths=[];
        return;
    end

    paths=getfullname(handles);
    modelName=get_param(bdroot(handles(1)),'Name');
    removeIdx=1:length(modelName);

    if ischar(paths)
        paths={paths};
    end

    for i=1:length(paths)
        paths{i}(removeIdx)=[];
    end
end


function mdlInfoStruct=sigb_transform_index(mdlInfoStruct,old2NewIdx)
    if isempty(old2NewIdx)||isempty(mdlInfoStruct.sigbuildHandles)
        return;
    end
    preserve_dirty=Simulink.PreserveDirtyFlag(mdlInfoStruct.modelH,'blockDiagram');
    for sigBuildH=mdlInfoStruct.sigbuildHandles
        blkInfo=sigb_get_info(sigBuildH);
        if~isempty(blkInfo.vnvMgrIdx)
            blkInfo.vnvMgrIdx=old2NewIdx(blkInfo.vnvMgrIdx);
            removeIdx=(blkInfo.vnvMgrIdx==-1);
            blkInfo.vnvMgrIdx(removeIdx)=[];
            blkInfo.verifyBlkHandles=...
            mdlInfoStruct.assertHandles(blkInfo.vnvMgrIdx);
            blkInfo.overideSettings(removeIdx,:)=[];
            sigb_write_info(blkInfo);
        end
    end
end


function isLink=util_is_a_link(blockH)
    if isempty(get_param(blockH,'ReferenceBlock'))
        isLink=0;
    else
        isLink=1;
    end
end


function isLib=util_is_library(modelH)
    if bdIsLibrary(modelH)
        isLib=1;
    else
        isLib=0;
    end
end


function isImplicit=util_is_implicit_link(blockH)
    parentH=get_param(get_param(blockH,'parent'),'handle');
    if(~strcmp(get_param(parentH,'type'),'block_diagram')&&...
        ~isempty(get_param(parentH,'referenceblock')))
        isImplicit=1;
    else
        isImplicit=0;
    end
end


function[list,depth,outPos]=util_block_list_tree(blockList)

    if isempty(blockList)
        list=[];
        depth=[];
        outPos=[];
        return;
    end

    inputIdx=1:length(blockList);
    ancestorStack=bdroot(blockList(1));
    stackLength=1;
    list=bdroot(blockList(1));
    depth=0;
    outPos=-1;

    for i=1:length(blockList)
        blockH=blockList(i);
        blockValue=inputIdx(i);
        parentH=get_param(get_param(blockH,'Parent'),'Handle');
        blockDepth=find(ancestorStack==parentH);

        if isempty(blockDepth)

            newBlocks=[];
            while(isempty(blockDepth))
                newBlocks=[parentH,newBlocks];%#ok<*AGROW>
                parentH=get_param(get_param(parentH,'Parent'),'Handle');
                blockDepth=find(ancestorStack==parentH);
            end

            newBlkCnt=length(newBlocks);
            list=[list,newBlocks];
            depth=[depth,blockDepth-1+(1:newBlkCnt)];
            outPos=[outPos,-1*ones(1,newBlkCnt)];

            ancestorStack=[ancestorStack(1:blockDepth),newBlocks];
            blockDepth=blockDepth+newBlkCnt;
        else

            ancestorStack((blockDepth+1):end)=[];
        end

        list=[list,blockH];
        depth=[depth,blockDepth];
        outPos=[outPos,blockValue];
        stackLength=blockDepth;
    end
end






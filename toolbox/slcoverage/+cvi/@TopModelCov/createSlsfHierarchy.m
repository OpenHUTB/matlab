function createSlsfHierarchy(modelH,hiddenSubSys)
    try





        modelCovId=get_param(modelH,'CoverageId');
        activeRoot=cv('get',modelCovId,'.activeRoot');
        topSlHandle=cv('get',activeRoot,'.topSlHandle');
        topSlName=get_param(topSlHandle,'name');
        topSlsfId=cv('new','slsfobj','.handle',topSlHandle,...
        '.origin',1,...
        '.modelcov',modelCovId);
        cv('SetSlsfName',topSlsfId,topSlName);
        check_triggered_model(hiddenSubSys,topSlsfId,topSlName);
        cv('set',activeRoot,'.topSlsf',topSlsfId);

        hasStartupBlks=cvi.TopModelCov.isStartupVariantCoverageSupported()&&...
        checkIfModelHasStartupBlks(modelH);

        if strcmpi(get_param(topSlHandle,'type'),'block')&&strcmpi(get_param(topSlHandle,'DisableCoverage'),'on')
            add_custom_objectives(topSlHandle,topSlsfId,modelCovId);
        else

            sfcnBlkH=[];
            coveng=cvi.TopModelCov.getInstance(modelH);
            if isa(coveng,'cvi.TopModelCov')&&cvi.SFunctionCov.isSFcnCodeCovOn(coveng.topModelH)

                sfcnBlkH=cvi.SFunctionCov.setupModel(coveng,modelH);
            end

            build_sl_hierarchy(topSlHandle,topSlsfId,modelCovId,sfcnBlkH,hasStartupBlks);


            if~isempty(sfcnBlkH)&&(cv('get',modelCovId,'.simMode')==SlCov.CovMode.Normal)
                cvi.SFunctionCov.addMetrics(coveng,sfcnBlkH);
            end

        end
    catch MEx
        rethrow(MEx);
    end

    function check_triggered_model(hiddenSubSys,topSlsfId,name)

        if isequal(hiddenSubSys,0)
            return;
        end


        slsfobjs=cv('find','all','slsfobj.name',name,'slsfobj.origin',1);
        for idx=1:numel(slsfobjs)
            h=cv('get',slsfobjs(idx),'.handle');
            hiddenSubSysHandle=cv('get',slsfobjs(idx),'.hiddenSubSysHandle');
            if~isequal(hiddenSubSysHandle,0)||...
                (~isequal(h,0)&&ishandle(h)&&strcmpi(get_param(h,'type'),'block_diagram'))
                cv('set',slsfobjs(idx),'.hiddenSubSysHandle',hiddenSubSys);
                set_param(hiddenSubSys,'CoverageId',topSlsfId);
            end
        end


        function build_sl_hierarchy(rootSysHndl,rootSlsfId,modelId,sfcnBlkH,hasStartupBlks)



            CoverageBlockTypes=cvi.TopModelCov.getSupportedBlockTypes;

            cvi.TopModelCov.unsetModelContentsCoverageIds(bdroot(rootSysHndl));


            if(strcmp(cv('Feature','disable assert coverage'),'on'))
                skipAssert=1;
            else
                skipAssert=0;
            end

            if(nargin==1)
                modelName=get_param(bdroot(rootSysHndl),'Name');
                modelcovMangledName=SlCov.CoverageAPI.mangleModelcovName(modelName,mode);
                modelId=SlCov.CoverageAPI.findModelcovMangled(modelcovMangledName);
                rootSlsfId=0;
                if isempty(modelId),modelId=0;end
            end


            if(rootSlsfId==0)
                rootSlsfId=create_new_slsfobjs(rootSysHndl,modelId);
            else


                if bdroot(rootSysHndl)~=rootSysHndl
                    set_param(rootSysHndl,'CoverageId',rootSlsfId);
                end
            end





            if modelId==0
                modelHandle=bdroot(rootSysHndl);
                modelName=get_param(modelHandle,'Name');
                modelId=SlCov.CoverageAPI.createModelcov(modelName,modelHandle);
            end


            [subsys_blks,subsys_par]=find_subsystem_hierarchy(rootSysHndl,hasStartupBlks);



            if(skipAssert)
                assertRelated=strcmp(get_param(subsys_blks,'UsedByAssertionBlockOnly'),'on');
                subsys_blks(assertRelated)=[];
                subsys_par(assertRelated)=[];
            end


            [subsys_blks,subsys_par]=filter_custom_objectives(subsys_blks,subsys_par);
            [subsys_blks,subsys_par,blksToRemove]=filter_observer_unsupported_blocks(modelId,subsys_blks,subsys_par);


            subsys_cvIds=create_new_slsfobjs(subsys_blks,modelId);
            subsys_cvIds=[subsys_cvIds(:);rootSlsfId];





            sysGroups=find([-1;subsys_par]~=[subsys_par;-1]);

            for i=1:(length(sysGroups)-1)
                children=subsys_cvIds((sysGroups(i)):(sysGroups(i+1)-1));
                parent=subsys_cvIds([subsys_blks;rootSysHndl]==subsys_par(sysGroups(i)));


                if isempty(parent)
                    cleanup_orphans(children);
                else
                    cv('BlockAdoptChildren',parent,children);
                end
            end




            leafBlocks=[];
            numBlkTypes=numel(CoverageBlockTypes);
            if Simulink.internal.useFindSystemVariantsMatchFilter()








                findBlocksOfTypeFunc=@(mdl,blockType)find_system(mdl,...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                'LookUnderMasks','all','BlockType',blockType,...
                'DisableCoverage','off');
            else





                assert(~hasStartupBlks);
                findBlocksOfTypeFunc=@(mdl,blockType)find_system(mdl,...
                'FollowLinks','on','LookUnderMasks','all','BlockType',blockType,...
                'DisableCoverage','off');
            end
            for ii=1:numBlkTypes

                warning_state=warning('off');%#ok<WNOFF>
                newBlocks=findBlocksOfTypeFunc(rootSysHndl,CoverageBlockTypes{ii});
                warning(warning_state);



                if ii==numBlkTypes&&~isempty(sfcnBlkH)


                    newBlocks=intersect(newBlocks,sfcnBlkH);
                end
                leafBlocks=[leafBlocks;newBlocks];%#ok<AGROW>
            end


            delIdx=ismember(leafBlocks,blksToRemove);
            leafBlocks(delIdx)=[];


            leafBlocks_par=get_param(get_param(leafBlocks,'Parent'),'Handle');
            if iscell(leafBlocks_par)
                leafBlocks_par=cat(1,leafBlocks_par{:});
                [leafBlocks_par,sortI]=sort(leafBlocks_par);
                leafBlocks=leafBlocks(sortI);
            end


            if(skipAssert)
                assertRelated=strcmp(get_param(leafBlocks,'UsedByAssertionBlockOnly'),'on');
                leafBlocks(assertRelated)=[];
                leafBlocks_par(assertRelated)=[];
            end



            leafBlocks_cvIds=create_new_slsfobjs(leafBlocks,modelId,sfcnBlkH);

            leafSysGroups=find([-1;leafBlocks_par]~=[leafBlocks_par;-1]);



            if~any(leafBlocks_cvIds==0)
                for i=1:(length(leafSysGroups)-1)
                    children=leafBlocks_cvIds((leafSysGroups(i)):(leafSysGroups(i+1)-1));
                    parent=subsys_cvIds([subsys_blks;rootSysHndl]==leafBlocks_par(leafSysGroups(i)));


                    if isempty(parent)
                        cleanup_orphans(children);
                    else
                        cv('BlockAdoptChildren',parent,children);
                    end
                end
            end
            add_custom_objectives(rootSysHndl,subsys_cvIds,modelId);



            warning_state=warning('off');%#ok<WNOFF>
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                leftOvers=find_system(rootSysHndl,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                'LookUnderMasks','all','CoverageId',0,...
                'DisableCoverage','off');
            else





                assert(~hasStartupBlks);
                leftOvers=find_system(rootSysHndl,'FollowLinks','on',...
                'LookUnderMasks','all','CoverageId',0,...
                'DisableCoverage','off');
            end
            warning(warning_state);


            delIdx=ismember(leftOvers,blksToRemove);
            leftOvers(delIdx)=[];

            leftOvers=filter_blocks_with_not_interested_output(leftOvers);
            leftOver_par=get_param(get_param(leftOvers,'Parent'),'Handle');


            if iscell(leftOver_par)
                leftOver_par=cat(1,leftOver_par{:});
                [leftOver_par,sortI]=sort(leftOver_par);
                leftOvers=leftOvers(sortI);
            end

            [leftOvers,leftOver_par]=filter_custom_objectives(leftOvers,leftOver_par);

            leftOverSysGroups=find([-1;leftOver_par]~=[leftOver_par;-1]);

            leftOver_cvids=create_new_slsfobjs(leftOvers,modelId);

            for i=1:(length(leftOverSysGroups)-1)
                children=leftOver_cvids((leftOverSysGroups(i)):(leftOverSysGroups(i+1)-1));
                parent=subsys_cvIds([subsys_blks;rootSysHndl]==leftOver_par(leftOverSysGroups(i)));

                children(children==0)=[];

                if isempty(parent)
                    cleanup_orphans(children);
                else
                    cv('BlockAdoptChildren',parent,children);
                end
            end








            function leftOvers=filter_blocks_with_not_interested_output(leftOvers)

                objsIdx=[];
                toFilterBlockTypes={'Merge','Scope','Outport','Inport','Width','Display','ObserverPort','Record','ToWorkspace'};
                for bidx=1:numel(leftOvers)
                    blockType=get_param(leftOvers(bidx),'BlockType');
                    f=strfind(toFilterBlockTypes,blockType);
                    if any([f{:}])
                        objsIdx=[objsIdx,bidx];
                    else
                        parentH=get_param(get_param(leftOvers(bidx),'Parent'),'Handle');
                        if ishandle(parentH)&&...
                            strcmpi(get_param(parentH,'Type'),'block')&&...
                            strcmpi(get_param(parentH,'BlockType'),'subsystem')&&...
                            strcmpi(get_param(parentH,'MaskHideContents'),'on')
                            objsIdx=[objsIdx,bidx];
                        end
                    end
                end

                leftOvers(objsIdx)=[];




                function[subsys_blks,subsys_par]=filter_custom_objectives(subsys_blks,subsys_par)
                    delIdx=[];
                    for idx=1:numel(subsys_blks)
                        blk=subsys_blks(idx);
                        parent=get_param(blk,'parent');
                        if cvi.TopModelCov.isDVBlock(get_param(blk,'handle'))||cvi.TopModelCov.isDVBlock(get_param(parent,'handle'))
                            delIdx=[delIdx,idx];%#ok<AGROW>
                        end
                    end
                    subsys_blks(delIdx)=[];
                    subsys_par(delIdx)=[];



                    function[subsys_blks,subsys_par,blksToRemove]=filter_observer_unsupported_blocks(modelcovId,subsys_blks,subsys_par)




                        blksToRemove=[];
                        isObserver=cv('get',modelcovId,'.isObserver');
                        if~isObserver
                            return;
                        end


                        termEventListeners=find_system(subsys_blks,...
                        'FollowLinks','on',...
                        'SearchDepth',1,...
                        'LookUnderMasks','all',...
                        'BlockType','EventListener',...
                        'EventType','Terminate');

                        if isempty(termEventListeners)
                            return;
                        end
                        termFuncSubsystems=arrayfun(@(b)get_param(get_param(b,'parent'),'handle'),termEventListeners)';


                        delIdx=ismember(subsys_blks,termFuncSubsystems);
                        subsys_blks(delIdx)=[];
                        subsys_par(delIdx)=[];



                        testId=cv('get',modelcovId,'.activeTest');
                        if(testId>0)
                            rb={};
                            for i=1:length(termFuncSubsystems)
                                cb=termFuncSubsystems(i);
                                rat=getString(message('Slvnv:simcoverage:cvhtml:UnsupportedForObserver'));
                                rb=[rb,{{Simulink.ID.getSID(cb),rat}}];%#ok<AGROW>
                            end

                            if~isempty(rb)
                                crb=cv('get',testId,'.reducedBlocks');
                                crb=[crb,rb];
                                cv('set',testId,'.reducedBlocks',crb);
                            end
                        end





                        blksToRemove=find_system(termFuncSubsystems,...
                        'FollowLinks','on',...
                        'SearchDepth',1,...
                        'LookUnderMasks','all');



                        function add_custom_objectives(rootSysHndl,subsys_cvIds,modelId)
                            customBlks=[];
                            warning_state=warning('off');%#ok<WNOFF>
                            dvBlockTypes=cvi.MetricRegistry.getDVSupportedMaskTypes;
                            for idx=1:numel(dvBlockTypes)


                                customBlks=[customBlks;find_system(rootSysHndl,'FollowLinks','on',...
                                'LookUnderMasks','all',...
                                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                                'MaskType',dvBlockTypes{idx},...
                                'DisableCoverage','off',...
                                'Enabled','on')];
                            end
                            warning(warning_state);
                            if isempty(customBlks)
                                return;
                            end
                            if~isempty(subsys_cvIds)
                                allHandles=cv('get',subsys_cvIds,'.handle');
                            else
                                allHandles=[];
                            end
                            if~isempty(customBlks)
                                for cs=customBlks(:)'
                                    parentH=get_param(get_param(cs,'Parent'),'Handle');
                                    cvId=create_new_slsfobjs(cs,modelId);

                                    while true
                                        parentCvId=subsys_cvIds(allHandles==parentH);
                                        if~isempty(parentCvId)
                                            cv('BlockAdoptChildren',parentCvId,cvId);
                                            break;
                                        end
                                        newSubSysCvId=create_new_slsfobjs(parentH,modelId);


                                        cv('BlockAdoptChildren',newSubSysCvId,cvId);
                                        subsys_cvIds=[subsys_cvIds;newSubSysCvId];%#ok<AGROW>
                                        allHandles=[allHandles;parentH];%#ok<AGROW>
                                        cvId=newSubSysCvId;
                                        parentH=get_param(get_param(parentH,'Parent'),'Handle');
                                    end
                                    assert(~isempty(cvId));
                                end
                            end





                            function newIds=create_new_slsfobjs(slHandles,modelId,sfcnBlkH)

                                if nargin<3
                                    sfcnBlkH=[];
                                end

                                newIds=zeros(size(slHandles));

                                for i=1:length(slHandles)
                                    ch=slHandles(i);

                                    blktypeObjId=get_blktype_id(modelId,ch,sfcnBlkH);
                                    name=get_param(ch,'Name');
                                    newIds(i)=cv('new','slsfobj','.handle',ch,...
                                    '.origin',1,...
                                    '.modelcov',modelId,...
                                    '.slBlckType',blktypeObjId);
                                    cv('SetSlsfName',newIds(i),name);
                                    set_param(ch,'CoverageId',newIds(i));
                                end



                                function cleanup_orphans(cvIds)
                                    slHandles=cv('get',cvIds,'.handle');
                                    for blockH=slHandles(:)'
                                        set_param(blockH,'CoverageId',0);
                                    end
                                    cv('delete',cvIds);



                                    function[allNodes,allParents,childCnts]=find_subsystem_hierarchy(root,hasStartupBlks)
                                        warning_state=warning('off');%#ok<WNOFF>
                                        if Simulink.internal.useFindSystemVariantsMatchFilter()
                                            allNodes=find_system(root,'FollowLinks','on',...
                                            'SearchDepth',1,...
                                            'LookUnderMasks','all',...
                                            'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                                            'BlockType','SubSystem',...
                                            'DisableCoverage','off');
                                        else





                                            assert(~hasStartupBlks);
                                            allNodes=find_system(root,'FollowLinks','on',...
                                            'SearchDepth',1,...
                                            'LookUnderMasks','all',...
                                            'BlockType','SubSystem',...
                                            'DisableCoverage','off');
                                        end
                                        warning(warning_state);

                                        allNodes(allNodes==root)=[];

                                        if isempty(allNodes)
                                            allParents=[];
                                            childCnts=[];
                                            return;
                                        end

                                        childCnts=length(allNodes);
                                        allParents=root*ones(length(allNodes),1);

                                        for child=allNodes(:)'
                                            [newNodes,newParents,newCnts]=find_subsystem_hierarchy(child,hasStartupBlks);
                                            allNodes=[allNodes;newNodes];
                                            allParents=[allParents;newParents];
                                            childCnts=[childCnts;newCnts];
                                        end


                                        function check_sf_debug(modelName)
                                            [~,mexf]=inmem;
                                            sfIsHere=any(strcmp(mexf,'sf'));
                                            if sfIsHere
                                                sfrt=sfroot;
                                                machine=sfrt.find('-isa','Stateflow.Machine','name',modelName);
                                                if~isempty(machine)
                                                    if sfc('coder_options','forceDebugOff')
                                                        warning(message('Slvnv:simcoverage:createSlsHierarchy:stateflow_no_debug'));
                                                    end
                                                end
                                            end

                                            function objId=get_blktype_id(modelId,slHandle,sfcnBlkH)

                                                if nargin<3
                                                    sfcnBlkH=[];
                                                end

                                                blktypeStr=get_param(slHandle,'BlockType');

                                                isDV=cvi.TopModelCov.isDVBlock(slHandle);
                                                if isDV
                                                    blktypeStr=get_param(slHandle,'MaskType');
                                                elseif strcmp(blktypeStr,'S-Function')
                                                    if isempty(sfcnBlkH)||~ismember(slHandle,sfcnBlkH)
                                                        blktypeStr=SlCov.Utils.fixSFunctionName(get_param(slHandle,'FunctionName'));
                                                    end
                                                end
                                                objId=[];

                                                blockTypeIds=cv('get',modelId,'.blockTypes');
                                                if~isempty(blockTypeIds)
                                                    objId=cv('find',blockTypeIds,'.type',blktypeStr);
                                                end

                                                if isempty(objId)
                                                    if(isDV||isSupported(blktypeStr))
                                                        objId=cv('new','typename','.type',blktypeStr);
                                                        blockTypeIds(end+1)=objId;
                                                        cv('set',modelId,'.blockTypes',blockTypeIds);
                                                    else
                                                        objId=0;
                                                    end
                                                end

                                                objId=objId(1);



                                                function res=isSupported(blktypeStr)
                                                    res=ismember(blktypeStr,cvi.TopModelCov.getSupportedBlockTypes);


                                                    function match=matchFilterInAllVariants(~)
                                                        match=true;


                                                        function hasStartupBlks=checkIfModelHasStartupBlks(modelH)
                                                            startupBlks=find_system(modelH,'FollowLinks','on',...
                                                            'MatchFilter',@startupBlocksInAllVariants,...
                                                            'LookUnderMasks','all');
                                                            if~isempty(startupBlks)
                                                                hasStartupBlks=true;
                                                            else
                                                                hasStartupBlks=false;
                                                            end


                                                            function match=startupBlocksInAllVariants(handle)
                                                                match=false;
                                                                if strcmp(get_param(handle,'Type'),'block')
                                                                    blockType=get_param(handle,'BlockType');
                                                                    if(strcmp(blockType,'VariantSource')||strcmp(blockType,'VariantSink'))&&...
                                                                        strcmp(get_param(handle,'VariantControlMode'),'expression')&&...
                                                                        strcmp(get_param(handle,'VariantActivationTime'),'startup')
                                                                        match=true;
                                                                    elseif strcmp(blockType,'SubSystem')
                                                                        SS=Simulink.SubsystemType(handle);
                                                                        if SS.isVariantSubsystem&&...
                                                                            strcmp(get_param(handle,'VariantControlMode'),'expression')&&...
                                                                            strcmp(get_param(handle,'VariantActivationTime'),'startup')
                                                                            match=true;
                                                                        end
                                                                    end
                                                                end



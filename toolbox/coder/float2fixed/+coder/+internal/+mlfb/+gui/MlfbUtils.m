classdef(Sealed)MlfbUtils<handle


    methods(Access=private)
        function this=MlfbUtils()
        end
    end

    methods(Static,Hidden)
        function on=isCodeViewFeaturedOn()
            on=slfeature('FPTMATLABFunctionBlockFloat2Fixed');
        end

        function[javaRuns,lastUpdated]=getRunsForBlock(blockId)
            coder.internal.mlfb.idForBlock(blockId);

            repository=fxptds.FPTRepository.getInstance();
            dataset=repository.getDatasetForSource(blockId.ModelName);
            assert(~isempty(dataset));

            DataLayer=fxptds.DataLayerInterface.getInstance();
            runNames=DataLayer.getAllRunNamesWithResults(dataset);

            javaRuns={};

            import('com.mathworks.toolbox.coder.mlfb.impl.MutableRun');

            for i=1:numel(runNames)
                runName=runNames{i};
                if isempty(runName)
                    continue;
                end

                run=dataset.getRun(runName);
                includedFbs=coder.internal.mlfb.gui.MlfbUtils.getFunctionBlocksInRun(run);
                javaRuns{end+1}=MutableRun(runName,includedFbs,run.hasDataTypeProposals());%#ok<AGROW>
            end

            lastUpdated=dataset.getLastUpdatedRun();
            if isempty(lastUpdated)
                lastUpdated='';
            elseif~ismember(lastUpdated,runNames)
                if~isempty(runNames)
                    lastUpdated=runNames{end};
                else
                    lastUpdated='';
                end
            end
        end

        function runMode=getRunMode(run)
            assert(isa(run,'fxptds.FPTRun'));


            runMode=datasample(cell(com.mathworks.toolbox.coder.mlfb.fpt.RunMode.values()),1);
            runMode=runMode{1};
        end

        function run=getFptRunByName(blockArg,runName)
            blockId=coder.internal.mlfb.idForBlock(blockArg);

            repository=fxptds.FPTRepository.getInstance();
            dataset=repository.getDatasetForSource(blockId.ModelName);
            assert(~isempty(dataset));

            if ismember(runName,dataset.getAllRunNames())
                run=dataset.getRun(runName);
            else
                run=[];
            end
        end

        function javaIds=idsToJava(outputType,varargin)
            javaIds=cell(size(varargin));
            for i=1:numel(varargin)
                blockId=varargin{i};
                assert(isa(blockId,'coder.internal.mlfb.BlockIdentifier'));
                javaIds{i}=blockId.toJava();
            end

            outputType=lower(outputType);
            validatestring(outputType,{'array','list','set'});



            if~strcmp(outputType,'array')

                javaIds=java.util.Arrays.asList(javaIds);
                if strcmp(outputType,'set')

                    javaIds=java.util.LinkedHashSet(javaIds);
                end
            end
        end

        function applyConversionFimathToSud(sudId,fimathObj)
            coder.internal.mlfb.idForBlock(sudId);

            if ischar(fimathObj)
                fimathObj=eval(fimathObj);
            end
            assert(isa(fimathObj,'embedded.fimath'));

            coder.internal.mlfb.gui.MlfbUtils.forEachFunctionBlock(sudId,...
            @(id)coder.internal.MLFcnBlock.Float2FixedManager.setFimath(id,fimathObj));
        end

        function forEachFunctionBlock(nodeArg,visitor)
            nodeId=coder.internal.mlfb.idForBlock(nodeArg);
            validateattributes(visitor,{'char','function_handle'},{});

            if ischar(visitor)
                visitor=str2func(visitor);
            end
            assert(abs(nargin(visitor))>=1);

            if~coder.internal.mlfb.gui.MlfbUtils.isFunctionBlock(nodeId)
                coder.internal.mlfb.gui.MlfbUtils.walkSidHierarchy(nodeId,@walk);
            else
                visitor(nodeId);
            end

            function walk(id)
                if id.isFunctionBlock()
                    visitor(id);
                end
            end
        end

        function info=getSudInfo(blockId)
            blockId=coder.internal.mlfb.idForBlock(blockId);
            javaId=blockId.toJava();

            import('com.mathworks.toolbox.coder.mlfb.impl.SimpleSimulinkBlockInfo');
            info=SimpleSimulinkBlockInfo(javaId,...
            blockId.Name,...
            blockId.FullName,...
            blockId.ModelName,...
            blockId.SIDNumber,...
            javaId.isModel());
        end

        function info=getBlockInfo(blockId)
            blockId=coder.internal.mlfb.idForBlock(blockId);
            assert(blockId.isFunctionBlock());
            javaId=blockId.toJava();

            functionIds=sfprivate('eml_based_fcns_in',blockId.getChartID());
            assert(~isempty(functionIds),'EMChart did not resolve to a function');

            try
                machineId=blockId.getChart().Machine.Id;
            catch
                machineId=0;
            end

            import('com.mathworks.toolbox.coder.mlfb.impl.SimpleMlfbBlockInfo');
            info=SimpleMlfbBlockInfo(javaId,...
            blockId.FullName,...
            blockId.Name,...
            blockId.ModelName,...
            blockId.getChartID(),...
            functionIds(1),...
            machineId,...
            blockId.SIDNumber);
            info.setLocked(~coder.internal.mlfb.gui.MlfbUtils.isBlockChartEnabled(blockId));
        end

        function runName=getFptActionableRun(blockSid)
            validateattributes(blockSid,{'char'},{'nonempty'});
            appData=SimulinkFixedPoint.getApplicationData(bdroot(blockSid));
            runName=appData.ScaleUsing;
        end

        function managed=isManagedVariantSubsystem(blockArg)
            blockId=coder.internal.mlfb.idForBlock(blockArg);
            [orig,fixpt]=coder.internal.mlfb.getMlfbVariants(blockId.SID);
            managed=~isempty(orig)&&~isempty(fixpt)&&~blockId.isFunctionBlock();
        end

        function enabled=isBlockChartEnabled(blockArg)
            blockId=coder.internal.mlfb.idForBlock(blockArg);
            enabled=blockId.isStateflowChart()&&coder.internal.mlfb.gui.MlfbUtils.isChartEnabled(blockId.getChart());
        end

        function enabled=isChartEnabled(chart)
            assert(isa(chart,'Stateflow.EMChart'));
            enabled=~chart.Iced&&~chart.Locked;
        end

        function fixptId=getFixedPointVariantId(origArg)
            origId=coder.internal.mlfb.idForBlock(origArg);
            [~,fixptSid]=coder.internal.mlfb.getMlfbVariants(origId.SID);
            fixptId=coder.internal.mlfb.idForBlock(fixptSid);
        end

        function match=isFixedPointVariant(mlfbArg)
            mlfbId=coder.internal.mlfb.idForBlock(mlfbArg);
            fixptSid=coder.internal.mlfb.gui.MlfbUtils.getFixedPointVariantId(mlfbId);
            match=eq(mlfbId,fixptSid);
        end

        function code=getMultipleBlockCode(blocks)
            blocks=cell(blocks);
            code=cell(numel(blocks),1);

            for i=1:numel(blocks)
                code{i}=coder.internal.gui.GuiUtils.getFunctionBlockCode(char(blocks{i}));
            end
        end

        function[info,code]=getFunctionBlockInfoAndCode(sid)
            info=coder.internal.mlfb.gui.MlfbUtils.getBlockInfo(sid);
            code=coder.internal.gui.GuiUtils.getFunctionBlockCode(sid);
        end

        function type=getJavaBlockType(blockObj)
            blockObj=coder.internal.mlfb.idForBlock(blockObj).Block;
            import('com.mathworks.toolbox.coder.mlfb.BlockType');

            switch class(blockObj)
            case 'Simulink.BlockDiagram'
                type=BlockType.MODEL;
            case 'Simulink.SubSystem'
                if coder.internal.mlfb.gui.MlfbUtils.isFunctionBlock(blockObj)
                    type=BlockType.FUNCTION_BLOCK;
                else
                    type=BlockType.SUBSYSTEM;
                end
            otherwise
                type=BlockType.GENERIC;
            end
        end

        function ids=getFunctionBlocksInRun(runObj)
            assert(isa(runObj,'fxptds.FPTRun'));

            results=runObj.getResults();
            handles=zeros(numel(results),1);
            count=0;

            for i=1:numel(results)
                result=results(i);
                uid=result.getUniqueIdentifier();

                if isa(uid,'fxptds.MATLABExpressionIdentifier')
                    count=count+1;
                    resultObj=uid.getMATLABFunctionBlock();


                    if~isempty(resultObj)
                        handles(count)=resultObj.Handle;
                    end
                end
            end


            handles=unique(handles(1:count));


            ids=java.util.ArrayList(numel(handles));
            for i=1:numel(handles)
                id=coder.internal.mlfb.idForBlock(handles(i));
                ids.add(id.toJava());
            end
        end

        function answer=isFunctionBlock(blockArg)
            blockIdentifier=coder.internal.mlfb.idForBlock(blockArg);
            answer=blockIdentifier.isFunctionBlock();
        end

        function walkSidHierarchy(identifier,visitor)
            assert(isa(visitor,'function_handle')&&nargin(visitor)==1||nargin(visitor)==2);
            twoarg=nargin(visitor)==2;
            controllable=nargout(visitor)==1;

            traverse([],coder.internal.mlfb.idForBlock(identifier));

            function keepGoing=traverse(parentId,nodeId)
                keepGoing=true;

                try
                    nodeObject=nodeId.Block;
                    mlfb=nodeId.isFunctionBlock();

                    if~mlfb&&~coder.internal.mlfb.gui.MlfbUtils.isRelevantBlock(identifier)

                        return;
                    end

                    if twoarg
                        args={parentId,nodeId};
                    else
                        args={nodeId};
                    end

                    if controllable
                        cue=visitor(args{:});
                    else
                        visitor(args{:});
                        cue=1;
                    end

                    if cue==0

                        return;
                    elseif cue==-1

                        keepGoing=false;
                        return;
                    elseif mlfb
                        return;
                    else

                    end

                    try
                        children=nodeObject.getHierarchicalChildren();
                    catch
                        return;
                    end

                    for i=1:numel(children)
                        try
                            childId=coder.internal.mlfb.idForBlock(children(i));
                            if~coder.internal.mlfb.gui.MlfbUtils.isRelevantBlock(childId)
                                continue;
                            end
                        catch
                            continue;
                        end

                        if nodeId~=childId
                            keepGoing=traverse(nodeId,childId);
                        end

                        if~keepGoing
                            break;
                        end
                    end
                catch me
                    coder.internal.gui.asyncDebugPrint(me);
                end
            end
        end

        function proposeOrApply(mode,~)
            validatestring(mode,{'propose','apply'});

            fpt=coder.internal.mlfb.FptFacade.getInstance();
            assert(fpt.isLive(),'Code View should only be open when the FPT is open');
            assert(~isempty(fpt.getSud()),'Code View should only be open with an active SUD');

            if strcmp(mode,'propose')
                fpt.propose();
            else
                fpt.apply();
            end
        end

        function initial=getInitialBlock(selected)





            initial=[];
            fpt=coder.internal.mlfb.FptFacade.getInstance();
            sud=fpt.getSud();

            if ischar(selected)
                selected=get_param(selected,'Object');
            else
                assert(isa(selected,'DAStudio.Object')||isa(selected,'Simulink.DABaseObject'));
            end

            if isempty(sud)
                return;
            elseif isempty(selected)
                initial=coder.internal.mlfb.idForBlock(sud);
                return;
            end

            import('coder.internal.mlfb.gui.MlfbUtils');
            [selected,sud]=coder.internal.mlfb.idForBlock(selected,sud);
            relationship=MlfbUtils.getBlockRelationship(sud,selected);

            if isempty(relationship)

                return;
            elseif relationship>0

                initial=selected;
            else
                assert(relationship<0);

                initial=sud;
            end

            assert(~isempty(initial));

            if~initial.isFunctionBlock()
                initial=[];
            end
        end

        function relation=getBlockRelationship(first,second)
            import('coder.internal.mlfb.gui.MlfbUtils');
            [first,second]=coder.internal.mlfb.idForBlock(first,second);

            if isUnder(first,second)
                relation=1;
            elseif isUnder(second,first)
                relation=-1;
            else
                relation=[];
            end

            function under=isUnder(parent,testNode)
                current=testNode;
                while~isempty(current)&&current~=parent
                    current=current.getParent();
                end
                under=~isempty(current);
            end
        end

        function pass=isFixedPointToolWithBlock(blockSid)
            validateattributes(blockSid,{'char'},{'nonempty'});

            pass=false;
            sud=coder.internal.mlfb.FptFacade.invoke('getSud');

            if~isempty(sud)
                targetModel=get_param(bdroot(blockSid),'Object');
                fptModel=get_param(bdroot(sud.getFullName()),'Object');
                pass=isequal(targetModel,fptModel);

                if~pass


                    modelRefs=find_mdlrefs(fptModel.getFullName(),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                    pass=any(strcmp(targetModel.getFullName(),modelRefs));
                end
            end
        end

        function[result,mlfbSid]=getSelectedListViewResult()
            result=[];
            mlfbSid=[];

            selected=coder.internal.mlfb.FptFacade.invoke('getSelectedResult');
            assert(isempty(selected)||numel(selected)==1);

            if isa(selected,'fxptds.MATLABExpressionResult')
                result=selected;
                mlfbSid=selected.getUniqueIdentifier().MATLABFunctionIdentifier.SID;
            end
        end

        function goToBlock(blockArg)
            blockId=coder.internal.mlfb.idForBlock(blockArg);
            if blockId.isStateflowChart()
                sf('UpView',blockId.getChartID());
            end
        end

        function goToFptTreeNode(blockId)
            blockId=coder.internal.mlfb.idForBlock(blockId);
            if~isempty(blockId)
                coder.internal.mlfb.FptFacade.invoke('goToTreeNode',blockId.FullName);
            end
        end

        function iconPath=getCodeViewActionIcon()
            iconPath=fullfile(matlabroot,'toolbox','coder',...
            'float2fixed','resources','codeview_16.png');
        end

        function clearDriverApplyErrors(sud)
            coder.internal.mlfb.gui.MlfbUtils.forEachFunctionBlock(sud,@visitMlfb);

            function visitMlfb(id)
                driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(id.SID);
                if~isempty(driver)
                    driver.getAndClearApplyMessages();
                end
            end
        end

        function relevant=isRelevantBlock(nodeArg,currentStateOnly)















            if~exist('currentStateOnly','var')
                currentStateOnly=false;
            end

            relevant=false;

            try
                nodeId=coder.internal.mlfb.idForBlock(nodeArg);
            catch

                return;
            end

            nodeObject=nodeId.Block;

            if~nodeId.isFunctionBlock()&&...
                ~isa(nodeObject,'Simulink.SubSystem')&&...
                ~isa(nodeObject,'Simulink.BlockDiagram')


            elseif~nodeObject.isHierarchical()||nodeObject.isModelReference()

            elseif nodeId.isStateflowChart()&&~nodeId.isFunctionBlock()


            elseif currentStateOnly&&~strcmp(nodeObject.StaticLinkStatus,'none')




            else
                relevant=true;
            end
        end
    end

    methods(Static,Access=private)
        function under=isUnderNode(parentArg,nodeArg)
            [parentId,nodeId]=coder.internal.mlfb.idForBlock(parentArg,nodeArg);
            curNode=nodeId;

            while~isempty(curNode)
                if curNode==parentId
                    under=true;
                    return;
                else
                    curNode=curNode.getParent();
                end
            end
            under=false;
        end
    end
end



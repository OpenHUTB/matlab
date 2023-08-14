classdef SerDesTree<serdes.internal.ibisami.ami.Tree






    properties(Constant)
        TapFlag="TapWeights"
        MaxInitAggressorsValue=6
        AMIDebugBlock="AMI_Debug"
    end
    properties(Hidden)
        Broadcast=true;
        UndoStack={}
    end
    properties(Dependent)
SimulinkWorkSpace
BlockNodes
    end
    properties(Dependent,Access=private)
    end
    properties
        dirty(1,1)logical=true;
        modelHandle=[]
        SimulinkVariables={};
        BaseWorkspaceVariables={};
Paths2Nodes

        UsesSimulinkWorkSpace(1,1)logical=false;
        UseSwitchableModulation(1,1)logical=false;
    end
    methods
        function blockNodes=get.BlockNodes(tree)
            blockNodes=serdes.internal.ibisami.ami.SerDesNode.empty;
            modelSpecificNodes=tree.getChildren(tree.ModelSpecificNode);
            for nodeIdx=1:numel(modelSpecificNodes)
                node=modelSpecificNodes{nodeIdx};
                if~isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')
                    blockNodes{end+1}=node;%#ok<AGROW>
                end
            end
        end
        function simulinkWorkSpace=get.SimulinkWorkSpace(tree)
            simulinkWorkSpace=serdes.internal.ibisami.ami.simulinkWorkSpace(tree);
        end
        function set.Broadcast(tree,broadcast)
            if broadcast~=tree.Broadcast
                tree.Broadcast=broadcast;
                if broadcast
                    tree.treeChanged
                end
            end
        end
    end
    methods
        function tree=SerDesTree(varargin)
            if nargin>0



                arg1=varargin{1};
                if ischar(arg1)||isstring(arg1)
                    varargin{1}=serdes.internal.ibisami.ami.SerDesNode(arg1);
                else
                    validateattributes(arg1,{'serdes.internal.ibisami.ami.SerDesNode'},{'scalar'},"SerDesTree","RootNode")
                end
            else
                varargin{1}=string.empty;
            end
            tree=tree@serdes.internal.ibisami.ami.Tree(varargin{:});
            tree.Paths2Nodes=containers.Map('KeyType','char','ValueType','any');
            if nargin>1
                createBasics=varargin{2};
                if~islogical(createBasics)
                    createBasics=true;
                end
            else
                createBasics=true;
            end
            if createBasics
                tree.addGeneralParameters
                tree.addLegacyModulationParameters
            end
        end
    end
    methods(Access=private)
        function node=nodeByName(~,name,nodeArray)
            for nodeIdx=1:numel(nodeArray)
                node=nodeArray{nodeIdx};
                if strcmp(node.NodeName,name)
                    return
                end
            end
            node=serdes.internal.ibisami.ami.SerDesNode.empty;
        end
    end
    methods






        function blockNode=addBlock(tree,varargin)
            if numel(varargin)>0
                blockName=varargin{1};
                validateattributes(blockName,{'char','string'},{},...
                '','blockName',1)
                if strcmpi(blockName,tree.AMIDebugBlock)
                    error(message('serdes:ibis:BlockReserved',blockName))
                end
                blockNode=serdes.internal.ibisami.ami.SerDesNode(blockName);
                tree.addChild(tree.ModelSpecificNode,blockNode);
                if numel(varargin)>1
                    params=varargin{2};
                    for paramIdx=1:length(params)
                        param=params{paramIdx};
                        if isa(param,'serdes.internal.ibisami.ami.TappedDelayLine')
                            tree.insertTappedDelayLine(blockNode,param)
                        elseif isa(param,'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter')
                            tree.addChild(blockNode,param)
                        end
                    end
                end
            end
        end
        function blockNode=getBlockNode(tree,blockName)
            blockNode=[];
            blocks=tree.BlockNodes;
            for blockIdx=1:numel(blocks)
                block=blocks{blockIdx};
                if strcmpi(block.NodeName,blockName)
                    blockNode=block;
                    break;
                end
            end
        end
        function[ok,blockIdx]=containsBlock(tree,blockName)
            ok=false;
            blocks=tree.BlockNodes;
            for blockIdx=1:numel(blocks)
                block=blocks{blockIdx};
                if strcmpi(block.NodeName,blockName)
                    ok=true;
                    break;
                end
            end
            if~ok
                blockIdx=0;
            end
        end
        function amiParameter=getParameterFromBlock(tree,blockName,amiParameterName)



            validateattributes(blockName,{'string','char'},{})
            validateattributes(amiParameterName,{'string','char'},{})
            block=tree.getBlockNode(blockName);
            if~isempty(block)
                blockChildren=tree.getChildren(block);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if isa(child,...
                        'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter')
                        if strcmpi(child.NodeName,amiParameterName)
                            amiParameter=child;
                            return;
                        end
                    elseif strcmp(child.NodeName,tree.TapFlag)
                        tapParams=tree.getChildren(child);
                        for tapIdx=1:numel(tapParams)
                            tap=tapParams{tapIdx};
                            if strcmpi(tap.NodeName,amiParameterName)
                                amiParameter=tap;
                                return;
                            end
                        end
                    end
                end
            end
            amiParameter=[];
        end
        function setCurrentValue(tree,blockName,amiParameterName,newValue)
            if ischar(newValue)
                newValue=string(newValue);
            end
            block=tree.getBlockNode(blockName);
            if~isempty(block)
                amiParameter=tree.getParameterFromBlock(blockName,amiParameterName);
                if~isempty(amiParameter)&&...
                    (isempty(amiParameter.CurrentValue)||amiParameter.CurrentValue~=newValue)
                    amiParameter.CurrentValue=newValue;
                    tree.treeChanged
                end
            end
        end
        function setReservedParameterCurrentValue(tree,reservedParameterName,value)
            if ischar(value)
                value=string(value);
            end
            parameter=tree.getReservedParameter(reservedParameterName);
            if~isempty(parameter)&&...
                (isempty(parameter.CurrentValue)||parameter.CurrentValue~=value)
                parameter.CurrentValue=value;
                if isa(parameter,'serdes.internal.ibisami.ami.parameter.modulation.Modulation')
                    thresholdsHidden=~strcmp(parameter.CurrentValue,'PAM4')&&...
                    ~tree.UseSwitchableModulation;
                    centerThreshold=tree.getReservedParameter("Pam4_CenterThreshold");
                    if~isempty(centerThreshold)
                        centerThreshold.Hidden=thresholdsHidden;
                    end
                    upperThreshold=tree.getReservedParameter("Pam4_UpperThreshold");
                    if~isempty(upperThreshold)
                        upperThreshold.Hidden=thresholdsHidden;
                    end
                    lowerThreshold=tree.getReservedParameter("Pam4_LowerThreshold");
                    if~isempty(lowerThreshold)
                        lowerThreshold.Hidden=thresholdsHidden;
                    end
                elseif isa(parameter,'serdes.internal.ibisami.ami.parameter.modulation.ModulationLevels')
                    thresholdsHidden=~(parameter.CurrentValue>2)&&~tree.UseSwitchableModulation;
                    thresholds=tree.getReservedParameter("PAM_Thresholds");
                    if~isempty(thresholds)
                        thresholds.Hidden=thresholdsHidden;
                    end
                end
                tree.treeChanged
            end
        end
        function value=getCurrentValue(tree,blockName,amiParameterName)
            block=tree.getBlockNode(blockName);
            value=[];
            if~isempty(block)
                amiParameter=tree.getParameterFromBlock(blockName,amiParameterName);
                if~isempty(amiParameter)
                    value=amiParameter.CurrentValue;
                end
            end
        end
        function renameBlock(tree,oldBlockName,newBlockName)


            if strcmpi(newBlockName,tree.AMIDebugBlock)
                error(message('serdes:ibis:BlockReserved',newBlockName))
            end
            if~tree.containsBlock(newBlockName)&&tree.containsBlock(oldBlockName)
                blockNode=tree.getBlockNode(oldBlockName);
                blockNode.NodeName=newBlockName;
                tree.treeChanged
            end
        end
        function removeBlock(tree,blockName,saveonStack)


            if nargin<3
                saveonStack=false;
            end
            [blockin,blockIndex]=tree.containsBlock(blockName);
            if blockin
                blockNode=tree.getBlockNode(blockName);
                if saveonStack
                    blockArray{1}=blockIndex;
                    blockArray{2}=blockNode;
                    blockChildren=tree.getChildren(blockNode);
                    for childIndex=1:length(blockChildren)
                        child=blockChildren{childIndex};
                        if isa(child,'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter')
                            blockArray{end+1}=child;%#ok<AGROW>
                        elseif strcmp(child.NodeName,tree.TapFlag)
                            taps=tree.getChildren(child);
                            for tapIdx=1:length(taps)
                                tap=taps{tapIdx};
                                blockArray{end+1}=tap;%#ok<AGROW>
                            end
                        end
                    end
                    tree.UndoStack{end+1}=blockArray;
                end
                tree.deleteSubtree(blockNode);
            end
        end
        function popUndoStack(tree,blockName)




            for indx=length(tree.UndoStack):-1:1






                blockArray=tree.UndoStack{indx};
                blockNode=blockArray{2};
                if strcmpi(blockNode.NodeName,blockName)

                    tree.UndoStack(indx)=[];
                    tapNode=[];
                    blockIndex=blockArray{1}-1;
                    tree.addChild(tree.ModelSpecificNode,blockNode,false,blockIndex)
                    for parameterIdx=3:length(blockArray)
                        parameter=blockArray{parameterIdx};
                        if isa(parameter.Type,'serdes.internal.ibisami.ami.type.Tap')
                            if isempty(tapNode)


                                tapNode=serdes.internal.ibisami.ami.SerDesNode(tree.TapFlag);
                                tree.addChild(blockNode,tapNode);
                            end

                            tree.addChild(tapNode,parameter);
                        else


                            tree.addChild(blockNode,parameter)
                        end
                    end
                    break;
                end
            end
        end
        function clearUndoStack(tree)
            tree.UndoStack={};
        end
        function removeAmiParameterFromBlock(tree,blockName,amiParameterName,updateSources)


            if nargin<4
                updateSources=false;
            end
            param=tree.getParameterFromBlock(blockName,amiParameterName);
            if~isempty(param)
                if updateSources
                    serdes.internal.ibisami.ami.manageAmiSources('delete',tree,param)
                end
                tree.removeNode(param);
            end
        end
        function isTaps=isTapStructure(tree,node)


            isTaps=node.NodeName==tree.TapFlag;
        end
        function tapNode=getTapNode(tree,blockName)

            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        tapNode=child;
                        return;
                    end
                end
            end
            tapNode=[];
        end
        function tapWeights=getTapWeightsFromBlock(tree,blockName)

            tapWeights=[];
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        taps=tree.getChildren(child);
                        tapWeights=zeros(1,numel(taps));
                        for tapIdx=1:numel(taps)
                            tap=taps{tapIdx};
                            tapWeights(1,tapIdx)=tap.CurrentValue;
                        end
                        break;
                    end
                end
            end
        end
        function mainTap=getMainTapIndexOfBlock(tree,blockName)

            mainTap=-1;
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        mainTap=0;
                        taps=tree.getChildren(child);
                        for tapIdx=1:numel(taps)
                            tap=taps{tapIdx};
                            if tap.NodeName=="0"
                                mainTap=tapIdx;
                                break;
                            end
                        end
                        break;
                    end
                end
            end
        end
        function taps=getTapsOfBlock(tree,blockName)
            taps=[];
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        taps=tree.getChildren(child);
                    end
                end
            end
        end
        function usage=getTapsUsageOfBlock(tree,blockName)
            usage="In";
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        taps=tree.getChildren(child);
                        if numel(taps)>0
                            tap=taps{1};
                            usageObj=tap.Usage;
                            usage=usageObj.Name;
                            break;
                        end
                    end
                end
            end
        end
        function addOrUpdateTapsOfBlock(tree,blockName,vectorOfWeights,varargin)













            validateattributes(blockName,{'char','string'},{},...
            '','blockName',1)
            validateattributes(vectorOfWeights,{'double'},{'nonempty','nrows',1})

            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                isUpdate=false;
                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        isUpdate=true;
                    end
                end
                usage=tree.getTapsUsageOfBlock(blockName);
                [~,newMainTap]=max(abs(vectorOfWeights));
                usageChanged=false;
                updateSources=false;
                if numel(varargin)>0
                    tUsage=varargin{1};
                    if~isempty(tUsage)
                        usageChanged=~strcmpi(tUsage,usage);
                        usage=tUsage;
                    end
                end
                if numel(varargin)>1
                    if~isempty(varargin{2})
                        newMainTap=varargin{2};
                    end
                end
                if numel(varargin)>2
                    if~isempty(varargin{3})
                        updateSources=varargin{3};
                    end
                end
                if isUpdate



                    updateSources=updateSources&&usageChanged;

                    oldMainTap=tree.getMainTapIndexOfBlock(blockName);
                    if oldMainTap<=0&&numel(varargin)<=1

                        newMainTap=0;
                    end
                end
                tapDelayLine=serdes.internal.ibisami.ami.TappedDelayLine('name',tree.TapFlag,...
                'mainTapIndex',newMainTap,...
                'usage',usage,...
                'tapWeights',vectorOfWeights);
                if isUpdate
                    oldTaps=tree.getTapsOfBlock(blockName);



                    newTaps=tapDelayLine.Taps;
                    for newTapIndex=1:numel(newTaps)
                        newTap=newTaps(newTapIndex);
                        oldTap=tree.nodeByName(newTap.NodeName,oldTaps);
                        if~isempty(oldTap)













                            oldTapCopy=oldTap.copy;
                            oldTapCopy.CurrentValue=newTap.CurrentValue;
                            oldTapCopy.Usage=newTap.Usage;
                        end
                    end
                    if numel(oldTaps)~=numel(vectorOfWeights)||oldMainTap~=newMainTap



                        oldPreCount=oldMainTap-1;
                        oldPostCount=numel(oldTaps)-oldMainTap;
                        newPreCount=newMainTap-1;
                        newPostCount=numel(vectorOfWeights)-newMainTap;
                        msg="";
                        if oldPreCount~=newPreCount
                            numAddOrDel=abs(oldPreCount-newPreCount);
                            if oldPreCount>newPreCount
                                operation="Delete";
                                range=sort([newPreCount+1,oldPreCount]);
                            else
                                operation="Add";
                                range=sort([oldPreCount+1,newPreCount]);
                            end
                            if numAddOrDel==1
                                msg=msg+operation+" pre-cursor tap at position -"+range(1);
                            else
                                msg=msg+operation+" pre-cursor taps at positions -"+range(2)+" through -"+range(1);
                            end
                        end
                        if oldPostCount~=newPostCount
                            if msg~=""
                                msg=msg+" and "+newline;
                            end
                            numAddOrDel=abs(oldPostCount-newPostCount);
                            if oldPostCount>newPostCount
                                if msg==""
                                    operation="Delete";
                                else
                                    operation="delete";
                                end
                                range=sort([newPostCount+1,oldPostCount]);
                            else
                                if msg==""
                                    operation="Add";
                                else
                                    operation="add";
                                end
                                range=sort([oldPostCount+1,newPostCount]);
                            end
                            if numAddOrDel==1
                                msg=msg+operation+" post-cursor tap at position "+range(1);
                            else
                                msg=msg+operation+" post-cursor taps at positions "+range(1)+" through "+range(2);
                            end
                        end
                        msg=msg+"?"+newline+" New tap positions will be:";

                        for tapNum=newPreCount:-1:1
                            msg=msg+" -"+tapNum;
                        end

                        if newMainTap>0
                            msg=msg+" "+"Main";
                        end

                        for tapNum=1:newPostCount
                            msg=msg+" "+tapNum;
                        end
                        answer=questdlg(msg,"Confirm","OK","Cancel","OK");
                        if strcmp(answer,"Cancel")
                            error(message('serdes:ibis:TapChangesCanceled'))
                        end
                    end

                    tapNode=tree.getTapNode(blockName);
                    wasNew=tapNode.New;

                    tree.deleteTapsOfBlock(blockName,updateSources)
                end
                if tree.Broadcast
                    tree.Broadcast=false;
                    broadcastSetOff=true;
                else
                    broadcastSetOff=false;
                end
                tree.insertTappedDelayLine(blockNode,tapDelayLine)
                if updateSources
                    tapNode=tree.getTapNode(blockName);
                    serdes.internal.ibisami.ami.manageAMISources('add',tree,tapNode);
                end
                if isUpdate

                    tapNode=tree.getTapNode(blockName);
                    tree.setNodeNew(tapNode,wasNew);




                    for newTapIndex=1:numel(newTaps)
                        newTap=newTaps(newTapIndex);
                        oldTap=tree.nodeByName(newTap.NodeName,oldTaps);
                        if~isempty(oldTap)


                            oldTap.CurrentValue=newTap.CurrentValue;
                            oldTap.Usage=newTap.Usage;
                            tree.replaceNode(newTap,oldTap)
                        end
                    end
                end
                if broadcastSetOff
                    tree.Broadcast=true;
                end
            end
        end
        function deleteTapsOfBlock(tree,blockName,updateSources)
            if tree.Broadcast
                tree.Broadcast=false;
                broadcastSetOff=true;
            else
                broadcastSetOff=false;
            end
            if nargin<3
                updateSources=false;
            end
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                blockChildren=tree.getChildren(blockNode);
                for childIdx=1:numel(blockChildren)
                    child=blockChildren{childIdx};
                    if child.NodeName==tree.TapFlag
                        if updateSources
                            serdes.internal.ibisami.ami.manageAMISources('delete',tree,child);
                        end
                        tree.deleteSubtree(child)
                        break;
                    end
                end
            end
            if broadcastSetOff
                tree.Broadcast=true;
            end
        end
        function addAmiParameterToBlock(tree,blockName,parameter,updateSources)
            validateattributes(blockName,{'char','string'},{},...
            '','blockName',1)
            validateattributes(parameter,{'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter'},{},...
            '','parameterName',2)
            blockNode=tree.getBlockNode(blockName);
            if nargin<4
                updateSources=false;
            end
            if~isempty(blockNode)
                tree.addChild(blockNode,parameter)
            end
            if updateSources&&serdes.utilities.canWriteWorkSpace(tree.SimulinkWorkSpace)
                serdes.internal.ibisami.ami.manageAMISources('add',tree,parameter)
            end
        end
        function nameOfParameterStructMember=...
            addAmiInValueParameterToBlock(tree,blockName,amiParameterName,value)
            validateattributes(blockName,{'char','string'},{},...
            '','blockName',1)
            validateattributes(amiParameterName,{'char','string'},{},...
            '','amiParameterName',2)
            validateattributes(value,{'double','logical','char','string'},{},...
            '','value',3)
            nameOfParameterStructMember=[];
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)
                if isa(value,'logical')
                    if value
                        value="True";
                    else
                        value="False";
                    end
                    type="Boolean";
                elseif isreal(value)&&~isnan(value)&&~isinf(value)
                    value=mat2str(value);
                    type="Float";
                else
                    error(message('serdes:ibis:MustBeNumericOrLogical'))
                end
                format="Value "+value;
                parameter=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(...
                'name',amiParameterName,...
                'format',format,...
                'type',type,...
                'Usage','In');
                tree.addChild(blockNode,parameter)
                nameOfParameterStructMember=blockName+"Parameter."+amiParameterName;
            end
        end
        function hideNode(tree,node,hidden)
            if node.Hidden~=hidden
                node.Hidden=hidden;
                tree.treeChanged
            end
        end
        function setNodeCurrentValue(tree,node,currentValue)
            if isa(node,'serdes.internal.ibisami.ami.parameter.ReservedParameter')
                tree.setReservedParameterCurrentValue(node.NodeName,currentValue)
            else
                if ischar(currentValue)
                    currentValue=string(currentValue);
                end
                try
                    if node.CurrentValue~=currentValue
                        node.CurrentValue=currentValue;
                        tree.treeChanged
                    end
                catch ex
                    if strcmp(ex.identifier,'MATLAB:string:ComparisonNotDefined')
                        node.CurrentValue=currentValue;
                        tree.treeChanged
                    else
                        rethrow(ex)
                    end
                end
            end
        end
        function hideReservedParameter(tree,reservedParameterName,hidden)
            parameter=tree.getReservedParameter(reservedParameterName);
            if~isempty(parameter)
                tree.hideNode(parameter,hidden);
            end
        end
        function hideParameterOfBlock(tree,blockName,amiParameterName,hidden)
            parameter=tree.getParameterFromBlock(blockName,amiParameterName);
            if~isempty(parameter)
                tree.hideNode(parameter,hidden)
            end
        end
        function hideTapsOfBlock(tree,blockName,hidden)
            if tree.Broadcast
                tree.Broadcast=false;
                broadcastSetOff=true;
            else
                broadcastSetOff=false;
            end
            blockNode=tree.getBlockNode(blockName);
            if~isempty(blockNode)

                nodesOfBlock=tree.getChildren(blockNode);
                for nodeIdx=1:numel(nodesOfBlock)
                    nodeOfBlock=nodesOfBlock{nodeIdx};
                    if nodeOfBlock.NodeName==tree.TapFlag

                        taps=tree.getChildren(nodeOfBlock);
                        for tapIdx=1:numel(taps)
                            tap=taps{tapIdx};
                            tree.hideNode(tap,hidden)
                        end

                        tree.hideNode(nodeOfBlock,hidden)
                        break
                    end
                end
            end
            if broadcastSetOff
                tree.Broadcast=true;
            end
        end
        function manageAmiDebug(tree)
            param=tree.getReservedParameter("DLL_ID");
            if~isempty(param)
                adbName=tree.AMIDebugBlock;
                debugBlock=tree.getBlockNode(adbName);
                if isempty(debugBlock)


                    debugBlock=serdes.internal.ibisami.ami.SerDesNode(adbName);
                    tree.addChild(tree.ModelSpecificNode,debugBlock);
                    debugBlock.Description="Parameters used to manage debug output of the dll.";

                    enable=serdes.internal.ibisami.ami.parameter.ami_debug.Enable;
                    startTime=serdes.internal.ibisami.ami.parameter.ami_debug.Start_Time;
                    tree.addChild(debugBlock,enable)
                    tree.addChild(debugBlock,startTime)
                else
                    enable=tree.getParameterFromBlock(adbName,"Enable");
                    startTime=tree.getParameterFromBlock(adbName,"Start_Time");
                end
                enable.Hidden=param.Hidden;
                startTime.Hidden=param.Hidden;
                debugBlock.Hidden=param.Hidden;
                tree.treeChanged
            end
        end
    end
    methods
        function setVersionNeeded(tree)
            reservedParameters=tree.getReservedParameters;
            ver=6.1;
            amiVersionParameter=tree.getReservedParameter("AMI_Version");
            if isempty(amiVersionParameter)
                return
            end
            for paramIdx=1:numel(reservedParameters)
                reservedParameter=reservedParameters{paramIdx};
                if reservedParameter~=amiVersionParameter&&...
                    ~reservedParameter.Hidden
                    ver=max(ver,reservedParameter.EarliestRequiredVersion);
                end
            end
            amiVersionParameter.CurrentValue=string(sprintf('%1.1f',ver));
        end
        function setNodeNew(tree,node,new)
            if isa(node,'serdes.internal.ibisami.ami.SerDesNode')
                node.New=new;
                tree.treeChanged
            end
        end
        function treeStruct=serDesStruct(tree,varargin)
            if nargin<2
                targetNode=tree.getRootNode;
            else
                targetNode=varargin{1};
            end
            treeStruct=generateSerDesStruct(tree,targetNode,false,[]);
        end
        function[InInOutStruct,InOutOutStruct]=simulinkStructs(tree,node)
            InInOutStruct=generateSerDesStruct(tree,node,true,["Info","Out"]);
            InOutOutStruct=generateSerDesStruct(tree,node,true,["Info","In"]);
        end
        function simStruct=simulinkStruct(tree,node)
            simStruct=generateSerDesStruct(tree,node,true,["Info"]);%#ok<NBRAK>
        end

        function removeNode(tree,node,addAmiSources)
            if nargin<3
                addAmiSources=false;
            end
            if addAmiSources&&serdes.utilities.canWriteWorkSpace(tree.SimulinkWorkSpace)
                serdes.internal.ibisami.ami.manageAMISources('delete',tree,node)
            end
            removeNode@serdes.internal.ibisami.ami.Tree(tree,node);
        end
        function replaceNode(tree,oldNode,newNode,updateSources)
            if nargin<4
                updateSources=false;
            end
            if updateSources&&serdes.utilities.canWriteWorkSpace(tree.SimulinkWorkSpace)
                serdes.internal.ibisami.ami.manageAMISources('delete',tree,oldNode)
            end
            replaceNode@serdes.internal.ibisami.ami.Tree(tree,oldNode,newNode);
            if updateSources&&serdes.utilities.canWriteWorkSpace(tree.SimulinkWorkSpace)
                serdes.internal.ibisami.ami.manageAMISources('add',tree,newNode)
            end
        end
        function addChild(tree,parent,child,addAmiSources,insertIdx)
            validateattributes(child,{'serdes.internal.ibisami.ami.SerDesNode'},{'scalar'},"addChild","child")
            if nargin<4
                addAmiSources=false;
            end
            if nargin<5
                addChild@serdes.internal.ibisami.ami.Tree(tree,parent,child);
            else
                addChild@serdes.internal.ibisami.ami.Tree(tree,parent,child,insertIdx);
            end
            if addAmiSources&&serdes.utilities.canWriteWorkSpace(tree.SimulinkWorkSpace)
                serdes.internal.ibisami.ami.manageAMISources('add',tree,child)
            end
        end
        function insertTappedDelayLine(tree,parentNode,tappedDelayLine)
            validateattributes(tappedDelayLine,{'serdes.internal.ibisami.ami.TappedDelayLine'},{'scalar'},...
            "insertTappedDelayLine","tappedDelayLine")
            delaylineName=tappedDelayLine.Name;
            delayLineNode=serdes.internal.ibisami.ami.SerDesNode(delaylineName);
            tree.addChild(parentNode,delayLineNode)
            taps=tappedDelayLine.Taps;
            for tapIndex=1:length(taps)
                tap=taps(tapIndex);
                tree.addChild(delayLineNode,tap)
            end
        end
        function createStructsAndParameters(tree,varargin)
            if numel(varargin)>0
                fromSimulinkExport=varargin{1};
                if islogical(fromSimulinkExport)
                    tree.UsesSimulinkWorkSpace=fromSimulinkExport;
                end
            end
            if tree.UsesSimulinkWorkSpace
                serdes.internal.ibisami.ami.createStructsAndParameters(tree)
            end
        end
        function setPaths2Nodes(tree)
            serdes.internal.ibisami.ami.setPaths2Nodes(tree)
        end
        function updateCurrentValue(tree,pathToParameter,value)
            if ischar(value)
                value=string(value);
            end
            amiParameter=tree.getParamFromPath(pathToParameter);
            if amiParameter.CurrentValue~=value
                amiParameter.CurrentValue=value;
                tree.treeChanged
            end
        end
        function param=getParamFromPath(tree,path)
            param=[];
            path=char(path);
            if tree.Paths2Nodes.isKey(path)
                param=tree.Paths2Nodes(path);
            end
        end
        function treeStruct=generateSerDesStruct(tree,targetNode,useCurrentValue,excludedUsages)
            if isstring(targetNode)||ischar(targetNode)
                targetNode=tree.getBlockNode(targetNode);
            end
            if isempty(targetNode)
                treeStruct=struct;
                return
            end
            validateattributes(targetNode,{'serdes.internal.ibisami.ami.SerDesNode'},{'scalar'},"generateSerDesStruct","targetNode")
            baseNodeId=targetNode.NodeId;


            tree.clearVisited;
            params=tree.getAllAmiParameters;
            nextParamIndex=0;
            for paramIdx=1:length(params)
                param=params{paramIdx};
                if tree.isDecendantOf(targetNode,param)
                    usageName=param.Usage.Name;
                    if~any(strcmpi(excludedUsages,usageName))
                        currentNode=param;
                        currentNode.Visited=true;
                        nextParamIndex=nextParamIndex+1;
                        while tree.getParent(currentNode).NodeId~=baseNodeId
                            currentNode=tree.getParent(currentNode);
                            currentNode.Visited=true;
                        end
                    end
                end
            end
            treeStruct=recursivelyGetSubTreeStruct(tree,targetNode,useCurrentValue);
        end
    end
    methods
        function validatedNode=validateNode(tree,node)



            node=validateNode@serdes.internal.ibisami.ami.Tree(tree,node);
            if isa(node,'serdes.internal.ibisami.ami.SerDesNode')
                if isa(node,'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter')
                    type=node.Type;
                    usage=node.Usage;
                    if~isempty(type)&&~isempty(usage)
                        if isa(type,'serdes.internal.ibisami.ami.type.String')&&...
                            ~isa(usage,'serdes.internal.ibisami.ami.usage.Info')
                            error(message('serdes:ibis:NoStringUnlessInfo'))
                        end
                    end
                end
                validatedNode=node;
            else
                error(message('serdes:ibis:MustBeSerDesNode'))
            end
        end
        function emptyNode=getEmptyNode(~)

            emptyNode=serdes.internal.ibisami.ami.SerDesNode.empty;
        end
    end
    methods(Access=protected)
        function ok=validateTreeName(~,treeName)
            ok=serdes.internal.ibisami.ami.VerifySerDesNodeName(treeName);
        end
        function treeChanged(tree)
            if isvalid(tree)&&tree.Broadcast
                tree.dirty=false;
                tree.notify('TreeChanged')
                tree.createStructsAndParameters
                tree.setVersionNeeded
            end
        end
    end
    methods(Access=protected)
        function addGeneralParameters(tree)



            maxInitAggressors=serdes.internal.ibisami.ami.parameter.general.MaxInitAggressors;
            maxInitAggressors.CurrentValue=tree.MaxInitAggressorsValue;
            tree.addChild(tree.ReservedParametersNode,maxInitAggressors)
        end
        function treeStruct=recursivelyGetSubTreeStruct(tree,targetNode,useCurrentValue)
            treeStruct=struct;
            children=tree.getChildren(targetNode);
            childValues={};
            childValueFields=[];
            childVisitedIndex=0;
            for childIndex=1:length(children)
                child=children{childIndex};
                if child.Visited
                    if isa(child,'serdes.internal.ibisami.ami.parameter.AmiParameter')


                        if useCurrentValue
                            childValue=child.CurrentValue;
                            if isempty(childValue)
                                childValue=child.Default;
                            end
                        else
                            childValue=child;
                        end
                        childField=serdes.internal.ibisami.ami.RepairSerDesParameterName(child.NodeName);
                    else
                        childValue=tree.recursivelyGetSubTreeStruct(child,useCurrentValue);
                        childField=child.NodeName;


                        if useCurrentValue&&strcmpi(childField,tree.TapFlag)
                            childValue=struct2array(childValue);
                        end
                    end
                    childVisitedIndex=childVisitedIndex+1;
                    childValues{childVisitedIndex}=childValue;%#ok<AGROW>
                    childField=string(childField);
                    childValueFields=[childValueFields;childField];%#ok<AGROW>
                end
            end
            if isempty(childValues)
                return
            end
            childValues=childValues';
            treeStruct=cell2struct(childValues,childValueFields,1);
        end
    end
    methods
        function addLegacyModulationParameters(tree)

            modulation=serdes.internal.ibisami.ami.parameter.modulation.Modulation;
            modulation.Usage=serdes.internal.ibisami.ami.usage.In;
            modulation.CurrentValue="NRZ";
            tree.addChild(tree.ReservedParametersNode,modulation)
            centerOffset=serdes.internal.ibisami.ami.parameter.modulation.Pam4CenterThreshold;
            centerOffset.Usage=serdes.internal.ibisami.ami.usage.Out;
            centerOffset.Hidden=true;
            tree.addChild(tree.ReservedParametersNode,centerOffset)
            upperOffset=serdes.internal.ibisami.ami.parameter.modulation.Pam4UpperThreshold;
            upperOffset.Usage=serdes.internal.ibisami.ami.usage.Out;
            upperOffset.Hidden=true;
            tree.addChild(tree.ReservedParametersNode,upperOffset)
            lowerOffset=serdes.internal.ibisami.ami.parameter.modulation.Pam4LowerThreshold;
            lowerOffset.Usage=serdes.internal.ibisami.ami.usage.Out;
            lowerOffset.Hidden=true;
            tree.addChild(tree.ReservedParametersNode,lowerOffset)
        end
        function removeLegacyModulationParameters(tree)
            listOfLegacyParameters=["Modulation","Pam4_CenterThreshold","Pam4_UpperThreshold","Pam4_LowerThreshold"];
            for paraIdx=1:length(listOfLegacyParameters)
                param=tree.getReservedParameter(listOfLegacyParameters(paraIdx));
                if~isempty(param)
                    tree.removeNode(param);
                end
            end
        end
        function addModulationParameters(tree)

            modulation=serdes.internal.ibisami.ami.parameter.modulation.ModulationLevels;
            modulation.CurrentValue=2;
            tree.addChild(tree.ReservedParametersNode,modulation)
            pamThresholds=serdes.internal.ibisami.ami.parameter.modulation.PAMThresholds;
            pamThresholds.Hidden=true;
            tree.addChild(tree.ReservedParametersNode,pamThresholds)
        end
        function removeModulationParameters(tree)
            listOfLegacyParameters=["Modulation_Levels","PAM_Thresholds"];
            for paraIdx=1:length(listOfLegacyParameters)
                param=tree.getReservedParameter(listOfLegacyParameters(paraIdx));
                if~isempty(param)
                    tree.removeNode(param);
                end
            end
        end
        function setModulationFormat(tree,useSwitchableModulation,listContents)
            if nargin==2
                listContents=["NRZ","PAM4"];
            end
            tree.UseSwitchableModulation=useSwitchableModulation;
            modulation=tree.getReservedParameter("Modulation");
            modulationLevels=tree.getReservedParameter("Modulation_Levels");
            if~isempty(modulation)
                if useSwitchableModulation
                    if~isa(listContents,"string")
                        listContents=serdes.internal.callbacks.convertModulation(listContents);
                    end
                    fmt=serdes.internal.ibisami.ami.format.List(listContents);
                else
                    modulationCV=modulation.CurrentValue;
                    fmt=serdes.internal.ibisami.ami.format.Value(modulationCV);
                end
                modulation.Format=fmt;
                if strcmp(modulation.CurrentValue,"NRZ")
                    thresholdsHidden=~tree.UseSwitchableModulation;
                    centerThreshold=tree.getReservedParameter("Pam4_CenterThreshold");
                    if~isempty(centerThreshold)
                        centerThreshold.Hidden=thresholdsHidden;
                    end
                    upperThreshold=tree.getReservedParameter("Pam4_UpperThreshold");
                    if~isempty(upperThreshold)
                        upperThreshold.Hidden=thresholdsHidden;
                    end
                    lowerThreshold=tree.getReservedParameter("Pam4_LowerThreshold");
                    if~isempty(lowerThreshold)
                        lowerThreshold.Hidden=thresholdsHidden;
                    end
                end
            elseif~isempty(modulationLevels)
                if useSwitchableModulation
                    fmt=serdes.internal.ibisami.ami.format.List(listContents);


                else
                    modulationCV=modulationLevels.CurrentValue;
                    fmt=serdes.internal.ibisami.ami.format.Value(modulationCV);
                end
                modulationLevels.Format=fmt;
                if modulationLevels.CurrentValue==2
                    thresholdsHidden=~tree.UseSwitchableModulation;
                    thresholds=tree.getReservedParameter("PAM_Thresholds");
                    if~isempty(thresholds)
                        thresholds.Hidden=thresholdsHidden;
                    end
                end
            end
            tree.treeChanged
        end
    end
end
classdef RoutineParser<handle








    properties(Access=private)

        RoutinePath(1,:)char;
        Ctx(1,1)plccore.common.Context;
        Pou(1,1);
        Routine;
        PowerStartBlk(1,:)double;
        RungStartEndInfo;



        RungsGraph(1,:)plccore.frontend.model.LadderNode;
        AllNodes(1,:)plccore.frontend.model.LadderNode;
        AllNodesMap;
        Instruction2IRObj;
        commentHandler;

        RungTerminalIndex;
        Debug(1,:)logical;
        RungBlkTouchMap;
        RungBlkOwnerMap;
    end

    methods
        function obj=RoutineParser(routinePath,ctx,pou,routine)
            obj.RoutinePath=routinePath;
            obj.Ctx=ctx;
            obj.Pou=pou;
            obj.Routine=routine;
            obj.commentHandler=plccore.util.CommentHandler(routinePath);
            obj.Debug=plcfeature('PLCLadderDebug');

            obj.AllNodesMap=containers.Map('KeyType','double',...
            'ValueType','double');
            obj.PowerStartBlk=[];
            obj.RungStartEndInfo=[];
            obj.RungStartEndInfo.start=[];
            obj.RungStartEndInfo.end=[];

            import plccore.frontend.model.LadderNode;
            obj.RungsGraph=LadderNode.empty;
            obj.clearNodes;
        end

        function out=startParsing(obj)
            obj.setPowerStartAndRungTerminalBlocks;
            obj.generateRungGraph;
            obj.setRungStartBlks;
            import plccore.frontend.L5X.Instruction2IR;
            obj.Instruction2IRObj=Instruction2IR(obj.Ctx,obj.Pou,'',false);
            obj.generateRungsIR();
            out=obj.Pou;
        end

        function out=getGraph(obj)
            out=obj.RungsGraph;
        end

        function dumpRungGraph(obj,rungID)


            validateattributes(rungID,{'double'},{'nonempty'});

            rungCount=length(obj.RungsGraph);
            if rungCount==0
                disp('No rungs found in the ladder IR. No dump can be generated');
            elseif rungID<1||rungID>rungCount
                disp(['Invalid input value of rungID : ',num2str(rungID)...
                ,'. Expected values from 1 to ',num2str(rungCount),'.']);
            else
                disp(obj.RungsGraph(rungID));
            end
        end
    end

    methods(Access=private)
        function generateRungsIR(obj)


            import plccore.frontend.model.RoutineParser;
            import plccore.ladder.LadderDiagram;
            rungObjs=obj.getRungBlks;
            if obj.Debug
                fprintf('\n%s : %s Rungs start : \n',obj.Pou.name,obj.Routine.name);
            end
            LD=LadderDiagram.createLadderDiagram(obj.Routine);
            if~anyRungsFound(obj)
                return;
            end
            for ii=1:length(rungObjs)
                currentrungIR=LD.createRung(obj.commentHandler.getComment(rungObjs(ii).end));
                if obj.Debug
                    fprintf('Rung : %s\n',num2str(ii));
                end
                obj.rungTerminalBeingProcessed(ii);
                obj.RungBlkTouchMap=containers.Map('KeyType','double','ValueType','double');
                obj.RungBlkOwnerMap=containers.Map('KeyType','double','ValueType','double');

                terminalNode=obj.blockToNode(rungObjs(ii).end);
                rungOps=obj.appendToChain2(terminalNode,[]);

                if isempty(rungOps)
                    currentrungIR.clear();
                    plccore.common.plcThrowError('plccoder:plccore:LadderDiagramWithEmptyRungs',num2str(obj.rungTerminalBeingProcessed()-1),obj.RoutinePath);
                elseif isa(rungOps,'plccore.ladder.RungOpAtom')
                    currentrungIR.appendRungOp(rungOps);
                elseif isa(rungOps,'plccore.ladder.RungOpFBCall')
                    currentrungIR.appendRungOp(rungOps);
                elseif isa(rungOps,'plccore.ladder.RungOpPar')
                    currentrungIR.appendRungOp(rungOps);
                else
                    rungOps=rungOps.rungOps;
                    for v=1:length(rungOps)
                        currentrungIR.appendRungOp(rungOps{v});
                    end
                end

            end
            obj.rungTerminalBeingProcessed(-1);
            if obj.Debug
                fprintf('\n%s Rungs end : \n',obj.Pou.name);
            end
        end

        function ir=getIRforBlock(obj,blkHdl)
            import plccore.type.*;
            import plccore.common.*;
            import plccore.expr.*;
            import plccore.ladder.*;
            import plccore.frontend.model.RoutineParser;
            import plccore.frontend.ModelParser;

            instr=slplc.api.getPOU(blkHdl);
            if strcmpi(instr.PLCBlockType,'UnknownInstr')
                plccore.common.plcThrowError('plccoder:plccore:UnknownInstrNotSupported',instr.PLCUnknownInstrName,obj.Pou.name);
            end

            instrName=instr.PLCBlockType;
            [readOperands,writeOperands]=RoutineParser.getReadWriteOperandNamesForInstr(blkHdl);

            if strcmpi(instr.PLCPOUType,'Function Block')

                opTagName=instr.PLCOperandTag;
                instrName=instr.PLCPOUName;


                if ModelParser.incompleteAOIListObj.ismember(instrName)
                    generateIRForIncompleteAOI(obj,blkHdl,instrName);
                end

                [readOperands,writeOperands]=RoutineParser.getReadWriteOperandNamesForInstr(blkHdl);
                [readLabels,writeLabels]=RoutineParser.getReadWritePortLabelsForInstr(blkHdl);
                varList=slplc.utils.getVariableList(blkHdl);
                varNames={varList.Name};
                filterIdx=ismember(varNames,[readLabels;writeLabels]');
                varNames=varNames(filterIdx);
                operands=[readOperands,writeOperands];
                [~,sortIdx]=ismember(varNames,[readLabels;writeLabels]');
                operands=[{opTagName},operands(sortIdx)];
            elseif strcmpi(instr.PLCPOUType,'Subroutine')
                routine_name=instr.PLCPOUName;
                progLocalScope=obj.Pou.localScope;
                if~progLocalScope.hasSymbol(routine_name)

                    routineBlk=slplc.utils.getInternalBlockPath(blkHdl,'Logic');
                    routineIR=obj.Pou.createRoutine(routine_name);
                    routineParser=RoutineParser(routineBlk,obj.Ctx,obj.Pou,routineIR);
                    routineParser.startParsing;
                end
                instrName='JSR';
                operands={routine_name};
            elseif isempty(instr.PLCOperandTag)&&isempty(readOperands)&&isempty(writeOperands)




                if ismember(instrName,{'JMP','LBL'})
                    operands={instr.PLCLabelTag};
                else
                    operands={};
                end
            elseif~isempty(instr.PLCOperandTag)















                if ismember(instrName,{'CPT'})
                    assert(~isempty(writeOperands),'CPT block %s should have at least one output',getfullname(blkHdl));
                    operands={writeOperands{1},instr.PLCOperandTag};
                elseif ismember(instrName,{'TON','CTD','CTU','RTO','TOF'})
                    opTagName=instr.PLCOperandTag;
                    operands={opTagName,'?','?'};
                elseif ismember(instrName,{'OSR','OSF'})
                    assert(~isempty(writeOperands),'ONS/OSF block %s should have at least one output',getfullname(blkHdl));
                    operands={instr.PLCOperandTag,writeOperands{1}};
                elseif ismember(instrName,{'COP'})
                    assert(isfield(instr,'PLCSrcArrayIndex'),[instrName,' block should have parameter ''PLCSrcArrayIndex''']);
                    assert(isfield(instr,'PLCDestArrayIndex'),[instrName,' block should have parameter ''PLCDestArrayIndex''']);
                    assert(length(readOperands)==2,'COP block %s should have at least one input',getfullname(blkHdl));
                    [dstArrayMLIndex,destok]=str2num(instr.PLCDestArrayIndex);
                    assert(destok,[instrName,' block parameter ''PLCDestArrayIndex'' cannot be converted to number']);
                    [srcArrayMLIndex,srcok]=str2num(instr.PLCSrcArrayIndex);
                    assert(srcok,[instrName,' block parameter ''PLCSrcArrayIndex'' cannot be converted to number']);

                    srcExprStr=readOperands{1};
                    srcExprStrNew=obj.MLtoRockwellExprStr(srcExprStr,srcArrayMLIndex);


                    destExprStr=instr.PLCOperandTag;
                    destExprStrNew=obj.MLtoRockwellExprStr(destExprStr,dstArrayMLIndex);


                    lengthStr=readOperands{2};
                    operands={srcExprStrNew,destExprStrNew,lengthStr};
                elseif ismember(instrName,{'FLL'})
                    assert(isfield(instr,'PLCDestArrayIndex'),[instrName,' block should have parameter ''PLCDestArrayIndex''']);
                    assert(length(readOperands)==2,'FLL block %s should have at least one input',getfullname(blkHdl));
                    [dstArrayMLIndex,destok]=str2num(instr.PLCDestArrayIndex);
                    assert(destok,[instrName,' block parameter ''PLCDestArrayIndex'' cannot be converted to number']);


                    srcExprStrNew=readOperands{1};


                    destExprStr=instr.PLCOperandTag;
                    destExprStrNew=obj.MLtoRockwellExprStr(destExprStr,dstArrayMLIndex);


                    lengthStr=readOperands{2};
                    operands={srcExprStrNew,destExprStrNew,lengthStr};
                else
                    operands={instr.PLCOperandTag};
                end
            elseif isempty(instr.PLCOperandTag)


















                if ismember(instrName,{'COP','FBC'})
                    assert(false,'FLL FBC and COP parsing implementation not complete');
                else
                    operands=[readOperands,writeOperands];
                end
            else
                assert(false);
            end
            ir=obj.Instruction2IRObj.getIRforInstruction(instrName,operands);

        end

        function exprStrNew=MLtoRockwellExprStr(obj,exprStr,arrayIndexNum)



            exprIR=plccore.frontend.L5X.util.getLadderExpr(obj.Ctx,obj.Pou,'',exprStr);
            destType=plccore.common.Utils.getTypeFromExpr(obj.Ctx,obj.Pou,exprIR);

            if isa(destType,'plccore.type.ArrayType')
                exprStrNew=[exprStr,'[',num2str(arrayIndexNum),']'];
            else
                exprStrNew=exprStr;
            end
        end

        function[tf,pou]=doesPOUDataDefExist(obj)
            pou=[];
            import plccore.frontend.ModelParser;
            [isLadderBlock,ladderInfo]=ModelParser.isLadderBlock(obj.RoutinePath);
            if isLadderBlock&&...
                strcmpi(ladderInfo.PLCPOUType,'function block')
                pouIdentifierName=matlab.lang.makeValidName(ladderInfo.PLCPOUName);
                tf=obj.Ctx.configuration.globalScope.hasSymbol(pouIdentifierName);
                if tf
                    pou=obj.Ctx.configuration.globalScope.getSymbol(pouIdentifierName);
                end
            else
                tf=false;
            end
        end

        function generateIRForIncompleteAOI(obj,currentPOUPath,aoiName)


            import plccore.frontend.model.POUParser;
            import plccore.frontend.ModelParser;
            ModelParser.incompleteAOIListObj.removeAOI(aoiName);
            if isnumeric(currentPOUPath)
                currentPOUPath=getfullname(currentPOUPath);
            end

            SLLDPOUProcessor=POUParser(currentPOUPath,obj.Ctx);
            SLLDPOUProcessor.startParsing();
        end
    end

    methods(Access=private)

        function setRungStartBlks(obj)


            import plccore.frontend.model.RoutineParser;
            if~isempty(obj.RungStartEndInfo(1).start)
                obj.RungStartEndInfo.start=[];
                obj.RungStartEndInfo.end=[];
            end

            for ii=1:length(obj.RungsGraph)
                rungIndex=ii;
                rungPowerNode=obj.RungsGraph(rungIndex);
                for iii=1:length(rungPowerNode.NextNode)

                    rungStartNode=rungPowerNode.NextNode(iii);

                    if isempty(obj.RungStartEndInfo(rungIndex).start)
                        obj.RungStartEndInfo(rungIndex).start=rungStartNode.BlkHdl;
                    else
                        obj.RungStartEndInfo(rungIndex).start(end+1)=rungStartNode.BlkHdl;
                    end
                end
            end
        end

        function setPowerStartAndRungTerminalBlocks(obj)
            import plccore.frontend.model.RoutineParser.*;
            ldobj=get_param(obj.RoutinePath,'UDDObject');
            allblocksinLogic=ldobj.getCompiledBlockList;

            for ii=1:length(allblocksinLogic)
                curblk=allblocksinLogic(ii);
                if isRungTerminalBlock(curblk)
                    rtIndex=getRungTerminalIndex(curblk);
                    obj.RungStartEndInfo(rtIndex).end=curblk;
                elseif isPowerStartBlock(curblk)
                    obj.PowerStartBlk(end+1)=curblk;
                end
            end


            if isempty(obj.PowerStartBlk)
                ladderBlkName=get_param(obj.RoutinePath,'name');
                error('PLC:ladder2IR:PowerStartBlkInvalid',['No power start block found in ladder rungs block : ',ladderBlkName,'Invalid ladder diagram.']);
            end
        end

        function out=getRungBlks(obj)
            out=obj.RungStartEndInfo;
        end

        function clearNodes(obj)
            import plccore.frontend.model.LadderNode;
            obj.AllNodes=LadderNode.empty;
            obj.AllNodesMap=containers.Map('KeyType','double',...
            'ValueType','double');
        end

        function generateRungGraph(obj)






            for ii=1:length(obj.RungStartEndInfo)
                if~anyRungsFound(obj)
                    plccore.common.plcThrowError('plccoder:plccore:LadderDiagramWithNoRungs',obj.RoutinePath);
                end
                obj.rungTerminalBeingProcessed(ii);
                obj.appendToRungGraphIR(obj.RungStartEndInfo(ii).end,[]);
                if obj.Debug==10
                    fprintf('Rung graph representation for rung %s\n',num2str(ii));
                    obj.dumpRungGraph(ii);
                end
            end
            obj.rungTerminalBeingProcessed(-1);

        end

        function tf=anyRungsFound(obj)
            tf=true;
            if isempty(obj.RungStartEndInfo(1).end)
                tf=false;
            end
        end

        function tf=isRungEmpty(~,rungIR)
            tf=false;
            if isempty(rungIR)
                tf=true;
            end
        end

        function appendToRungGraphIR(obj,blkHdl,lastNode)
            import plccore.frontend.model.RoutineParser;


            [currentNode,nodeExistedAlready]=blockToNode(obj,blkHdl);

            if RoutineParser.isRungTerminalBlock(blkHdl)
                currentNode.willHaveNoSuccessors;


                prevPort=RoutineParser.getSrcBlkOuputPorts(blkHdl);
                prevBlk=RoutineParser.getBlockfromPort(prevPort);


                obj.appendToRungGraphIR(prevBlk,currentNode);

            elseif RoutineParser.isPowerStartBlock(blkHdl)
                assert(currentNode.RungID==obj.rungTerminalBeingProcessed);
                powerStartNode=currentNode;

                powerStartNode.insertSuccessor(lastNode);
                lastNode.insertPredecessor(currentNode);
                powerStartNode.willHaveNoPredecessors;
            else

                currentNode.insertSuccessor(lastNode);
                lastNode.insertPredecessor(currentNode);

                prevPorts=RoutineParser.getSrcBlkOuputPorts(blkHdl);

                if RoutineParser.isParallelJunctionBlock(blkHdl)
                    assert(length(prevPorts)==2);


                    prevBlks(1)=RoutineParser.getBlockfromPort(prevPorts(1));
                    prevBlks(2)=RoutineParser.getBlockfromPort(prevPorts(2));

                    if~nodeExistedAlready
                        obj.appendToRungGraphIR(prevBlks(1),currentNode);
                        obj.appendToRungGraphIR(prevBlks(2),currentNode);
                    end


                    obj.setPredecessor(currentNode,prevBlks(1));
                    obj.setPredecessor(currentNode,prevBlks(2));

                else
                    assert(length(prevPorts)>=1);






                    prevBlks(1)=RoutineParser.getBlockfromPort(prevPorts(1));
                    if~nodeExistedAlready
                        obj.appendToRungGraphIR(prevBlks(1),currentNode);
                    end


                    obj.setPredecessor(currentNode,prevBlks(1));
                end
            end


        end

        function[currentNode,nodeExistedAlready]=blockToNode(obj,blkHdl)
            import plccore.frontend.model.RoutineParser;
            import plccore.frontend.model.LadderNode;

            if obj.doesNodeAlreadyExist(blkHdl)
                currentNode=obj.getExistingNodeForBlk(blkHdl);
                nodeExistedAlready=true;
            else

                currentNode=LadderNode(blkHdl,obj.rungTerminalBeingProcessed);
                if RoutineParser.isPowerStartBlock(blkHdl)
                    nodeExistedAlready=false;
                    if isempty(obj.RungsGraph)
                        obj.RungsGraph=currentNode;
                    else
                        if length(obj.RungsGraph)<obj.rungTerminalBeingProcessed
                            obj.RungsGraph(obj.rungTerminalBeingProcessed)=currentNode;
                        else

                            currentNode=obj.RungsGraph(obj.rungTerminalBeingProcessed);
                            nodeExistedAlready=true;
                        end
                    end
                else

                    obj.insertIntoExistingNodesMap(currentNode);
                    nodeExistedAlready=false;
                end

            end
        end

        function insertIntoExistingNodesMap(obj,node)
            assert(isa(node,'plccore.frontend.model.LadderNode'));

            if~obj.doesNodeAlreadyExist(node.BlkHdl)
                obj.AllNodes(end+1)=node;
                index=length(obj.AllNodes);
                obj.AllNodesMap(node.BlkHdl)=index;
            end

        end

        function out=doesNodeAlreadyExist(obj,blkHdl)
            if obj.AllNodesMap.isKey(blkHdl)
                out=true;
            else
                out=false;
            end
        end

        function out=getExistingNodeForBlk(obj,blkHdl)

            index=obj.AllNodesMap(blkHdl);
            assert(~isempty(index));
            out=obj.AllNodes(index);
            assert(~isempty(out));
            assert(isa(out,'plccore.frontend.model.LadderNode'));
        end

        function setPredecessor(obj,currentNode,prevBlkHandle)
            import plccore.frontend.model.RoutineParser;
            if~RoutineParser.isPowerStartBlock(prevBlkHandle)
                prevNode1=obj.getExistingNodeForBlk(prevBlkHandle);
                currentNode.insertPredecessor(prevNode1);
            end
        end

        function[newIR,turnAroundNode]=appendToChain2(obj,currentNode,existingIR)











            import plccore.frontend.model.RoutineParser;


            assert(~isempty(currentNode),'current node cannot be empty');
            if RoutineParser.isRungTerminalBlock(currentNode.BlkHdl)


                assert(isempty(existingIR),'existing chain should be empty for rung terminal block');

                obj.confirmRungEndsAtCorrectTerminal(currentNode.BlkHdl);

                prevNode=currentNode.PrevNode;
                assert(length(prevNode)==1,'The block before rung terminal has to be a single ladder block or the junction block');
                [newIR,turnAroundNode]=appendToChain2(obj,prevNode,existingIR);
                assert(RoutineParser.isPowerStartBlock(turnAroundNode.BlkHdl),'Overall turnaround node should be a power start block');

            elseif RoutineParser.isPowerStartBlock(currentNode.BlkHdl)

                assert(currentNode.RungID==obj.rungTerminalBeingProcessed);
                turnAroundNode=currentNode;
                newIR=existingIR;
                return;
            else

                RoutineParser.confirmDestBlocksConnectivity(currentNode);
                if RoutineParser.isParallelJunctionBlock(currentNode.BlkHdl)
                    prevNode=currentNode.PrevNode;
                    assert(length(prevNode)==2,'Junction block should have two previous nodes');


                    [serialIR1,turnAroundNode1]=appendToChain2(obj,prevNode(1),[]);
                    takeTurnAroundBlockOwnership(obj,turnAroundNode1.BlkHdl,currentNode.BlkHdl);
                    [serialIR2,turnAroundNode2]=appendToChain2(obj,prevNode(2),[]);


                    obj.confirmParallelBranchNotEmpty(currentNode,turnAroundNode1);
                    obj.confirmParallelBranchNotEmpty(currentNode,turnAroundNode2);
                    obj.confirmTurnAroundBlocksSame(turnAroundNode1.BlkHdl,turnAroundNode2.BlkHdl);

                    parallelIR=RoutineParser.appendParallelyToChain2(serialIR1,serialIR2);
                    updatedIR=RoutineParser.appendSeriallyToChain2(parallelIR,existingIR);

                    assert(turnAroundNode1.BlkHdl==turnAroundNode2.BlkHdl,'Parallel chains must end at the same block but didn''t');
                    nextNodeCount=length(turnAroundNode1.NextNode);

                    if nextNodeCount==2...
                        ||...
                        (obj.getTouch(turnAroundNode1.BlkHdl)-nextNodeCount==0&&...
                        obj.turnAroundBlockOwnership(turnAroundNode1.BlkHdl,currentNode.BlkHdl))


                        [newIR,turnAroundNode]=appendToChain2(obj,turnAroundNode1,updatedIR);
                    else
                        newIR=updatedIR;
                        turnAroundNode=turnAroundNode1;


                        rejectTurnAroundBlockOwnership(obj,turnAroundNode1.BlkHdl,currentNode.BlkHdl);
                    end

                else



                    blockIR=obj.getIRforBlock(currentNode.BlkHdl);
                    serialIR=RoutineParser.appendSeriallyToChain2(blockIR,existingIR);



                    prevNode=currentNode.PrevNode;

                    assert(length(prevNode)==1,['The block before ladder'...
                    ,'instruction has to be a single ladder block or the junction block or powerstart block']);

                    nextNodeCount=length(prevNode.NextNode);
                    if nextNodeCount>1||RoutineParser.isPowerStartBlock(prevNode.BlkHdl)

                        turnAroundNode=prevNode;
                        newIR=serialIR;

                        if~RoutineParser.isPowerStartBlock(prevNode.BlkHdl)
                            setTouch(obj,prevNode.BlkHdl,1);
                        end
                        return;
                    else

                        [newIR,turnAroundNode]=appendToChain2(obj,prevNode,serialIR);
                    end
                end
            end
        end

        function setTouch(obj,blkHdl,count)
            if obj.RungBlkTouchMap.isKey(blkHdl)
                obj.RungBlkTouchMap(blkHdl)=obj.RungBlkTouchMap(blkHdl)+count;
            else
                obj.RungBlkTouchMap(blkHdl)=count;
            end
        end

        function out=getTouch(obj,blkHdl)
            if obj.RungBlkTouchMap.isKey(blkHdl)
                out=obj.RungBlkTouchMap(blkHdl);
            else
                out=0;
            end
        end

        function takeTurnAroundBlockOwnership(obj,tbBlkHdl,junctionBlkHdl)
            if~obj.RungBlkOwnerMap.isKey(tbBlkHdl)
                obj.RungBlkOwnerMap(tbBlkHdl)=junctionBlkHdl;
            end

        end

        function rejectTurnAroundBlockOwnership(obj,tbBlkHdl,junctionBlkHdl)
            if obj.RungBlkOwnerMap.isKey(tbBlkHdl)
                if obj.RungBlkOwnerMap(tbBlkHdl)==junctionBlkHdl
                    obj.RungBlkOwnerMap.remove(tbBlkHdl);
                end
            end

        end

        function tf=turnAroundBlockOwnership(obj,tbBlkHdl,junctionBlkHdl)
            tf=false;
            if obj.RungBlkOwnerMap.isKey(tbBlkHdl)
                if obj.RungBlkOwnerMap(tbBlkHdl)==junctionBlkHdl
                    tf=true;
                end
            end

        end

        function out=rungTerminalBeingProcessed(obj,data)

            if nargin==2
                obj.RungTerminalIndex=data;
            end
            out=obj.RungTerminalIndex;
        end

        function confirmParallelBranchNotEmpty(obj,junctionNode,turnAroundNode)




            import plccore.frontend.model.RoutineParser;
            if any(turnAroundNode.NextNode==junctionNode)
                blkName=getfullname(junctionNode.BlkHdl);
                rung=obj.rungTerminalBeingProcessed;
                error('PLC:LadderExport:EmptyParallelBranch',...
                ['Parallel branch near block : ''',blkName...
                ,''' is empty. Possible invalid ladder rung : ',num2str(rung)]);
            end
        end

        function confirmTurnAroundBlocksSame(obj,pblock1,pblock2)
            import plccore.frontend.model.RoutineParser;
            if pblock1~=pblock2
                blkName1=getfullname(pblock1);
                blkName2=getfullname(pblock2);
                rung=obj.rungTerminalBeingProcessed;
                error('PLC:LadderExport:BlocksInParallelInvalid',...
                ['Parallel chains should begin at same block, but began at:',blkName1,', ',blkName2,'. Possible invalid ladder rung : ',num2str(rung)]);
            end
        end

        function confirmRungEndsAtCorrectTerminal(obj,blkHdl)

            import plccore.frontend.model.RoutineParser;
            index=RoutineParser.getRungTerminalIndex(blkHdl);
            if index~=obj.rungTerminalBeingProcessed
                error('PLC:LadderExport:BlocksLeadToInvalidRungTerminal',...
                ['Block parsing lead to terminal : ',num2str(index)...
                ,'. Expected rung terminal : '...
                ,num2str(obj.rungTerminalBeingProcessed)...
                ,'.Possible invalid ladder diagram']);
            end
        end
    end

    methods(Access=private,Static)


        function rtIndex=getRungTerminalIndex(rungTerminalBlkHdl)

            rtIndex=get_param(rungTerminalBlkHdl,'PLCRungTerminalIndex');

            if isempty(rtIndex)
                error('PLC:ladderExport:InvalidRungTerminalName',...
                ['Rung terminal : ',rtname,' should have priority set which indicates the rung number']);
            end
            rtIndex=str2double(rtIndex);
        end

        function out=isRungTerminalBlock(blkHandle)
            blkInfo=slplc.api.getPOU(blkHandle);
            if strcmpi(blkInfo.PLCBlockType,'RungTerminal')
                out=true;
            else
                out=false;
            end
        end

        function out=isPowerStartBlock(blkHandle)
            blkInfo=slplc.api.getPOU(blkHandle);
            if strcmpi(blkInfo.PLCBlockType,'PowerRailStart')
                out=true;
            else
                out=false;
            end
        end

        function out=getNonRungOutDestInputPorts(blkPrtHandle)



            out=[];

            if isnumeric(blkPrtHandle)
                blkPrtHandle=get_param(blkPrtHandle,'UDDObject');
            end


            if strcmpi(blkPrtHandle.Type,'Port')
                parent=blkPrtHandle.Parent;
                blkUDD=get_param(parent,'UDDObject');
            else
                blkUDD=blkPrtHandle;
            end

            blkOutports=blkUDD.PortHandles.Outport;
            for blkOutPortIndex=2:length(blkOutports)
                outportUDD=get_param(blkOutports(blkOutPortIndex),'UDDObject');

                dstInportHdls=outportUDD.getGraphicalDst;
                for dstInportIndex=1:length(dstInportHdls)
                    out(end+1)=dstInportHdls(dstInportIndex);%#ok<AGROW>
                end
            end
        end

        function out=getSrcBlkOuputPorts(blkPrtHandle)


            if isnumeric(blkPrtHandle)
                blkPrtHandle=get_param(blkPrtHandle,'UDDObject');
            end


            if strcmpi(blkPrtHandle.Type,'Port')
                parent=blkPrtHandle.Parent;
                blkUDD=get_param(parent,'UDDObject');
            else
                blkUDD=blkPrtHandle;
            end


            out=blkUDD.getGraphicalSrc;
        end

        function out=getBlockfromPort(prtHandle)
            type=get_param(prtHandle,'Type');
            assert(strcmpi(type,'port'),'Input handle is not a port');

            blockPath=get_param(prtHandle,'Parent');
            out=get_param(blockPath,'Handle');
        end

        function out=getUDDfromHdl(hdl)
            out=get_param(hdl,'UDDObject');
        end

        function confirmDestBlocksConnectivity(currentNode)
            import plccore.frontend.model.RoutineParser;
            import plccore.frontend.ModelParser;
            ph=get_param(currentNode.BlkHdl,'PortHandles');
            if isempty(ph.Outport)
                return;
            end
            uddObj=RoutineParser.getUDDfromHdl(ph.Outport(1));

            destBlkPorts=uddObj.getGraphicalDst;
            if length(destBlkPorts)~=length(currentNode.NextNode)
                numberOfLDBlksFound=0;
                for ii=1:length(destBlkPorts)
                    destBlock=RoutineParser.getBlockfromPort(destBlkPorts(ii));
                    isLadderBlock=ModelParser.isLadderBlock(destBlock);
                    if isLadderBlock
                        numberOfLDBlksFound=numberOfLDBlksFound+1;
                    end
                    if numberOfLDBlksFound>1
                        srcName=getfullname(currentNode.BlkHdl);

                        error('PLC:LadderExport:BlocksMismatchBtwGraphAndActual',...
                        ['Source block : ',srcName...
                        ,' has different number of ladder blocks when traversing left to right and right to left.']);
                    end
                end
            end
        end

        function[readLabels,writeLabels]=getReadWritePortLabelsForInstr(instrBlkHdl)
            readLabels=plc_find_system(instrBlkHdl,'LookUnderMasks','on','SearchDepth',1,'BlockType','Inport');
            readLabels=get_param(readLabels(2:end),'Name');

            writeLabels=plc_find_system(instrBlkHdl,'LookUnderMasks','on','SearchDepth',1,'BlockType','Outport');
            writeLabels=get_param(writeLabels(2:end),'Name');

            if ischar(readLabels)&&ischar(writeLabels)
                readLabels={readLabels};
                writeLabels={writeLabels};
            end
        end

        function[readOperands,writeOperands]=getReadWriteOperandNamesForInstr(instrBlkHdl)




            readOperands={};
            writeOperands={};

            import plccore.frontend.model.RoutineParser;
            srcBlkPorts=RoutineParser.getSrcBlkOuputPorts(instrBlkHdl);

            for ii=2:length(srcBlkPorts)
                srcBlk=RoutineParser.getBlockfromPort(srcBlkPorts(ii));
                blkInfo=slplc.api.getPOU(srcBlk);
                if strcmpi(blkInfo.PLCBlockType,'VariableRead')
                    readOperands{end+1}=blkInfo.PLCOperandTag;%#ok<AGROW>
                elseif strcmpi(get_param(srcBlk,'BlockType'),'Constant')
                    cvalue=get_param(srcBlk,'Value');
                    readOperands{end+1}=cvalue;%#ok<AGROW>
                else
                    plccore.common.plcThrowError('plccoder:plccore:InvalidLadderInputBlock',getfullname(instrBlkHdl));
                end
            end

            dstBlkPorts=RoutineParser.getNonRungOutDestInputPorts(instrBlkHdl);
            if~isempty(dstBlkPorts)
                varWriteBlkFound=false;
                for ii=1:length(dstBlkPorts)
                    destBlk=RoutineParser.getBlockfromPort(dstBlkPorts(ii));
                    blkInfo=slplc.api.getPOU(destBlk);
                    if strcmpi(blkInfo.PLCBlockType,'VariableWrite')
                        writeOperands{end+1}=blkInfo.PLCOperandTag;%#ok<AGROW>
                        varWriteBlkFound=true;
                    elseif~isempty(blkInfo.PLCBlockType)


                        varWriteBlkFound=true;
                    else



                    end
                end
                if~varWriteBlkFound
                    plccore.common.plcThrowError('plccoder:plccore:NoVariableWriteBlockFound',getfullname(instrBlkHdl));
                end
            end

        end
    end

    methods(Static,Access=private)

        function newChain=appendSeriallyToChain(existingChain,blockIR)



            import plccore.type.*;
            import plccore.common.*;
            import plccore.expr.*;
            import plccore.ladder.*;
            if~isempty(existingChain)
                if isa(existingChain,'plccore.ladder.RungOpSeq')
                    newChain=RungOpSeq([existingChain.rungOps,{blockIR}]);
                else
                    newChain=RungOpSeq({existingChain,blockIR});
                end
            else
                newChain=blockIR;
            end
        end


        function newChain=appendSeriallyToChain2(blockIR,existingChain)



            import plccore.type.*;
            import plccore.common.*;
            import plccore.expr.*;
            import plccore.ladder.*;
            if~isempty(existingChain)
                if isa(existingChain,'plccore.ladder.RungOpSeq')
                    newChain=RungOpSeq([{blockIR},existingChain.rungOps]);
                else
                    newChain=RungOpSeq({blockIR,existingChain});
                end
            else
                newChain=blockIR;
            end
        end


        function newChain=appendParallelyToChain(parallelBranchFirst,parallelBranchRemaining)




            import plccore.type.*;
            import plccore.common.*;
            import plccore.expr.*;
            import plccore.ladder.*;

            newChain=RungOpPar({parallelBranchFirst,parallelBranchRemaining});
        end

        function newChain=appendParallelyToChain2(parallelBranchFirst,parallelBranchRemaining)




            import plccore.type.*;
            import plccore.common.*;
            import plccore.expr.*;
            import plccore.ladder.*;


            rungOpsList={};
            if isa(parallelBranchFirst,'plccore.ladder.RungOpPar')
                rungOpsList=[rungOpsList,parallelBranchFirst.rungOps];
            else
                rungOpsList{end+1}=parallelBranchFirst;
            end

            if isa(parallelBranchRemaining,'plccore.ladder.RungOpPar')
                rungOpsList=[rungOpsList,parallelBranchRemaining.rungOps];
            else
                rungOpsList{end+1}=parallelBranchRemaining;
            end


            newChain=RungOpPar(rungOpsList);
        end
    end

    methods(Static)
        function out=isParallelJunctionBlock(blkHandle)
            blkType=get_param(blkHandle,'PLCBlockType');
            if strcmp(blkType,'Junction')
                out=true;
            else
                out=false;
            end
        end
    end
end












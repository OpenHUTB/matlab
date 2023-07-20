



classdef Transition<slci.common.BdObject

    properties(Access=private)
        fSrc=[];
        fDst=[];
        fSrcId=0;
        fDstId=0;
        fFlag=0;
        fExecutionOrder=-1;
        fConditionAST=[];
        fConditionActionAST=[];
        fHasTransitionAction=false;
        fParent=[];
        fSfId=-1;

        fIsLoopInitTransition=false;
        fIsLoopCondTransition=false;
        fIsLoopAfterTransition=false;
        fIsLoopBodyTransition=false;
        fInductionVarIdentifier=[];
        fNeedConstraints=true;
    end


    methods

        function setInductionVariable(aObj,identifier)
            aObj.fInductionVarIdentifier=identifier;
        end


        function out=getInductionVariable(aObj)
            out=aObj.fInductionVarIdentifier;
        end


        function setIsLoopInitTransition(aObj,isLoopInitTrans)
            aObj.fIsLoopInitTransition=isLoopInitTrans;
        end


        function out=isLoopInitTransition(aObj)
            out=aObj.fIsLoopInitTransition;
        end


        function setIsLoopCondTransition(aObj,isLoopCondTrans)
            aObj.fIsLoopCondTransition=isLoopCondTrans;
        end


        function out=isLoopCondTransition(aObj)
            out=aObj.fIsLoopCondTransition;
        end


        function setIsLoopAfterTransition(aObj,isLoopAfterTrans)
            aObj.fIsLoopAfterTransition=isLoopAfterTrans;
        end


        function out=isLoopAfterTransition(aObj)
            out=aObj.fIsLoopAfterTransition;
        end


        function setIsLoopBodyTransition(aObj,isLoopBodyTrans)
            aObj.fIsLoopBodyTransition=isLoopBodyTrans;
        end


        function out=isLoopBodyTransition(aObj)
            out=aObj.fIsLoopBodyTransition;
        end
    end

    methods(Access=private)


        function isValidCond...
            =isSupportedCond(aObj)
            isValidCond=false;
            if~aObj.HasCondition()
                return;
            end
            conditionActionAst=aObj.getConditionActionAST();
            if~isempty(conditionActionAst)
                return;
            end
            rootAst=aObj.getConditionAST().getChildren();

            if(numel(rootAst)~=1)
                return;
            end


            isValidOperator=false;
            if isa(rootAst{1},'slci.ast.SFAstLesserThan')...
                ||isa(rootAst{1},'slci.ast.SFAstLesserThanOrEqual')
                isValidOperator=true;
            end

            children=rootAst{1}.getChildren();
            if(numel(children)==2)

isValidLhs...
                =isa(children{1},'slci.ast.SFAstIdentifier')...
                &&strcmpi(children{1}.getDataType(),'int32');

isValidRhs...
                =aObj.isConstantWithInt32DataType(children{2});
                if(isValidOperator&&isValidLhs&&isValidRhs)
                    isValidCond=true;
                end
            end
        end


        function isValidInit...
            =isSupportedInit(aObj)
            isValidInit=false;
            inductionVar=aObj.fInductionVarIdentifier;
            conditionAst=aObj.getConditionAST();
            if~isempty(conditionAst)
                return;
            end
            conditionActionAst=aObj.getConditionActionAST();
            if isempty(conditionActionAst)
                return;
            end
            rootAst=conditionActionAst.getChildren();

            if(numel(rootAst)~=1)
                return;
            end

            if isa(rootAst{1},'slci.ast.SFAstEqualAssignment')

                children=rootAst{1}.getChildren();
                if(numel(children)==2)


isValidLhs...
                    =isa(children{1},'slci.ast.SFAstIdentifier')...
                    &&strcmpi(children{1}.getQualifiedName(),inductionVar)...
                    &&strcmpi(children{1}.getDataType(),'int32');

isValidRhs...
                    =aObj.isConstantWithInt32DataType(children{2});
                    if(isValidLhs&&isValidRhs)
                        isValidInit=true;
                    end
                end
            end
        end


        function isValidAfter...
            =isSupportedAfter(aObj)
            isValidAfter=false;
            inductionVar=aObj.fInductionVarIdentifier;
            conditionAst=aObj.getConditionAST();
            if~isempty(conditionAst)
                return;
            end
            conditionActionAst=aObj.getConditionActionAST();
            if isempty(conditionActionAst)
                return;
            end

            rootAst=conditionActionAst.getChildren();

            if(numel(rootAst)~=1)
                return;
            end


            if isa(rootAst{1},'slci.ast.SFAstEqualAssignment')


                children=rootAst{1}.getChildren();
                if(numel(children)==2)


isValidLhs...
                    =isa(children{1},'slci.ast.SFAstIdentifier')...
                    &&strcmpi(children{1}.getQualifiedName(),inductionVar);


isPlusRhs...
                    =isa(children{2},'slci.ast.SFAstPlus');
                    if isPlusRhs
                        children=children{2}.getChildren();
isValidRhs...
                        =(isa(children{1},'slci.ast.SFAstIdentifier')...
                        &&strcmpi(children{1}.getQualifiedName(),inductionVar))...
                        &&strcmpi(children{1}.getDataType(),'int32')...
                        &&aObj.isConstantWithInt32DataType(children{2})...
                        &&aObj.isPositiveConstant(children{2});

                    else
                        isValidRhs=false;
                    end
                    isValidAfter=isValidLhs&&isValidRhs;
                end
            elseif isa(rootAst{1},'slci.ast.SFAstPlusAssignment')


                children=rootAst{1}.getChildren();
                if(numel(children)==2)


isValidLhs...
                    =isa(children{1},'slci.ast.SFAstIdentifier')...
                    &&strcmpi(children{1}.getQualifiedName(),inductionVar)...
                    &&strcmpi(children{1}.getDataType(),'int32');

isValidRhs...
                    =aObj.isConstantWithInt32DataType(children{2});

                    isValidAfter=isValidLhs&&isValidRhs;
                end
            end
        end


        function out=isConstantWithInt32DataType(~,astNode)
            isInt32Type=strcmpi(astNode.getDataType(),'int32');
            if isInt32Type
                out=slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(astNode);
            else
                out=false;
            end
        end


        function out=isPositiveConstant(~,astNode)
            [success,value]=...
            slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(astNode);
            out=success&&(value>0);
        end


        function out=isInductionRedefined(aObj)
            out=false;
            inductionVar=aObj.fInductionVarIdentifier;
            asts=aObj.getConditionActionAST();
            if isempty(asts)
                return;
            end

            children=asts.getChildren();
            for i=1:numel(children)
                if isa(children{i},'slci.ast.SFAstEqualAssignment')
                    assignmentChildren=children{i}.getChildren();
                    lhs=assignmentChildren{1};
                    if isa(lhs,'slci.ast.SFAstIdentifier')...
                        &&strcmpi(lhs.getQualifiedName(),inductionVar)
                        out=true;
                    end
                end
            end
        end
    end

    methods

        function out=AppendConditionAction(aObj,actionClass)
            if isempty(aObj.fConditionActionAST)
                aObj.fConditionActionAST=slci.internal.createStateflowAst([],aObj);
            end
            out=aObj.fConditionActionAST.appendChild(actionClass,[]);
        end

        function out=IsVirtual(aObj)
            out=aObj.fSfId==0;
        end

        function out=IsTrivial(aObj)
            out=...
            (isempty(aObj.fConditionAST)||...
            ~aObj.fConditionAST.ContainsExecutable())&&...
            (isempty(aObj.fConditionActionAST)||...
            ~aObj.fConditionActionAST.ContainsExecutable());
        end

        function out=HasCondition(aObj)
            out=~isempty(aObj.fConditionAST)&&...
            aObj.fConditionAST.ContainsExecutable();
        end

        function out=getExecutionOrder(aObj)
            out=aObj.fExecutionOrder;
        end


        function out=getParentAtomicSubchartIfExists(aObj)
            out=0;
            if isa(aObj.fParent,'slci.stateflow.SFAtomicSubchart')
                out=aObj.fParent.getParentAtomicSubchartSfId();
            end
        end
        function out=getHasTransitionAction(aObj)
            out=aObj.fHasTransitionAction;
        end

        function out=getFlag(aObj)
            out=aObj.fFlag;
        end

        function setFlag(aObj,aFlag)
            aObj.fFlag=aFlag;
        end

        function out=getSfId(aObj)
            out=aObj.fSfId;
        end

        function setSfId(aObj,aSfId)
            aObj.fSfId=aSfId;
        end

        function out=getSrc(aObj)
            out=aObj.fSrc;
        end

        function setSrcId(aObj,aSrcId)
            aObj.fSrcId=aSrcId;
        end

        function setSrc(aObj,aSrc)
            aObj.fSrc=aSrc;
        end

        function out=getDst(aObj)
            out=aObj.fDst;
        end

        function setDst(aObj,aDst)
            aObj.fDst=aDst;
        end


        function setDstId(aObj,aDstId)
            aObj.fDstId=aDstId;
        end

        function out=getDstId(aObj)
            out=aObj.fDstId;
        end

        function out=getSrcId(aObj)
            out=aObj.fSrcId;
        end



        function out=getConditionAST(aObj)
            if~isempty(aObj.fConditionAST)&&...
                aObj.fConditionAST.ContainsExecutable()
                out=aObj.fConditionAST;
            else
                out=[];
            end
        end



        function out=getConditionActionAST(aObj)
            if~isempty(aObj.fConditionActionAST)&&...
                aObj.fConditionActionAST.ContainsExecutable()
                out=aObj.fConditionActionAST;
            else
                out=[];
            end
        end

        function out=getASTs(aObj)
            out={};
            if~isempty(aObj.fConditionAST)
                out{end+1}=aObj.fConditionAST;
            end
            if~isempty(aObj.fConditionActionAST)
                out{end+1}=aObj.fConditionActionAST;
            end
        end

        function out=getParent(aObj)
            out=aObj.fParent;
        end

        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent;
            else
                out=aObj.fParent.ParentChart();
            end
        end

        function out=ParentState(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent;
            else
                out=[];
            end
        end

        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end

        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end


        function out=isSupportedLoopInit(aObj)
            out=true;
            if(aObj.fIsLoopInitTransition)
                out=aObj.isSupportedInit();
            end
        end


        function out=isSupportedLoopCond(aObj)
            out=true;
            if(aObj.fIsLoopCondTransition)
                out=aObj.isSupportedCond();
            end
        end


        function out=hasSupportedLoopInductionVar(aObj)
            out=true;
            inductionVariable=getInductionVariable(aObj);
            if isempty(inductionVariable)
                out=false;
            end
        end


        function out=isSupportedLoopAfter(aObj)
            out=true;
            if(aObj.fIsLoopAfterTransition)
                out=aObj.isSupportedAfter();
            end
        end


        function out=isSupportedLoopBody(aObj)
            out=true;
            if(aObj.fIsLoopBodyTransition)
                out=~aObj.isInductionRedefined();
            end
        end

        function aObj=Transition(aTransitionUDDObj,aParent,addConstraints)
            aObj.fParent=aParent;
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameTransition');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameTransitions');
            aObj.fNeedConstraints=addConstraints;
            if isempty(aTransitionUDDObj)
                aObj.fSfId=0;
            else
                aObj.fSfId=aTransitionUDDObj.Id;
                aObj.setUDDObject(aTransitionUDDObj);
                parentPath=aObj.ParentChart().Path();
                if isa(aParent,'slci.stateflow.SFAtomicSubchart')
                    aObj.setSID(Simulink.ID.getStateflowSID(aTransitionUDDObj));

                else
                    aObj.setSID(Simulink.ID.getStateflowSID(aTransitionUDDObj,...
                    parentPath));
                end

                aObj.fExecutionOrder=aTransitionUDDObj.ExecutionOrder;
                dstObj=aTransitionUDDObj.Destination;
                if~isempty(dstObj)
                    aObj.fDstId=dstObj.Id;
                end
                srcObj=aTransitionUDDObj.Source;
                if~isempty(srcObj)
                    aObj.fSrcId=srcObj.Id;
                end
                astObjContainer=Stateflow.Ast.getContainer(aTransitionUDDObj);
                astObjSections=astObjContainer.sections;
                for i=1:numel(astObjSections)
                    section=astObjSections{i};
                    if isa(section,'Stateflow.Ast.ConditionSection')
                        aObj.fConditionAST=slci.internal.createStateflowAst(section,aObj);
                    elseif isa(section,'Stateflow.Ast.ConditionActionSection')
                        aObj.fConditionActionAST=slci.internal.createStateflowAst(section,aObj);
                    elseif isa(section,'Stateflow.Ast.TransitionActionSection')
                        aObj.fHasTransitionAction=true;
                    end
                end
            end
            if aObj.needConstraints

                aObj.addConstraint(slci.compatibility.StateflowActionOperationsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowEnumOperationsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowHasTransitionActionConstraint);

                aObj.addConstraint(slci.compatibility.StateflowEventTriggerConstraint);

                aObj.addConstraint(slci.compatibility.StateflowCustomDataConstraint);

                aObj.addConstraint(slci.compatibility.StateflowTimeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowContextSensitiveConstantConstraint);

                aObj.addConstraint(slci.compatibility.StateflowMixedTypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowInvalidOperandTypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowBooleanConditionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowNumArgumentsConstraint);

                aObj.addConstraint(slci.compatibility.StateflowArrayIndexTypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowArrayDimensionsConstraint);


                aObj.addConstraint(slci.compatibility.StateflowSimulinkFunctionInputDimensionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowSimulinkFunctionInputDatatypeConstraint);


                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionInputDatatypeConstraint);

                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionInputDimensionConstraint);

                aObj.addConstraint(slci.compatibility.StateflowGraphicalFunctionUnusedOutputConstraint);


                aObj.addConstraint(slci.compatibility.StateflowTruthTableInputDatatypeConstraint);


                aObj.addConstraint(slci.compatibility.StateflowTruthTableInputDimensionConstraint);


                sfLoopInductionVarConstraint=slci.compatibility.StateflowLoopInductionVariableConstraint;
                aObj.addConstraint(sfLoopInductionVarConstraint);


                sfLoopInitConstraint=slci.compatibility.StateflowLoopInitConstraint;
                aObj.addConstraint(sfLoopInitConstraint);


                sfLoopCondConstraint=slci.compatibility.StateflowLoopCondConstraint;
                aObj.addConstraint(sfLoopCondConstraint);


                sfLoopAfterConstraint=slci.compatibility.StateflowLoopAfterConstraint;
                aObj.addConstraint(sfLoopAfterConstraint);


                aObj.addConstraint(slci.compatibility.StateflowLoopBodyConstraint);


                aObj.addConstraint(slci.compatibility.StateflowInductionVariableReuseConstraint);


                aObj.addConstraint(slci.compatibility.StateflowMisraXorConstraint);

                aObj.addConstraint(slci.compatibility.StateflowVariantTransitionConstraint);

            end
        end


        function out=needConstraints(aObj)
            out=aObj.fNeedConstraints;
        end

        function aDstObj=CopyForCfg(aSrcObj)

            aDstObj=slci.stateflow.Transition(aSrcObj.getUDDObject(),aSrcObj.fParent,false);
        end

    end
end



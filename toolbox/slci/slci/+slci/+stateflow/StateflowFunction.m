



classdef StateflowFunction<slci.common.BdObject


    properties(Access=private)
        fName='';
        fParent=[];
        fSfId=-1;
        fDefaultTransitions=[];
        fInplacePairNameMap=[];
        fPath=[];
        fDefaultCfg=[];
        fNumInputs=0;
        fNumOutputs=0;
        fInputDataNames={};
        fOutputDataNames={};
        fTemporaryDataNames={};
        fLocalDataNames={};
        fConstantDataNames={};
        fGlobalStatesNames={};
        fInputDataQNames={};
        fOutputDataQNames={};
        fTemporaryDataQNames={};
        fLocalDataQNames={};
        fConstantDataQNames={};
        fGlobalStatesQNames={};
        fIsRecursive=false;
        fInlineOption=slci.stateflow.SFInlineOptionTypes.Auto;
    end

    methods

        function out=getName(aObj)
            out=aObj.fName;
        end


        function out=getPath(aObj)
            out=aObj.fPath;
        end


        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function setSfId(aObj,aSfId)
            aObj.fSfId=aSfId;
        end


        function setRecursive(aObj,fSfFnCallMap)
            aObj.fIsRecursive=fSfFnCallMap.isRecursive(aObj.getSID());
        end


        function out=isRecursive(aObj)
            out=aObj.fIsRecursive;
        end


        function setInlineOption(aObj,inlineOption)


            if strcmpi(inlineOption,'inline')
                aObj.fInlineOption=slci.stateflow.SFInlineOptionTypes.Inline;
            elseif strcmpi(inlineOption,'function')
                aObj.fInlineOption=slci.stateflow.SFInlineOptionTypes.Function;
            end
        end


        function out=isNonInlined(aObj)
            out=(aObj.fInlineOption==...
            slci.stateflow.SFInlineOptionTypes.Function);
        end


        function out=isInlined(aObj)
            out=(aObj.fInlineOption==...
            slci.stateflow.SFInlineOptionTypes.Inline);
        end


        function out=getInlineOptionValue(aObj)
            out=int32(aObj.getInlineOptionEnum());
        end


        function out=getInlineOptionEnum(aObj)
            out=aObj.fInlineOption;
        end


        function out=getDefaultCfg(aObj)
            out=aObj.fDefaultCfg;
        end


        function setDefaultCfg(aObj,aDefaultCfg)
            aObj.fDefaultCfg=aDefaultCfg;
        end


        function CreateCfgs(aObj)
            transitions=aObj.getDefaultTransitions();
            if~isempty(transitions)
                aObj.fDefaultCfg=slci.stateflow.Cfg(aObj,'default');
            end

            if(~isempty(aObj.fDefaultCfg)&&aObj.fDefaultCfg.IsEmpty())
                aObj.fDefaultCfg=[];
            end
        end


        function out=hasDefaultTransitions(aObj)
            out=~isempty(aObj.fDefaultTransitions);
        end


        function out=getDefaultTransitions(aObj)
            out=aObj.fDefaultTransitions;
        end


        function AddDefaultTransition(aObj,aDefaultTransition)
            if isempty(aObj.fDefaultTransitions)
                aObj.fDefaultTransitions=aDefaultTransition;
            else
                aObj.fDefaultTransitions(end+1)=aDefaultTransition;
            end
        end


        function out=NonEmptyCfgs(aObj)
            out={};
            defaultCfg=aObj.getDefaultCfg;
            if~isempty(defaultCfg)
                out{end+1}=defaultCfg;
            end
        end


        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFState')...
                ||isa(aObj.fParent,'slci.stateflow.SFFunction')...
                ||isa(aObj.fParent,'slci.stateflow.TruthTable')
                out=aObj.fParent.ParentChart();
            else
                assert(isa(aObj.fParent,'slci.stateflow.Chart'))
                out=aObj.fParent;
            end
        end


        function out=ParentState(aObj)
            if isa(aObj.fParent,'slci.stateflow.SFFunction')...
                ||isa(aObj.fParent,'slci.stateflow.TruthTable')
                out=aObj.fParent.ParentState();
            elseif isa(aObj.fParent,'slci.stateflow.SFState')
                out=aObj.fParent;
            else
                out=[];
            end
        end


        function out=getParent(aObj)
            out=aObj.fParent;
        end


        function setParent(aObj,aParent)
            aObj.fParent=aParent;
        end


        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end


        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end


        function out=getNumInputs(aObj)
            out=numel(aObj.fInputDataNames);
        end


        function out=getInputArgNames(aObj)
            out=aObj.fInputDataNames;
        end


        function out=getNumOutputs(aObj)
            out=numel(aObj.fOutputDataNames);
        end


        function out=getOutputArgNames(aObj)
            out=aObj.fOutputDataNames;
        end


        function out=getTemporaryDataNames(aObj)
            out=aObj.fTemporaryDataNames;
        end


        function out=getLocalDataNames(aObj)
            out=aObj.fLocalDataNames;
        end


        function out=getConstantDataNames(aObj)
            out=aObj.fConstantDataNames;
        end


        function out=getInputArgQualifiedNames(aObj)
            out=aObj.fInputDataQNames;
        end


        function out=getOutputArgQualifiedNames(aObj)
            out=aObj.fOutputDataQNames;
        end


        function out=getTemporaryDataQualifiedNames(aObj)
            out=aObj.fTemporaryDataQNames;
        end


        function out=getLocalDataQualifiedNames(aObj)
            out=aObj.fLocalDataQNames;
        end


        function out=getConstantDataQualifiedNames(aObj)
            out=aObj.fConstantDataQNames;
        end


        function out=getNumGlobalStatesData(aObj)
            out=numel(aObj.getGlobalStatesDataNames());
        end


        function out=getGlobalStatesDataNames(aObj)
            out=aObj.fGlobalStatesNames;
        end


        function out=getGlobalStatesDataQualifiedNames(aObj)
            out=aObj.fGlobalStatesQNames;
        end




        function setInplacePairName(aObj,children)
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')&&...
            strcmpi(x.Scope,'Output')),children));

            aObj.fInplacePairNameMap=...
            containers.Map('KeyType','char','ValueType','char');

            for i=1:numel(data)
                datai=data(i);
                if sf('get',datai.Id,'data.inPlace.isInPlace')
                    inPlaceData=idToHandle(sfroot,sf('get',datai.Id,'data.inPlace.pairId'));
                    outputKey=[aObj.getSID,':',datai.Name,':',num2str(datai.Id)];
                    inputKey=[aObj.getSID,':',inPlaceData.Name,':',num2str(inPlaceData.Id)];
                    aObj.fInplacePairNameMap(outputKey)=inputKey;
                    aObj.fInplacePairNameMap(inputKey)=outputKey;
                end
            end
        end


        function out=getInplacePairName(aObj)
            out=aObj.fInplacePairNameMap;
        end


        function setData(aObj,children,scopeKind)%#ok
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')&&...
            strcmpi(x.Scope,scopeKind)),children));%#ok
            cmd=['aObj.f'...
            ,scopeKind...
            ,'DataNames = arrayfun(@(x)(x.Name), data, ''UniformOutput'', false);'];
            cmd2=['aObj.f'...
            ,scopeKind...
            ,'DataQNames = arrayfun(@(x)([aObj.getSID '':'' x.Name '':'' num2str(x.Id)]), '...
            ,'data, ''UniformOutput'', false);'];
            eval(cmd);
            eval(cmd2);
        end

        function BuildGlobalStates(aObj)





            if(aObj.isInlined())
                return;
            end
            transitions=find(aObj.getUDDObject(),'-isa','Stateflow.Transition');
            transitions=slci.internal.getSFActiveObjs(transitions);
            for i=1:numel(transitions)
                transitionUdd=transitions(i);
                transitionAst=aObj.ParentChart().getTransitionFromId(transitionUdd.Id);
                ASTs=transitionAst.getASTs();
                aObj.addTransitionIdentifiers(ASTs);
            end
        end


        function addGlobalStatesData(aObj,identifier)
            assert(isa(identifier,'slci.ast.SFAstQualifiedId')...
            ||isa(identifier,'slci.ast.SFAstIdentifier'));


            modelObj=aObj.ParentModel().getUDDObject();
            machineData=modelObj.find('-isa','Stateflow.Data','-depth',1);



            if isa(identifier,'slci.ast.SFAstIdentifier')


                if(identifier.IsFalse||identifier.IsTrue)
                    return;
                end
                identifierName=identifier.fName;
                qualifiedId=identifier.getIdentifier;
            else
                identifierName=identifier.fRootIdentifier;
                qualifiedId=identifier.getBaseName;
            end

            if~isempty(machineData)
                for i=1:numel(machineData)
                    if strcmp(machineData(i).Name,identifierName)
                        return;
                    end
                end
            end

            if(any(contains(...
                aObj.fGlobalStatesQNames,qualifiedId)))
                return;
            end



            dataObj=...
            find(aObj.getUDDObject(),'-isa','Stateflow.Data','Id',identifier.fId);

            if isempty(dataObj)
                aObj.fGlobalStatesNames{end+1}=identifierName;
                aObj.fGlobalStatesQNames{end+1}=qualifiedId;
            end
        end


        function out=hasGlobalStates(aObj)
            out=~isempty(aObj.fGlobalStatesNames);
        end


        function aObj=StateflowFunction(aFunctionUDDObj,aParent,addConstraints)
            aObj.fSfId=aFunctionUDDObj.Id;
            aObj.fName=aFunctionUDDObj.Name;
            aObj.setUDDObject(aFunctionUDDObj);
            aObj.fPath=aFunctionUDDObj.Path;
            aObj.fParent=aParent;
            parentPath=aParent.Path;

            if isa(aParent,'slci.stateflow.SFAtomicSubchart')
                aObj.setSID(Simulink.ID.getStateflowSID(aFunctionUDDObj));

            else
                aObj.setSID(Simulink.ID.getStateflowSID(aFunctionUDDObj,...
                parentPath));
            end
            aObj.setInlineOption(aFunctionUDDObj.InlineOption);

            if addConstraints

                aObj.addConstraint(slci.compatibility.StateflowFunctionInlineOptionConstraint);


                aObj.addConstraint(slci.compatibility.StateflowRecursiveFunctionConstraint);

                if(slcifeature('SfLoopSupport')==0)

                    acyclicConstraint=slci.compatibility.AcyclicControlFlowConstraint;
                    aObj.addConstraint(acyclicConstraint);
                    structuredConstraint=slci.compatibility.StructuredControlFlowConstraint;
                    structuredConstraint.addPreRequisiteConstraint(acyclicConstraint);
                    aObj.addConstraint(structuredConstraint);
                end
            end
        end

    end

    methods(Access=protected)


        function addTransitionIdentifiers(aObj,object)
            if isa(object,'slci.ast.SFAstIdentifier')
                aObj.addGlobalStatesData(object);


            elseif isa(object,'slci.ast.SFAstQualifiedId')...
                &&~object.IsEnumConst()
                aObj.addGlobalStatesData(object);
            elseif iscell(object)
                for i=1:numel(object)
                    aObj.addTransitionIdentifiers(object{i});
                end
            elseif isa(object,'slci.ast.SFAstStructMember')
                children=object.getChildren;
                for i=1:numel(children)
                    if isa(children{i},'slci.ast.SFAstQualifiedId')
                        aObj.addTransitionIdentifiers(children{i});
                    end
                end
            elseif isa(object,'slci.ast.SFAstUnsupported')
                return;
            else
                children=object.getChildren;
                for i=1:numel(children)
                    aObj.addTransitionIdentifiers(children{i});
                end
            end
        end
    end
end






classdef SFAst<slci.common.BdObject

    properties(Constant,Access=protected)

        fDataTypeRank=containers.Map(...
        {...
        'boolean',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32',...
        'single',...
        'double'},...
        {20,20,20,30,30,40,40,50,60});
    end

    properties(Access=protected)
        fChildren={};
        fParent=[];
        fDataType='';
        fComputedDataType=false;
        fDataDim=-1;
        fComputedDataDim=false;


        fRootAst=[];
        fMtree=[];
    end

    methods(Access=protected)

        function out=DoUsualUnaryConversion(aObj,dtype)
            out=[];

            if isempty(dtype)
                out=dtype;
                return;
            elseif slci.stateflow.SFUtil.IsReal(dtype)
                out=dtype;
                return;
            elseif slci.stateflow.SFUtil.IsIntegerOrBoolean(dtype)
                r32=aObj.fDataTypeRank('int32');
                drank=aObj.fDataTypeRank(dtype);
                if r32<=drank
                    out=dtype;
                    return;
                end
                if slci.stateflow.SFUtil.IsSigned(dtype)
                    if drank<r32
                        out='int32';
                        return;
                    end
                end
                if slci.stateflow.SFUtil.IsUnsignedOrBoolean(dtype)
                    if drank<r32
                        out='int32';
                        return;
                    end
                end
                assert(false,'should not be possible to get here');
            else
                out=dtype;
            end
        end

        function out=DoUsualBinaryConversion(aObj,dtype1,dtype2)
            out=[];

            if isempty(dtype1)||isempty(dtype2)
                out=[];
                return;
            elseif slci.stateflow.SFUtil.IsBuiltin(dtype1)&&...
                slci.stateflow.SFUtil.IsBuiltin(dtype2)
                if slci.stateflow.SFUtil.IsReal(dtype1)||...
                    slci.stateflow.SFUtil.IsReal(dtype2)
                    if strcmp(dtype1,'double')||strcmp(dtype2,'double')
                        out='double';
                    elseif strcmp(dtype1,'single')||strcmp(dtype2,'single')
                        out='single';
                    else
                        assert(false,'Should not be possible to get here');
                    end
                    return;
                elseif slci.stateflow.SFUtil.IsIntegerOrBoolean(dtype1)&&...
                    slci.stateflow.SFUtil.IsIntegerOrBoolean(dtype2)
                    if(slci.stateflow.SFUtil.IsSigned(dtype1)&&...
                        slci.stateflow.SFUtil.IsSigned(dtype2))||...
                        (slci.stateflow.SFUtil.IsUnsignedOrBoolean(dtype1)&&...
                        slci.stateflow.SFUtil.IsUnsignedOrBoolean(dtype2))
                        r1=aObj.fDataTypeRank(dtype1);
                        r2=aObj.fDataTypeRank(dtype2);
                        if r1<r2
                            out=dtype2;
                        else
                            out=dtype1;
                        end
                        return;
                    else
                        if slci.stateflow.SFUtil.IsSigned(dtype1)
                            signedDtype=dtype1;
                            unsignedDtype=dtype2;
                        else
                            unsignedDtype=dtype1;
                            signedDtype=dtype2;
                        end
                        rs=aObj.fDataTypeRank(signedDtype);
                        ru=aObj.fDataTypeRank(unsignedDtype);
                        if rs<=ru
                            out=unsignedDtype;
                        else
                            out=signedDtype;
                        end
                        return
                    end
                elseif isequal(dtype1,dtype2)
                    out=dtype1;
                    return;
                else


                    out=dtype1;
                end
            else
                if isequal(dtype1,dtype2)
                    out=dtype1;
                    return;
                else


                    out=dtype1;
                end
            end
        end


        function out=IsExecutable(aObj)%#ok
            out=true;
        end


        function out=IsUnsupportedFunction(aObj)%#ok
            out=false;
        end

        function out=supportsEnumOperation(aObj)%#ok
            out=true;
        end


        function out=IsEventTrigger(aObj)%#ok
            out=false;
        end


        function out=IsCustomData(aObj)%#ok
            out=false;
        end


        function out=IsEnumCast(aObj)%#ok
            out=false;
        end


        function out=IsTime(aObj)%#ok
            out=false;
        end


        function out=IsContextSensitiveConstant(aObj)%#ok
            out=false;
        end


        function out=IsInvalidMixedType(aObj)%#ok

            out=false;
        end


        function out=IsInvalidOperandType(aObj)%#ok

            out=false;
        end

        function out=IsMixedType(aObj)
            out=false;
            children=aObj.getChildren();
            dataType=children{1}.getDataType();



            if(children{1}.IsEvent||isempty(dataType))
                return
            end
            for i=2:numel(children)
                if isempty(children{i}.getDataType())
                    return
                end
                if~strcmp(dataType,children{i}.getDataType())
                    out=true;
                    break;
                end
            end
        end


        function resolvedType=ResolveDataType(aObj)
            resolvedType='';
            children=aObj.getChildren();
            if aObj.hasMtree()

                assert(numel(children)>0,...
                'We should have at least 1 input.');

                type='';
                for i=1:numel(children)
                    child=children{i};
                    if~isempty(child.getDataType())


                        if strcmpi(type,'')
                            type=child.getDataType();
                        else
                            if~strcmpi(type,child.getDataType())
                                return;
                            end
                        end
                    else
                        return;
                    end
                end
                assert(~strcmpi(type,''));
                resolvedType=type;
            else

                if numel(children)==1
                    resolvedType=aObj.DoUsualUnaryConversion...
                    (children{1}.getDataType());
                else
                    assert(numel(children)==2,'we do not support > 2 inputs');
                    resolvedType=aObj.DoUsualBinaryConversion...
                    (children{1}.getDataType(),...
                    children{2}.getDataType());
                end
            end
        end

        function out=IsEvent(aObj)
            out=false;
            if(isa(aObj,'slci.ast.SFAstTrigger')...
                ||isa(aObj,'slci.ast.SFAstExplicitEvent'))
                out=true;
            end
        end
    end

    methods

        function setDataType(aObj,type)
            aObj.fDataType=type;
            aObj.fComputedDataType=true;
        end

        function out=getDataType(aObj)
            if~aObj.fComputedDataType
                aObj.ComputeDataTypeOfNodeAndDescendents();
            end

            out=aObj.fDataType;
        end

        function ComputeDataTypeOfNodeAndDescendents(aObj)
            if~aObj.fComputedDataType
                children=aObj.getChildren();
                for i=1:numel(children)
                    ComputeDataTypeOfNodeAndDescendents(children{i});
                end
                aObj.ComputeDataType();
                aObj.fComputedDataType=true;
            end
        end


        function ComputeDataType(aObj)%#ok
        end


        function out=ContainsExecutable(aObj)
            out=aObj.IsExecutable();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsExecutable()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=IsUnsupportedAst(aObj)%#ok
            out=false;
        end


        function out=ContainsUnsupportedAST(aObj)
            out=aObj.IsUnsupportedAst();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsUnsupportedAST()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsUnsupportedFunction(aObj)
            out=aObj.IsUnsupportedFunction();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsUnsupportedFunction()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsUnsupportedEnumOperations(aObj)
            out=false;
            supportsEnumType=aObj.supportsEnumOperation();
            children=aObj.getChildren();

            if~supportsEnumType
                isEnumDataType=arrayfun(@(x)...
                (Simulink.data.isSupportedEnumClass(x{:}.getDataType)),...
                children);
                if any(isEnumDataType)
                    out=true;
                    return;
                end
            end


            for i=1:numel(children)
                if children{i}.ContainsUnsupportedEnumOperations()
                    out=true;
                    return;
                end
            end


        end


        function out=ContainsEventTrigger(aObj)
            out=aObj.IsEventTrigger();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsEventTrigger()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsCustomData(aObj)
            out=aObj.IsCustomData();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsCustomData()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsEnumCast(aObj)
            out=aObj.IsEnumCast();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsEnumCast()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsTime(aObj)
            out=aObj.IsTime();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsTime()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsContextSensitiveConstant(aObj)
            out=aObj.IsContextSensitiveConstant();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsContextSensitiveConstant()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsInvalidMixedType(aObj)
            out=aObj.IsInvalidMixedType();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsInvalidMixedType()
                        out=true;
                        return
                    end
                end
            end
        end


        function out=ContainsInvalidOperandType(aObj)
            out=aObj.IsInvalidOperandType();
            if~out
                children=aObj.getChildren();
                for i=1:numel(children)
                    if children{i}.ContainsInvalidOperandType()
                        out=true;
                        return
                    end
                end
            end
        end


        function[flag,out]=getParentFuncAst(aObj)

            out=aObj;
            parent=aObj.getParent;
            while isa(parent,'slci.ast.SFAst')&&~isa(parent,'slci.ast.SFAstMatlabFunctionDef')
                parent=parent.getParent;

                if(parent==aObj.getRootAst)
                    break;
                end
            end
            if~isa(parent,'slci.ast.SFAst')

                flag=false;
            else
                flag=true;
                out=parent;
            end
        end

        function out=ParentTransition(aObj)
            rootAstParent=aObj.getRootAstOwner();
            if isa(rootAstParent,'slci.stateflow.Transition')
                out=rootAstParent;
            else
                out=[];
            end
        end

        function out=ParentState(aObj)
            rootAstParent=aObj.getRootAstOwner();
            if isa(rootAstParent,'slci.stateflow.SFState')
                out=rootAstParent;
            else
                out=[];
            end
        end

        function out=ParentChart(aObj)
            rootAstParent=aObj.getRootAstOwner();
            if isa(rootAstParent,'slci.stateflow.Transition')||...
                isa(rootAstParent,'slci.stateflow.SFState')||...
                isa(rootAstParent,'slci.stateflow.TruthTable')
                out=rootAstParent.ParentChart();
            elseif isa(rootAstParent,'slci.matlab.EMChart')
                out=rootAstParent;
            else
                out=[];
            end
        end

        function out=ParentBlock(aObj)
            rootAstParent=aObj.getRootAstOwner();
            if isa(rootAstParent,'slci.simulink.Block')
                out=rootAstParent;
            else
                parentChart=aObj.ParentChart();
                if~isempty(parentChart)
                    out=parentChart.ParentBlock();
                else
                    DAStudio.error('Slci:compatibility:UnknownAstParent');
                end
            end
        end

        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end

        function out=getRootAst(aObj)
            out=aObj.fRootAst;
        end

        function out=hasMtree(aObj)
            out=~isempty(aObj.fMtree);
        end

        function out=getMtree(aObj)
            assert(aObj.hasMtree());
            out=aObj.fMtree;
        end

        function setRootAst(aObj)
            assert(~isempty(aObj.fParent),'No parent found for Ast');
            if~isa(aObj.fParent,'slci.ast.SFAst')

                aObj.fRootAst=aObj;
            else
                aObj.fRootAst=aObj.fParent.getRootAst();
            end
        end

        function out=getRootAstOwner(aObj)
            rootAst=aObj.getRootAst();
            out=rootAst.fParent;
        end

        function out=getChildren(aObj)
            out=aObj.fChildren;
        end

        function out=getParent(aObj)
            out=aObj.fParent;
        end

        function out=appendChild(aObj,astClass,objChild)%#ok


            if isempty(meta.class.fromName(astClass))
                cmd='aObj.fChildren{end+1} = slci.ast.SFAstUnsupported(objChild, aObj);';
            else
                cmd=['aObj.fChildren{end+1} = ',astClass,'(objChild, aObj);'];
            end
            eval(cmd);
            out=aObj.fChildren{end};
        end

    end

    methods


        function setDataDim(aObj,dim)
            aObj.fDataDim=dim;
            aObj.fComputedDataDim=true;
        end


        function out=getDataDim(aObj)
            if~aObj.fComputedDataDim
                aObj.ComputeDataDimOfNodeAndDescendents();
            end

            out=aObj.fDataDim;
        end


        function width=getDataWidth(aObj)
            width=[];
            dim=aObj.getDataDim();
            [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
            if~flag
                return;
            end
            width=prod(dim);
        end


        function out=IsDataObj(aObj)
            out=aObj.ParentChart.IsDataObject(aObj.fId);
        end


        function out=getQualifiedName(aObj)

            assert(isa(aObj,'slci.ast.SFAstIdentifier')||...
            isa(aObj,'slci.ast.SFAstQualifiedId'));
            rootAstOwner=aObj.getRootAstOwner();

            out=[];
            if isa(rootAstOwner,'slci.stateflow.Transition')||...
                isa(rootAstOwner,'slci.stateflow.SFState')||...
                isa(rootAstOwner,'slci.stateflow.TruthTable')

                if aObj.IsDataObj()
                    parentChart=aObj.ParentChart();
                    assert(~isempty(parentChart),'Invalid parent chart');
                    dataObj=parentChart.getDataObject(aObj.fId);
                    out=dataObj.getQualifiedName();
                end
            end
        end
    end

    methods

        function resolvedDim=ResolveDataDim(aObj)
            children=aObj.getChildren();
            if numel(children)==1
                resolvedDim=children{1}.getDataDim();
            else

                for k=1:numel(children)
                    if any(children{k}.getDataDim()>1)
                        resolvedDim=children{k}.getDataDim;
                        return;
                    end
                end
                resolvedDim=children{1}.getDataDim();
            end
        end

        function ComputeDataDimOfNodeAndDescendents(aObj)
            if~aObj.fComputedDataDim
                children=aObj.getChildren();
                for i=1:numel(children)
                    ComputeDataDimOfNodeAndDescendents(children{i});
                end
                aObj.ComputeDataDim();
                aObj.fComputedDataDim=true;
            end
        end


        function ComputeDataDim(aObj)%#ok
        end


        function computeSIDForMatlab(aObj)
            if isa(aObj.getRootAstOwner(),'slci.matlab.EMChart')...
                &&aObj.hasMtree()
                chart=aObj.ParentChart();
                rootAst=aObj.getRootAst();
                assert(isa(rootAst,'slci.ast.SFAstMatlabFunctionDef'));
                [flag,scriptPath]=...
                slci.matlab.astProcessor.MatlabFunctionUtils.getScriptPath(rootAst);
                if flag

                    toks=regexp(scriptPath,'^(#)(.*)','tokens');
                    if~isempty(toks)
                        chartUDDObj=chart.getUDDObject();
                        stateId=sf('get',chartUDDObj.Id,'.states');
                        ssidNum=sf('get',stateId,'.ssIdNumber');
                        parent=[chart.getSID(),':',int2str(ssidNum)];
                    else
                        parent=scriptPath;
                    end
                    startPos=lefttreepos(aObj.getMtree());
                    endPos=righttreepos(aObj.getMtree());


                    startPos=startPos-1;
                    sid=[parent,':'...
                    ,int2str(startPos),'-',int2str(endPos)];
                    aObj.setSID(sid);
                end
            end
        end


        function setChildren(aObj,aChildren)

            assert(iscell(aChildren));
            aObj.fChildren=aChildren;

        end


    end


    methods(Access=protected)


        function aObj=SFAst(aAstObj,aParent)
            if isempty(aAstObj)
                return
            end

            aObj.fParent=aParent;
            aObj.setRootAst();

            astObj=aAstObj;
            if(isa(aObj.getParent,'slci.stateflow.Transition')...
                ||isa(aObj.getParent,'slci.stateflow.SFState'))...
                &&strcmpi(slci.internal.getLanguageFromSFObject(aObj.getParent.ParentChart),'MATLAB')







                sourceSnippet=aAstObj.roots{1}.sourceSnippet;







                for i=2:numel(aAstObj.roots)
                    root=aAstObj.roots{i};


                    if~isempty(root.sourceSnippet)...
                        &&~strcmp(root.sourceSnippet,newline)
                        sourceSnippet=[sourceSnippet,root.sourceSnippet;];%#ok<AGROW> 
                    end
                end

                if isempty(strip(sourceSnippet))
                    return
                end

                modifiedSourceSnippet=aObj.modifySourceSnippet(sourceSnippet);
                mt=mtree(modifiedSourceSnippet);

                if mt.isempty
                    return
                end
                astObj=mtfind(list(mt.root),'Kind',{'IF','SWITCH','EXPR','PRINT','DCALL'});
            end

            if isa(astObj,'mtree')
                aObj.fMtree=astObj;
            end

            if isa(astObj,'mtree')...
                &&(isa(aObj.getParent,'slci.stateflow.Transition')...
                ||isa(aObj.getParent,'slci.stateflow.SFState'))...
                &&strcmpi(slci.internal.getLanguageFromSFObject(aObj.getParent.ParentChart),'MATLAB')
                aObj.populateChildrenFromSFMtreeNode(astObj);
            elseif isa(astObj,'mtree')
                aObj.populateChildrenFromMtreeNode(astObj);
            else
                aObj.populateChildrenFromSFAstNode(astObj);
            end

            aObj.computeSIDForStateflow();

            if(isa(aObj.getRootAstOwner,'slci.stateflow.Transition')...
                ||isa(aObj.getRootAstOwner,'slci.stateflow.SFState'))...
                &&strcmpi(slci.internal.getLanguageFromSFObject(aObj.getParent.ParentChart),'MATLAB')


                slci.matlab.astTranslator.resolveLBNodes(aObj);
            end

            if((isa(aObj.getRootAstOwner,'slci.stateflow.Transition')...
                ||isa(aObj.getRootAstOwner,'slci.stateflow.SFState')...
                ||isa(aObj.getRootAstOwner,'slci.stateflow.TruthTable'))...
                &&aObj.getRootAstOwner.needConstraints)...
                ||isa(aObj.getRootAstOwner,'slci.matlab.EMChart')
                aObj.addConstraints();
            end

            if isa(aObj.getRootAstOwner.ParentChart,'slci.stateflow.Chart')...
                &&strcmpi(slci.internal.getLanguageFromSFObject(aObj.getParent.ParentChart),'MATLAB')
                aObj.getRootAstOwner.ParentChart.addSFAst(aObj);
            end
        end


        function computeSIDForStateflow(aObj)
            parentTransition=aObj.ParentTransition();
            if~isempty(parentTransition)
                aObj.setSID(parentTransition.getSID());
            else
                parentState=aObj.ParentState();
                if~isempty(parentState)
                    aObj.setSID(parentState.getSID());
                end
            end
        end


        function populateChildrenFromMtreeNode(aObj,inputObj)
            [success,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(success,...
            DAStudio.message('Slci:slci:unsupportedNodeMtree',class(inputObj)));
            for k=1:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
                if isAstNeeded
                    assert(~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                end
            end
        end


        function populateChildrenFromSFMtreeNode(aObj,inputObj)








            if isa(aObj,'slci.ast.SFAstRoot')&&(aObj.fMtree.count==1)
                [~,child]=slci.matlab.astTranslator.createAst(inputObj,aObj);
                if isa(child,'slci.ast.SFAstUnsupported')
                    aObj.fChildren{end+1}=child;
                    return;
                end
            end
            if~isempty(inputObj)
                mtObjs=slci.mlutil.getListNodes(inputObj);
                for i=1:numel(mtObjs)


                    if~aObj.isDummyFunctionNode(mtObjs{i})
                        aObj.populateChildrenFromMtreeNode(mtObjs{i});
                    end
                end
            end
        end


        function populateChildrenFromSFAstNode(aObj,inputObj)

            switch class(inputObj)
            case{'Stateflow.Ast.ConditionSection',...
                'Stateflow.Ast.ConditionActionSection',...
                'Stateflow.Ast.EntrySection',...
                'Stateflow.Ast.DuringSection',...
                'Stateflow.Ast.ExitSection'}
                children=inputObj.roots;
            otherwise
                children=inputObj.children;
            end


            for i=1:numel(children)
                objChild=children{i};
                objChildClass=class(objChild);
                scan=textscan(objChildClass,'%s','Delimiter','.');
                objChildClass=scan{1}{3};
                astClass=['slci.ast.SFAst',objChildClass];
                aObj.appendChild(astClass,objChild);
            end

        end





        function out=isDummyFunctionNode(aObj,mtreeNode)
            rootAstOwner=aObj.getRootAstOwner;
            out=isa(mtreeNode,'mtree')...
            &&strcmpi(mtreeNode.kind,'FUNCTION')...
            &&(isa(rootAstOwner,'slci.stateflow.Transition')...
            ||isa(rootAstOwner,'slci.stateflow.SFState'))...
            &&isa(rootAstOwner.ParentChart,'slci.stateflow.Chart');
        end

    end

    methods(Access=protected)


        function addConstraints(aObj)

            if isa(aObj.getRootAstOwner,'slci.matlab.EMChart')
                aObj.addMatlabFunctionConstraints();

            elseif isa(aObj.getRootAstOwner.ParentChart,'slci.stateflow.Chart')...
                &&strcmpi(aObj.getRootAstOwner.ParentChart.getActionLanguage,'MATLAB')
                aObj.addMatlabFunctionConstraints();
                aObj.addConstraint(slci.compatibility.MatlabFunctionUnsupportedAstConstraint);
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMixedDataDimConstraint,...
            slci.compatibility.MatlabFunctionUnsupportedAstConstraint,...
            slci.compatibility.MatlabFunctionMixedDatatypeConstraint,...
            };
            aObj.setConstraints(newConstraints);
        end




        function modifiedSourceSnippet=modifySourceSnippet(aObj,originalSourceSnippet)
            relationalOpPatternWithoutSpace='(?:<=?|>=?|==|~=|=)';
            relationalOpPatternWithSpace='(?: <=? | >=? | == | ~= | = )';



            if~contains(originalSourceSnippet,...
                regexpPattern(relationalOpPatternWithoutSpace))...
                ||contains(originalSourceSnippet,...
                regexpPattern(relationalOpPatternWithSpace))
                modifiedSourceSnippet=[originalSourceSnippet,newline,aObj.getParent.ParentChart.getDummySFFunctions];
                return
            end


            [delim,condSourceSnippet]=regexp(strip(originalSourceSnippet),';','match','split');

            condSourceSnippet=condSourceSnippet(~cellfun('isempty',condSourceSnippet));

            if~isempty(delim)
                delim=delim{1};
            else
                delim='';
            end
            modifiedSourceSnippet='';
            for idx=1:numel(condSourceSnippet)
                [boolOp,identifier]=regexp(condSourceSnippet{idx},relationalOpPatternWithoutSpace,'match','split');

                identifier=cellfun(@strip,identifier,'UniformOutput',false);
                if isempty(boolOp)
                    break;
                end
                joinedSnippet=strjoin([identifier{1},' ',boolOp,' ',identifier{2}],'');

                modifiedSourceSnippet=[modifiedSourceSnippet,newline,[joinedSnippet,delim]];%#ok<AGROW>
            end
            modifiedSourceSnippet=[modifiedSourceSnippet,newline,aObj.getParent.ParentChart.getDummySFFunctions];

        end

    end

    methods(Access=public)


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.common.BdObject(aObj);

            children=aObj.getChildren();
            numCh=numel(children);
            for k=1:numCh
                out=[out,children{k}.checkCompatibility()];%#ok
            end
        end

    end


end




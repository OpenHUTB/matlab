











classdef SFAstColon<slci.ast.SFAst

    properties(Access=protected)
        fNumOfChildren=0;
    end

    methods(Access=protected)


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);


            [isSubscriptIndex,~,~]=aObj.isSubscriptIndex();
            if isSubscriptIndex
                aObj.setDataType('double');
            else




                aObj.setDataType(aObj.ResolveDataType());
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

            [flag,dataDim]=...
            slci.matlab.astProcessor.AstSlciInferenceUtil.evalDim(aObj);
            if flag
                assert(~isequal(dataDim,-1));
                aObj.setDataDim(dataDim);
                return;
            end


            [found,width]=getSubscriptIndexWidth(aObj);
            if found
                aObj.setDataDim(width);
                return;
            end
        end



        function setNumOfChildren(aObj)
            children=aObj.getChildren();
            if isempty(children)
                aObj.fNumOfChildren=0;
                assert(isa(aObj.getParent(),...
                'slci.ast.SFAstArray'));
            else
                aObj.fNumOfChildren=numel(children);
            end
        end


        function out=hasEmptyChildren(aObj)
            out=(aObj.fNumOfChildren==0);
        end


        function aObj=SFAstColon(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstColon').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.setNumOfChildren();
        end

    end

    methods(Access=private)


        function[out,parentSubscript,subscriptBase]=isSubscriptIndex(aObj)
            out=false;
            parentSubscript=[];
            subscriptBase=[];
            parent=aObj.getParent();

            while~(isa(parent,'slci.ast.SFAstArray')...
                ||isa(parent,'slci.matlab.EMChart')...
                ||isa(parent,'slci.ast.SFAstFor')...
                ||isa(parent,'slci.ast.SFAstEqualAssignment'))
                current=parent;
                parent=current.getParent();
            end
            if isa(parent,'slci.ast.SFAstArray')
                out=true;
                parentSubscript=parent;
                subscriptBase=parent.getChildren{1};
            end
        end



        function[found,width]=getSubscriptIndexWidth(aObj)
            found=false;
            width=-1;
            [isSubscriptIndex,parentSubscript,subscriptBase]=...
            aObj.isSubscriptIndex();

            if isSubscriptIndex
                [found,arrayIndexPos]=...
                getIndexPos(aObj,parentSubscript,aObj);
                if found
                    if parentSubscript.fComputedDataDim


                        subscriptDim=parentSubscript.getDataDim();
                        missingDim=isequal(subscriptDim,-1);
                        if~missingDim&&arrayIndexPos<=numel(subscriptDim)
                            if numel(parentSubscript.getChildren())==2

                                [flag,subscriptDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,subscriptDim);
                                if~flag
                                    found=false;
                                    return;
                                end
                                width=prod(subscriptDim);
                            else
                                width=subscriptDim(arrayIndexPos);
                            end
                        end
                    elseif subscriptBase.fComputedDataDim...
                        &&~isequal(subscriptBase.getDataDim,-1)...
                        &&aObj.hasEmptyChildren()


                        numChild=numel(parentSubscript.getChildren());
                        if(numChild==2)

                            [flag,baseDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,subscriptBase.getDataDim());
                            if~flag
                                found=false;
                                return;
                            end
                            width=prod(baseDim);
                        elseif numChild>2

                            baseDim=subscriptBase.getDataDim();
                            width=baseDim(arrayIndexPos);
                        end
                    end
                end
            end
        end


        function[out,pos]=getIndexPos(aObj,parentAst,childAst)%#ok
            out=false;
            pos=0;
            children=parentAst.getChildren();

            for i=2:numel(children)
                if children{i}==childAst
                    out=true;

                    pos=i-1;
                    return;
                end
            end
        end


        function children=getColonMtreeChildren(aObj,inputObj)
            children={};
            [success,mtreeChildren]=slci.mlutil.getMtreeChildren(inputObj);
            assert(success,...
            DAStudio.message('Slci:slci:unsupportedNodeMtree',...
            class(inputObj)));
            for i=1:numel(mtreeChildren)
                child=mtreeChildren{i};
                if strcmpi(child.kind,'COLON')
                    child_children=aObj.getColonMtreeChildren(child);
                    children=[children,child_children];%#ok
                else
                    children{end+1}=child;%#ok
                end
            end
        end

    end

    methods(Access=protected)

        function populateChildrenFromMtreeNode(aObj,inputObj)
            children=aObj.getColonMtreeChildren(inputObj);
            for k=1:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
                if isAstNeeded
                    assert(~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionScalarOperandsConstraint,...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionColonDatatypeConstraint,...
            slci.compatibility.MatlabFunctionColonChildrenNumConstraint};
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end

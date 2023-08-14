












classdef SFAstCoderConst<slci.ast.SFAstMatlabDirective
    properties
        fIsConst=false;
        fValue=0;
    end

    methods


        function aObj=SFAstCoderConst(aAstObj,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstCoderConst'));
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,aParent);

            aObj.resolveValue();
        end


        function ComputeDataType(aObj)
            if aObj.isConst

                aObj.setDataType(class(aObj.fValue));
            elseif aObj.isExpressionEval

                children=aObj.getChildren();
                aObj.setDataType(children{1}.getDataType());
            end

        end


        function ComputeDataDim(aObj)
            if aObj.isConst

                aObj.setDataDim(size(aObj.fValue));
            elseif aObj.isExpressionEval

                children=aObj.getChildren();
                aObj.setDataDim(children{1}.getDataDim());
            end

        end


        function resolveValue(aObj)
            children=aObj.getChildren();
            if aObj.isExpressionEval

                child=children{1};
                assert(child.hasMtree());
                mt=child.getMtree();
                str=mt.tree2str();
                [success,value]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalStr(str);
                aObj.fIsConst=success;
                aObj.fValue=value;
            end
        end


        function out=isConst(aObj)
            out=aObj.fIsConst;
        end


        function value=getValue(aObj)
            value=double(aObj.fValue);
        end


        function out=isExpressionEval(aObj)
            out=numel(aObj.getChildren())==1;
        end




        function out=isFunctionEval(aObj)
            out=numel(aObj.getChildren())>1;
        end

    end

    methods(Access=protected)


















        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmp(inputObj.kind,{'SUBSCR','CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);






            assert(strcmpi(children{1}.kind,'DOT'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstCoderConst'));

            for k=2:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=...
                slci.matlab.astTranslator.createAst(child,aObj);
                assert(isAstNeeded);
                assert(~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end


        function addMatlabFunctionConstraints(aObj)

            newConstraints={...
            slci.compatibility.MatlabFunctionCoderConstConstraint...
            };
            aObj.setConstraints(newConstraints);
        end

    end


end

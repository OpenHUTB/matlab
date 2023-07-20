











classdef SFAstMinMax<slci.ast.SFAst

    properties
        fOmitNAN=true;
    end

    methods


        function aObj=SFAstMinMax(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();

            aObj.setDataType(children{1}.getDataType());
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

        end


        function out=getOmitNAN(aObj)
            out=aObj.fOmitNAN;
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag&&numel(children)>=2);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            for k=2:numel(children)
                child=children{k};
                if strcmpi(child.kind,'CHARVECTOR')

                    str=strrep(child.string,'''','');
                    assert(any(strcmpi(str,{'omitnan','includenan'})));
                    aObj.fOmitNAN=strcmpi(str,'omitnan');
                else


                    [isAstNeeded,cObj]=...
                    slci.matlab.astTranslator.createAst(child,aObj);
                    assert(isAstNeeded&&~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={};
            if~aObj.hasMultiOutputs()


                newConstraints{end+1}=...
                slci.compatibility.MatlabFunctionMissingDimConstraint;
            end

            if(numel(aObj.getChildren())==2)

                newConstraints{end+1}=...
                slci.compatibility.MatlabFunctionMixedDatatypeConstraint;

                newConstraints{end+1}=...
                slci.compatibility.MatlabFunctionMixedDataDimConstraint;
            end
            if~isempty(newConstraints)
                aObj.setConstraints(newConstraints);
            end
        end

    end

    methods(Access=private)


        function out=hasMultiOutputs(aObj)
            out=false;
            if isa(aObj.getParent(),'slci.ast.SFAstEqualAssignment')
                assignAst=aObj.getParent();
                children=assignAst.getChildren();
                assert(numel(children)>0)
                out=isa(children{1},'slci.ast.SFAstConcatenateLB')...
                &&(numel(children{1}.getChildren())>1);
            end
        end
    end

end

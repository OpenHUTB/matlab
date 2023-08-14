



classdef SFAstCastFunction<slci.ast.SFAst

    properties












        fTypeValIndex=0;


        fLikeArgIndex=0;
    end


    methods


        function aObj=SFAstCastFunction(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataDim(aObj)
            children=aObj.getChildren();

            aObj.fDataDim=children{1}.getDataDim();
        end


        function ComputeDataType(aObj)
            if aObj.hasMtree()

                if~isempty(aObj.getLikeArg())


                    aObj.fDataType=aObj.getLikeArg().getDataType();
                else
                    assert(~isempty(aObj.getTypeValue()));


                    [success,typeStr]=aObj.readTypeNode(aObj.getTypeValue());
                    if success
                        assert(~isempty(typeStr));
                        if strcmpi(typeStr,'logical')
                            typeStr='boolean';
                        end
                        aObj.fDataType=typeStr;
                    end
                end
            else


                children=aObj.getChildren();
                aObj.fDataType=children{2}.getDataType();
            end
        end


        function val=getTypeValue(aObj)
            val=[];
            if aObj.fTypeValIndex>0
                assert(aObj.fTypeValIndex<=numel(aObj.fChildren));
                val=aObj.fChildren{aObj.fTypeValIndex};
            end
        end


        function val=getLikeArg(aObj)
            val=[];
            if aObj.fLikeArgIndex>0
                assert(aObj.fLikeArgIndex<=numel(aObj.fChildren));
                val=aObj.fChildren{aObj.fLikeArgIndex};
            end
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag&&numel(children)>=3);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');


            child=children{2};
            [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
            assert(isAstNeeded&&~isempty(cObj));
            aObj.fChildren{1}=cObj;


            child=children{3};
            if strcmpi(child.kind,'CHARVECTOR')

                str=children{3}.string;
                tokens=regexp(str,'^('')(\s*like\s*)('')$','tokens');
                if~isempty(tokens)
                    assert(numel(children)==4);
                    child=children{4};
                    [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
                    assert(isAstNeeded&&~isempty(cObj));
                    aObj.fLikeArgIndex=2;
                    aObj.fChildren{aObj.fLikeArgIndex}=cObj;
                    return;
                end
            end


            [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
            assert(isAstNeeded&&~isempty(cObj));
            aObj.fTypeValIndex=2;
            aObj.fChildren{aObj.fTypeValIndex}=cObj;
        end


        function[success,type]=readTypeNode(~,typeAst)

            success=false;
            type='';

            assert(isa(typeAst,'slci.ast.SFAst'));







            if isa(typeAst,'slci.ast.SFAstString')
                type=typeAst.getValue();
                success=true;
            end
        end

    end

    methods(Access=protected)


        function addConstraints(aObj)
            addConstraints@slci.ast.SFAst(aObj);




            fTypeValue=aObj.getTypeValue();
            if~isempty(fTypeValue)
                constraintsToRemove={'MatlabFunctionUnsupportedAst',...
                'MatlabFunctionDatatype',...
                'MatlabFunctionDimScalar',...
                'MatlabFunctionDimMatrix',...
                'MatlabFunctionMissingDim',...
'MatlabFunctionMissingDatatype'...
                ,'MatlabFunctionMixedDatatype'...
                };
                fTypeValue.removeConstraints(constraintsToRemove);
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionDatatypeConstraint,...
            slci.compatibility.MatlabFunctionCastArgConstraint};
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end


end

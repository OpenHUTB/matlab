



classdef SFAstMathBuiltin<slci.ast.SFAst

    properties(Access=private)

        fType='';
    end

    properties(Constant=true)

        fnTypes={'acos',...
        'asin',...
        'atan',...
        'atan2',...
        'cos',...
        'sin',...
        'tan',...
        'sqrt',...
        'abs',...
        'mod',...
        'rem',...
        'log',...
        'log10',...
        'exp',...
        'hypot',...
        'pow2',...
        'ceil',...
        'floor',...
        'fix',...
'round'
        };
    end

    methods


        function aObj=SFAstMathBuiltin(input,type,aParent)
            aObj=aObj@slci.ast.SFAst(input,aParent);
            assert(ischar(type));
            assert(slci.ast.SFAstMathBuiltin.isMathType(type),...
            DAStudio.message('Slci:slci:InvalidMathFunction',type));
            aObj.fType=type;
        end



        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();
            assert(~isempty(children));
            for k=1:numel(children)
                dataType=children{k}.getDataType();
                if~isempty(dataType)
                    aObj.setDataType(dataType);
                    return;
                end
            end
        end



        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();
            assert(~isempty(children));
            dim=[];
            for k=1:numel(children)
                if~isequal(children{k}.getDataDim(),-1)
                    dim=children{k}.getDataDim();
                    if any(dim>1)


                        aObj.setDataDim(dim);
                        return;
                    end
                end
            end
            if~isempty(dim)
                aObj.setDataDim(dim);
            end
        end


        function fType=getMathType(aObj)
            assert(~isempty(aObj.fType));
            fType=aObj.fType;
        end

    end

    methods(Static=true)


        function flag=isMathType(fname)
            flag=any(strcmp(fname,slci.ast.SFAstMathBuiltin.fnTypes));
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmp(inputObj.kind,{'CALL','LP','SUBSCR'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(...
            inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),...
            DAStudio.message('Slci:slci:unsupportedNodeMtree','CALL'));

            for k=2:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=...
                slci.matlab.astTranslator.createAst(child,aObj);
                assert(isAstNeeded&&~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end


        function addMatlabFunctionConstraints(aObj)


            newConstraints={...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'}),...
            };

            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(...
            aObj);
        end

    end


end


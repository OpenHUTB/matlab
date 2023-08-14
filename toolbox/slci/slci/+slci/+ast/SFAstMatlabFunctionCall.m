



classdef SFAstMatlabFunctionCall<slci.ast.SFAst

    properties

        fName='';

        fFID=int32(-1);
    end

    methods


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end




        function aObj=SFAstMatlabFunctionCall(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            assert(isa(aAstObj,'mtree'),...
            'Invalid MATLAB Function Call Ast');
            if strcmpi(aAstObj.kind,'ID')
                aObj.fName=aAstObj.string;
            else
                assert(any(strcmpi(aAstObj.kind,{'CALL','LP','SUBSCR'})));
                assert(strcmpi(aAstObj.Left.kind,'ID'),...
                'Invalid function node');
                aObj.fName=aAstObj.Left.string;
            end
        end


        function name=getName(aObj)
            name=aObj.fName;
        end


        function inputArgs=getInputs(aObj)
            inputArgs=aObj.fChildren;
        end


        function fid=getFunctionID(aObj)
            fid=aObj.fFID;
        end


        function setFunctionID(aObj,fid)
            assert((aObj.fFID==-1||aObj.fFID==fid)...
            ,'Overwriting function ID');
            aObj.fFID=int32(fid);
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(isa(inputObj,'mtree'));


            if strcmpi(inputObj.kind,'ID')

            else
                assert(any(strcmpi(inputObj.kind,{'CALL','LP','SUBSCR'})));
                if~isempty(inputObj.Right)
                    mtreeNodes=slci.mlutil.getListNodes(inputObj.Right);
                    aObj.fChildren=cell(1,numel(mtreeNodes));
                    for k=1:numel(mtreeNodes)
                        [isAstNeeded,astObj]=slci.matlab.astTranslator.createAst(...
                        mtreeNodes{k},aObj);
                        assert(isAstNeeded&&~isempty(astObj));
                        aObj.fChildren{1,k}=astObj;
                    end
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMissingFunctionIDConstraint};

            aObj.setConstraints(newConstraints);
        end

    end

end

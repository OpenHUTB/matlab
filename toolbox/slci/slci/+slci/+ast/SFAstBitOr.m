



classdef SFAstBitOr<slci.ast.SFAstBitOp

    methods(Access=protected)

        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods

        function ComputeDataType(aObj)
            if aObj.hasMtree()

                children=aObj.getChildren();
                assert(numel(children)==2);
                dtype1=children{1}.getDataType();
                dtype2=children{2}.getDataType();
                if strcmpi(dtype1,dtype2)
                    aObj.fDataType=dtype1;
                    return;
                end

                isInteger={'int32','int16','int8','uint32',...
                'uint16','uint8','uint64','int64'};
                if any(ismember(isInteger,dtype1))
                    aObj.fDataType=dtype1;
                elseif any(ismember(isInteger,dtype2))
                    aObj.fDataType=dtype2;
                else
                    aObj.fDataType='double';
                end
            else

                aObj.fDataType=aObj.ResolveDataType();
                if strcmp(aObj.fDataType,'boolean')
                    aObj.fDataType='uint32';
                end
                if strcmp(aObj.fDataType,'single')||...
                    strcmp(aObj.fDataType,'double')
                    aObj.fDataType='int32';
                end
            end
        end


        function ComputeDataDim(aObj)

            aObj.fDataDim=aObj.ResolveDataDim();
        end

        function aObj=SFAstBitOr(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstBitOp(aAstObj,aParent);
        end

    end

end

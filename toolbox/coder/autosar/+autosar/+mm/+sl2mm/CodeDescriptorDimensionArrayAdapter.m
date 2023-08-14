classdef CodeDescriptorDimensionArrayAdapter





    methods(Static)
        function dimensionArray=getDimensionArray(embeddedTypeObj,codeType)



            if embeddedTypeObj.isPointer
                dimensionArray=1;
            elseif embeddedTypeObj.HasSymbolicDimensions
                if isa(embeddedTypeObj,'coder.descriptor.types.Matrix')
                    dimensionArray=embeddedTypeObj.SymbolicDimensions.toArray;
                else
                    dimensionArray=embeddedTypeObj.SymbolicDimensions;
                end

                if isempty(codeType)||...
                    ~autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.isNdMatrixType(codeType)
                    dimensionArray=cellstr(embeddedTypeObj.SymbolicWidth);
                else

                    if numel(dimensionArray)>1&&strcmp(dimensionArray{1},'1')
                        dimensionArray(1)=[];
                    end


                    if numel(dimensionArray)>1&&strcmp(dimensionArray{end},'1')
                        dimensionArray(end)=[];
                    end
                end
            else
                if isa(embeddedTypeObj,'coder.descriptor.types.Matrix')
                    dimensionArray=embeddedTypeObj.Dimensions.toArray;
                else
                    dimensionArray=embeddedTypeObj.Dimensions;
                end

                if isempty(codeType)||...
                    ~autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.isNdMatrixType(codeType)
                    dimensionArray=prod(dimensionArray);
                else

                    if numel(dimensionArray)>1&&dimensionArray(1)==1
                        dimensionArray(1)=[];
                    end


                    if numel(dimensionArray)>1&&dimensionArray(end)==1
                        dimensionArray(end)=[];
                    end
                end
            end
        end

        function isScalar=isMatrixOfSizeOne(embeddedTypeObj,codeType)


            assert(embeddedTypeObj.isMatrix,'Expected matrix');
            dimensionsArray=...
            autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.getDimensionArray(embeddedTypeObj,codeType);
            isScalar=prod(dimensionsArray)==1;
        end

        function isNdMatrixType=isNdMatrixType(codeType)


            isNdMatrixType=false;
            if isa(codeType,'coder.descriptor.types.Matrix')
                dims=codeType.Dimensions.toArray();
                dims(dims==1)=[];
                if numel(dims)>1
                    isNdMatrixType=true;
                end
            end
        end
    end

end



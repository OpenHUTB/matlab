classdef PortDimensionsWriter<handle





    properties(Access=protected)
Writer
ModelInterface
    end

    methods(Access=public)
        function this=PortDimensionsWriter(modelInterface,writer)
            this.ModelInterface=modelInterface;
            this.Writer=writer;
        end

        function write(this,portType,port,portIdxStr,portCodeInfo)

            [ndims,symbDims,symbWidth]=this.getSymbDimensionsInfo(port,portCodeInfo);

            isDynamicArray=false;
            for i=1:length(symbDims)
                currentStr=symbDims{i};
                if deblank(currentStr)=="Inf"
                    isDynamicArray=true;
                    break;
                end
            end

            if(isDynamicArray||port.IsString)
                symbDims='1';
                ndims=1;
                symbWidth='1';
            end

            if(ndims==this.ModelInterface.MatrixDimensionThreshhold)
                this.Writer.writeLine(...
                'if(!ssSet%sputPortMatrixDimensions(S, %s, %s, %s)) return;',...
                portType,portIdxStr,deblank(symbDims{1}),deblank(symbDims{2}));
            elseif(ndims>this.ModelInterface.MatrixDimensionThreshhold)
                dimsStr=strjoin(deblank(symbDims),', ');
                dimsStr=strcat('{',dimsStr,'}');
                portDimsStr=[lower(portType),'Dims'];
                portDimValuesStr=[lower(portType),'DimsVals'];
                this.Writer.writeChar('{');
                this.Writer.writeLine('DimsInfo_T %s;',portDimsStr)
                this.Writer.writeLine('int_T %s[%d] = %s;',portDimValuesStr,ndims,dimsStr);
                this.Writer.writeLine('%s.width = %s;',portDimsStr,symbWidth);
                this.Writer.writeLine('%s.numDims = %d;',portDimsStr,ndims);
                this.Writer.writeLine('%s.dims = %s;',portDimsStr,portDimValuesStr);
                this.Writer.writeLine('%s.nextSigDims = %s;',portDimsStr,coder.internal.modelreference.DataTypeUtils.getNullDefinition);
                this.Writer.writeLine('if (!ssSet%sputPortDimensionInfo(S, %s, &%s)) return;',portType,portIdxStr,portDimsStr);
                this.Writer.writeChar('}');
            else
                this.Writer.writeLine('if(!ssSet%sputPortVectorDimension(S, %s, %s)) return;',...
                portType,portIdxStr,symbWidth);
            end
        end
    end

    methods(Access=protected)
        function[numDims,dims,width]=getSymbDimensionsInfo(~,port,~)

            numDims=size(port.SymbolicDims,1);
            dims=cell(numDims,1);
            for idx=1:numDims
                dims{idx}=port.SymbolicDims(idx,:);
            end
            width=port.SymbolicPortWidth;
        end
    end
end



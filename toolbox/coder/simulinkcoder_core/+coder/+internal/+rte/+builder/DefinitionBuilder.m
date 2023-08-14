classdef DefinitionBuilder<handle




    properties
        DataBuilder;
        ProtoBuilder;
        FunctionType;
    end

    methods
        function this=DefinitionBuilder(protoBuilder,dataBuilder,fcnType)
            this.ProtoBuilder=protoBuilder;
            this.DataBuilder=dataBuilder;
            this.FunctionType=fcnType;
        end

        function writeToFile(this,writer)
            writer.wLine(this.ProtoBuilder.emit);
            writer.wBlockStart('');
            for lineIdx=1:length(this.emit)
                writer.wLine(this.emit{lineIdx});
            end
            writer.wBlockEnd('');
        end
    end

    methods
        function def=emit(this)
            if(this.FunctionType==coder.descriptor.DataTransferFunctionType.Get)
                def=this.DataBuilder.getReaderImplementation;
            else
                def=this.DataBuilder.getWriterImplementation;
            end
        end
    end
end

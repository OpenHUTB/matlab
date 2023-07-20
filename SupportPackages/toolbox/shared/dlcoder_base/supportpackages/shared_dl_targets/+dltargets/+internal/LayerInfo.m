classdef LayerInfo<handle

























    properties(SetAccess=private)
inputSizes
inputFormats
outputSizes
outputFormats
hasSequenceOutput
hasSequenceInput
hasDlarrayInputs
    end

    methods


        function this=LayerInfo(inputSize,inputFormat,outSize,outputFormat,hasSequenceOut,hasSequenceInput,...
            hasDlarrayInputs)
            this.inputSizes=inputSize;
            this.inputFormats=inputFormat;
            this.outputSizes=outSize;
            this.outputFormats=outputFormat;
            this.hasSequenceOutput=hasSequenceOut;
            this.hasSequenceInput=hasSequenceInput;
            this.hasDlarrayInputs=hasDlarrayInputs;
        end

        function val=get.inputSizes(this)
            val=this.inputSizes;
        end

        function val=get.inputFormats(this)
            val=this.inputFormats;
        end

        function val=get.outputSizes(this)
            val=this.outputSizes;
        end

        function val=get.outputFormats(this)
            val=this.outputFormats;
        end

        function val=get.hasSequenceOutput(this)
            val=this.hasSequenceOutput;
        end

        function val=get.hasSequenceInput(this)
            val=this.hasSequenceInput;
        end

        function val=get.hasDlarrayInputs(this)
            val=this.hasDlarrayInputs;
        end

    end

end

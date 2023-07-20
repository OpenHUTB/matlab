classdef MessageLogger<handle













    properties(SetAccess=private)
verbosityLevel
stream
    end

    properties(Constant)
        indent='\t'
        fileName='_fxpoptSession.log';
    end

    methods
        function this=MessageLogger(verbosityLevel,verbosityStream)

            this.verbosityLevel=verbosityLevel;


            this.stream=verbosityStream;
        end

        function publish(this,message,type)


            if type<=this.verbosityLevel
                this.printIndented(message,type);
            end
        end

        function set.stream(this,verbosityStream)
            switch verbosityStream
            case DataTypeOptimization.VerbosityStream.ToStandardOutput
                this.stream=matlab.unittest.plugins.ToStandardOutput;
            case DataTypeOptimization.VerbosityStream.ToFile
                this.stream=DataTypeOptimization.FxpoptToFileStream(this.fileName);
            case DataTypeOptimization.VerbosityStream.ToFixedPointTool
                this.stream=fxptui.Web.FixedPointToolStream;
            otherwise
                this.stream=matlab.unittest.plugins.ToStandardOutput;
            end

        end
    end
    methods(Hidden)

        function printIndented(this,message,type)


            switch(type)
            case DataTypeOptimization.VerbosityLevel.Moderate
                this.stream.print(sprintf('%s+ %s\n',this.indent,message));
            case DataTypeOptimization.VerbosityLevel.High
                this.stream.print(sprintf('%s%s- %s\n',this.indent,this.indent,message));
            end
        end
    end

end
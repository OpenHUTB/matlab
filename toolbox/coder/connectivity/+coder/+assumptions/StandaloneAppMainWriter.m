classdef(Hidden=true)StandaloneAppMainWriter<handle









    properties(SetAccess='private',GetAccess='private')

        Writer;
        MainFilePath;
        ComponentName;
    end


    methods

        function this=StandaloneAppMainWriter(outputPath,componentName)

            this.ComponentName=componentName;
            this.MainFilePath=fullfile(outputPath,...
            coder.assumptions.StandaloneApp.getMainFileName(componentName));
        end


        function writeOutput(this,obfuscateCode)

            args={'append',false,...
            'callCBeautifier',true,...
            'obfuscateCode',obfuscateCode};

            this.Writer=rtw.connectivity.CodeWriter.create('fileName',this.MainFilePath,args{:});


            [~,fname,fext]=fileparts(this.MainFilePath);
            this.Writer.wLine('/*');
            this.Writer.wLine(' * File: %s%s',fname,fext);
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Abstract: Entry point to test assumptions in the generated code.');
            this.Writer.wLine(' */');
            this.Writer.newLine;


            this.Writer.wLine('#include "%s"',...
            coder.assumptions.StandaloneApp.getStaticHFileName);
            this.Writer.newLine;


            this.Writer.wComment(['access results by adding this variable '...
            ,'to the watch in the debugger']);
            this.Writer.wLine('extern volatile CA_Results Results;')

            this.Writer.wBlockStart('int main(void)');
            this.Writer.wComment('call entry point function to run the tests');
            this.Writer.wLine('%s();',...
            coder.assumptions.CoderAssumptions.getEntryPointFcnName(this.ComponentName));
            this.Writer.wLine('return 0;');
            this.Writer.wBlockEnd;
            this.Writer.close;
        end

    end
end
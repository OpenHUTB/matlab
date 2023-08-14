classdef RTEWriter<handle





    properties(GetAccess='protected',SetAccess='private')
        RTEBuilder;
    end

    properties(Access='protected')
        File_h_name;
        File_c_name;

        WriterHFile;
        WriterCFile;
    end

    methods(Access='public')
        function this=RTEWriter(rteBuilder)
            autosar.mm.util.validateArg(rteBuilder,...
            'autosar.mm.mm2rte.RTEBuilder');
            this.RTEBuilder=rteBuilder;
        end



        function writeRTEContractPhaseAPIMapping(this,writer,functionName)
            functionNameWithSWC=regexprep(functionName,'^(Rte|E2EPW)_([a-zA-Z0-9]*)',...
            sprintf('$1_$2_%s',this.RTEBuilder.ASWCName));
            writer.wLine('#define %s %s',functionName,functionNameWithSWC);
        end
    end

    methods(Access='protected')
        function writeFileDescription(this,writer)
            rteBuilder=this.RTEBuilder;
            comments=sprintf(...
            ['This file contains stub implementations of the AUTOSAR RTE functions. \n',...
            'The stub implementations can be used for testing the generated code in \n',...
            'Simulink, for example, in SIL/PIL simulations of the component under \n',...
            'test. Note that this file should be replaced with an appropriate RTE \n',...
            'file when deploying the generated code outside of Simulink. \n\n',...
            'This file is generated for:\nAtomic software component: ',...
            ' "%s"\nARXML schema: "%s"\nFile generated on: "%s" '],...
            rteBuilder.ASWCName,...
            rteBuilder.RTEGenerator.SchemaVer,datestr(clock));
            writer.wComment(comments);
        end
    end

    methods(Access='public')


        function fileName=getWrittenFiles(this)
            fileName={this.File_h_name};
        end
    end

    methods(Static,Access='protected')
        function writeFileGuardStart(writer,headerFileFullPath)
            [~,fileName,fileExt]=fileparts(headerFileFullPath);
            guardName=strrep([fileName,fileExt],'.','_');
            writer.wLine(...
            '#ifndef %s \n#define %s\n',...
            guardName,...
            guardName);
        end

        function writeFileGuardEnd(writer)
            writer.wLine('#endif');
        end
    end

    methods(Abstract)

        write(this);
    end
end



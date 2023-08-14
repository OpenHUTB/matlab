classdef ARAWriter<handle



    properties(SetAccess='public')
        ARABuilder;
    end
    properties(SetAccess='protected')
        AraFileLocation;
    end
    properties(Access='protected')
        WrittenFiles;
        SchemaVersion;
    end
    methods(Access=public)



        function this=ARAWriter(araBuilder,schemaVer)
            autosar.mm.util.validateArg(araBuilder,...
            'autosar.mm.mm2ara.ARABuilder');
            this.SchemaVersion=schemaVer;
            this.ARABuilder=araBuilder;
            this.AraFileLocation=araBuilder.ARAGenerator.ARAFilesLocation;
            this.WrittenFiles={};
        end
        function fileNames=getWrittenFiles(this)
            fileNames=this.WrittenFiles;
        end
    end
    methods(Access='protected')



        function writeFileDescription(this,codeWriter,clusterName)
            schemaString=strrep(erase(this.SchemaVersion,'ARA_VER_'),'_','-');
            comments=sprintf(...
            ['This file contains ARA Function Cluster %s stub implementation.\n',...
            'This implementation can be used to compile the generated code\n',...
            'in Simulink. When deploying the generated code outside of Simulink,\n',...
            'replace this file with an appropriate ARA file. \n\n',...
            'Code generated for Simulink Adaptive model: "%s"',...
            '\nAUTOSAR AP Release: "%s"\nOn: "%s" '],...
            clusterName,this.ARABuilder.getComponentName(),...
            schemaString,datestr(clock));
            codeWriter.wComment(comments);
        end
    end
    methods(Abstract)

        write(this);
    end
end



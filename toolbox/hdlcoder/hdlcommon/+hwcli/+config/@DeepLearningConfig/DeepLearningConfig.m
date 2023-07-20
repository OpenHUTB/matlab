


classdef DeepLearningConfig<hwcli.base.IPCoreBase






    properties

RunTaskEmitDLBitstreamMATFile


    end





    methods
        function obj=DeepLearningConfig(tool)
            obj=obj@hwcli.base.IPCoreBase('Deep Learning Processor',tool);


            obj.RunTaskGenerateSoftwareInterface=false;
            obj.RunTaskEmitDLBitstreamMATFile=true;
            obj.RunExternalBuild=true;
            obj.ProjectFolder='dlhdl_prj';


            obj.Tasks={...
            'RunTaskGenerateRTLCodeAndIPCore',...
            'RunTaskCreateProject',...
            'RunTaskBuildFPGABitstream',...
            'RunTaskEmitDLBitstreamMATFile'};



        end
    end





    methods
        function set.RunTaskEmitDLBitstreamMATFile(obj,val)
            obj.errorCheckTask('RunTaskEmitDLBitstreamMATFile',val);
            obj.RunTaskEmitDLBitstreamMATFile=val;
        end

    end
end



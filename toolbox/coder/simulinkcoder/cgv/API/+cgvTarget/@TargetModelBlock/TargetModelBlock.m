







classdef TargetModelBlock<cgvTarget.TargetBase
    properties
        PILMBHarness;
        PILMBFullPath;
    end

    methods
        function delete(this)

            close_system(this.TestHarnessName,0);
        end

        function obj=TargetModelBlock(aModelName,connectivity)
            if(nargin~=2)
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            obj.TestHarnessName='pilTestHarness';
            obj.PILMBHarness='PILModelBlockHarness';
            obj.ModelName=aModelName;
            obj.PILMBFullPath=[obj.TestHarnessName,'/',obj.PILMBHarness];
            obj.ComponentType='modelblock';
            obj.Connectivity=connectivity;
        end



        function setupTarget(this)

            close_system(this.TestHarnessName,0);
            new_system(this.TestHarnessName,'FromTemplate','factory_default_model');
            load_system(this.TestHarnessName);

            load_system('simulink');
            add_block('simulink/Ports & Subsystems/Model',this.PILMBFullPath);



            modelBlockH=get_param(this.PILMBFullPath,'Handle');


            set_param(modelBlockH,'ModelName',this.ModelName);
            switch lower((this.Connectivity))
            case{'sim','normal'}




                simMode='Accelerator';
            case 'sil'
                simMode='Software-in-the-loop (SIL)';
            case 'pil'
                simMode='Processor-in-the-loop (PIL)';
            otherwise
                assert(false,'Unexpected connectivity "%s" type.',...
                this.Connectivity);
            end
            set_param(modelBlockH,'SimulationMode',simMode);

            modelCS=getActiveConfigSet(this.ModelName);


            testHarnessCS=modelCS.copy;
            testHarnessCS.Name='CSFromModel';
            attachConfigSet(this.TestHarnessName,testHarnessCS,true);
            setActiveConfigSet(this.TestHarnessName,'CSFromModel');

            slprivate('pil_configure_io_ports',modelBlockH,this.ModelName);


        end
    end

end



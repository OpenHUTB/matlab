classdef(ConstructOnLoad=true)iopll<eda.internal.component.BlackBox

    properties

refclk
rst
outclk_0
outclk_1
outclk_2
locked

NoHDLFiles
wrapperFileNotNeeded

PostCodeGenFcn
PostCodeGenFcnArgs
    end

    methods
        function this=iopll(FPGAFamily,FPGADevice,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase)
            this.UniqueName='iopll';

            this.rst=eda.internal.component.Inport('FiType','boolean');
            this.refclk=eda.internal.component.Inport('FiType','boolean');
            this.outclk_0=eda.internal.component.Outport('FiType','boolean');
            this.outclk_1=eda.internal.component.Outport('FiType','boolean');
            this.outclk_2=eda.internal.component.Outport('FiType','boolean');
            this.locked=eda.internal.component.Outport('FiType','boolean');

            this.PostCodeGenFcn='eda.intel.iopll.generateIOPLLQsys';
            this.PostCodeGenFcnArgs={FPGAFamily,FPGADevice,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase};
        end
    end

    methods(Static)
        function genFiles=generateIOPLLQsys(FPGAFamily,FPGADevice,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase)
            currentFolder=pwd;
            cleanupObj=onCleanup(@()cd(currentFolder));


            tempDir='iopll_temp';
            tclScriptName='gen_iopll.tcl';

            if isfolder(tempDir)
                rmdir(tempDir,'s');
            else
                mkdir(tempDir);
                cd(tempDir);
            end


            if any(str2double({outputClk0Freq,outputClk1Freq,outputClk2Freq})==0)
                error('iopll output clk freqency must be nonzero');
            end


            inputClkFreq=num2str(inputClkFreq);
            outputClk0Freq=num2str(outputClk0Freq);
            outputClk1Freq=num2str(outputClk1Freq);
            outputClk2Freq=num2str(outputClk2Freq);
            outputClk2Phase=strrep(outputClk2Phase,'"','');


            fid=fopen(tclScriptName,'w');
            fprintf(fid,[...
'package require qsys\n'...
            ,'create_system {iopll}\n'...
            ,'set_project_property DEVICE_FAMILY {%s}\n'...
            ,'set_project_property DEVICE {%s}\n'...
            ,'add_instance iopll_0 altera_iopll\n'...
            ,'set_instance_parameter_value iopll_0 {gui_reference_clock_frequency} {%s}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_use_locked} {1}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_number_of_clocks} {3}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_output_clock_frequency0} {%s}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_output_clock_frequency1} {%s}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_output_clock_frequency2} {%s}\n'...
            ,'set_instance_parameter_value iopll_0 {gui_phase_shift2} {%s}\n'...
            ,'set_instance_property iopll_0 AUTO_EXPORT true\n'...
            ,'set_interface_property reset EXPORT_OF iopll_0.reset\n'...
            ,'set_interface_property refclk EXPORT_OF iopll_0.refclk\n'...
            ,'set_interface_property locked EXPORT_OF iopll_0.locked\n'...
            ,'set_interface_property outclk0 EXPORT_OF iopll_0.outclk0\n'...
            ,'set_interface_property outclk1 EXPORT_OF iopll_0.outclk1\n'...
            ,'set_interface_property outclk2 EXPORT_OF iopll_0.outclk2\n'...
            ,'save_system iopll'...
            ],FPGAFamily,FPGADevice,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase);
            fclose(fid);


            [isexist,quartusRoot]=eda.internal.workflow.simpleWhich('quartus');
            qsysRoot=fullfile(quartusRoot,'..','sopc_builder','bin','qsys-script');
            if~isexist
                error(message('EDALink:FPGAProjectManager:AlteraQuartusIINotFound'));
            end
            [status,result]=system([qsysRoot,' --script=',tclScriptName]);
            if status
                error(message('EDALink:FPGAProjectManager:QsysScriptFailToGenIOPLL',result))
            end



            if isfile('iopll.ip')
                qsysFileName='iopll.ip';
            else
                qsysFileName='iopll.qsys';
            end
            genFiles={[tempDir,'/',qsysFileName]};
        end
    end
end


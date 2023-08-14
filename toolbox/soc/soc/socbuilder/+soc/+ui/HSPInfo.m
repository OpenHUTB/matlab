classdef HSPInfo<soc.ui.TemplateWithValidation




    properties
Vendor
    end

    methods
        function this=HSPInfo(varargin)
            this@soc.ui.TemplateWithValidation(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.HTMLText.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:HSPInfo_Title').getString();

            this.Vendor=soc.internal.getVendor(this.Workflow.sys);
            switch this.Vendor
            case{'xilinx','Xilinx'}
                this.Description.Text=message('soc:workflow:HSPInfo_Description_Xilinx').getString();
            case{'intel','Intel'}
                this.Description.Text=message('soc:workflow:HSPInfo_Description_Intel').getString();
            case 'Embedded Linux Board'
                this.Description.Text=message('soc:workflow:HSPInfo_Description_EmbeddedLinux').getString();
            case{'TI Delfino F28379D LaunchPad','TI Delfino F2837xD'}
                this.Description.Text=message('soc:workflow:HSPInfo_Description_TIC2000').getString();
            end
            this.Description.shiftVertically(-20);
            this.Description.addWidth(350);
            this.Description.addHeight(50);

            this.ValidationResult.Steps={message('soc:workflow:HSPInfo_Validation_Description').getString()};

            this.ValidationAction.Text='Validate';
            this.ValidationAction.ButtonPushedFcn=@this.startValidationCB;

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection='';
        end
        function screen=getNextScreenID(~)
            screen='soc.ui.ModelInfoNoSPKG';
        end
    end
    methods(Access=private)
        function startValidationCB(this,~,~)

            switch this.Vendor
            case{'xilinx','Xilinx'}
                result=codertarget.internal.isSpPkgInstalled('xilinxsoc');
            case{'intel','Intel'}
                result=codertarget.internal.isSpPkgInstalled('intelsoc');
            case 'Embedded Linux Board'
                result=~isempty(which('soc.embeddedlinux.internal.getRootDir'));
            case{'TI Delfino F28379D LaunchPad','TI Delfino F2837xD'}
                result=~isempty(which('soc.tic2000.internal.getRootFolder'));
            end

            if result
                this.setValidationStatus('pass',message('soc:workflow:HSPInfo_Validation_Pass').getString);
                this.NextButton.Enable='on';



                defFile=codertarget.peripherals.utils.getDefFileNameForBoard(this.Workflow.sys);
                appModel=codertarget.peripherals.AppModel(this.Workflow.sys,defFile);
                this.Workflow.SupportsPeripherals=~isempty(appModel.SupportedPeripheralInfo)&&...
                appModel.arePeripheralBlocksInRefModels();



                if soc.internal.hasProcessor(this.Workflow.sys)
                    this.Workflow.SysDeployer=soc.SystemDeployer(this.Workflow.sys,'ConnectHardware',false);
                    if~soc.ui.SoCGenWorkflow.isModelProcessorOnly(this.Workflow.sys)
                        this.Workflow.HWInterfaceObj=soc.internal.oscustomization.HWInterface.getInstance();
                    end
                end
            else
                this.setValidationStatus('fail',message('soc:workflow:HSPInfo_Validation_Fail').getString);
                this.NextButton.Enable='off';
            end
        end
    end
end

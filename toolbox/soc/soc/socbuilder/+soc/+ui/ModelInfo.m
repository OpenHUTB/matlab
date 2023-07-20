classdef ModelInfo<soc.ui.TemplateBaseWithSteps




    properties
Description
NewOrExisting
ModelInfoTable
RefDesignInfoTable
    end

    methods
        function this=ModelInfo(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.ModelInfoTable=matlab.hwmgr.internal.hwsetup.DeviceInfoTable.getInstance(this.ContentPanel);
            this.NewOrExisting=matlab.hwmgr.internal.hwsetup.RadioGroup.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:ModelInfo_Title').getString();

            this.NewOrExisting.Title=message('soc:workflow:ModelInfo_NewOrExisting_Title').getString();
            if this.Workflow.HasReferenceDesign
                this.NewOrExisting.Items={...
                message('soc:workflow:ModelInfo_ReferenceDesign').getString(),...
                message('soc:workflow:ModelInfo_NewOrExisting_Existing').getString()};
            else

                this.NewOrExisting.Items={...
                message('soc:workflow:ModelInfo_NewOrExisting_New').getString(),...
                message('soc:workflow:ModelInfo_NewOrExisting_Existing').getString()};
            end
            this.NewOrExisting.Position=[20,275,...
            this.ContentPanel.Position(3)-40,100];
            this.NewOrExisting.Tag='soc_ui_ModelInfo_NewOrExisting';
            this.NewOrExisting.SelectionChangedFcn=@this.NewOrExistingCB;

            this.Description.Text=message('soc:workflow:ModelInfo_Description').getString();
            this.Description.Position=[20,this.NewOrExisting.Position(2)-50...
            ,this.NewOrExisting.Position(3),this.NewOrExisting.Position(4)-70];
            this.ModelInfoTable.Position=[20,this.Description.Position(2)-80...
            ,this.Description.Position(3),this.Description.Position(4)+50];
            if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                this.ModelInfoTable.Labels={
                message('soc:workflow:ModelInfo_TopModel').getString(),...
                message('soc:workflow:ModelInfo_FPGAModel').getString(),...
                message('soc:workflow:ModelInfo_ARMModel').getString(),...
                };
                this.ModelInfoTable.Values={
                getModelText(this.Workflow.sys),...
                getModelText(this.getFPGAModelCB),...
                getModelText(this.getProcessorModelCB)};
                if this.Workflow.HasReferenceDesign
                    this.RefDesignInfoTable=matlab.hwmgr.internal.hwsetup.DeviceInfoTable.getInstance(this.ContentPanel);
                    this.RefDesignInfoTable.Position=[20,this.ModelInfoTable.Position(2)-85...
                    ,this.Description.Position(3),this.ModelInfoTable.Position(4)+10];
                    this.RefDesignInfoTable.Labels={
                    message('soc:workflow:ReferenceDesign_Board').getString(),...
                    message('soc:workflow:ReferenceDesign_Name').getString(),...
                    };
                    this.RefDesignInfoTable.Values={
                    this.Workflow.ReferenceDesignInfo.RDBoardName,...
                    this.Workflow.ReferenceDesignInfo.RDName};
                end

            else
                this.ModelInfoTable.Labels={
                message('soc:workflow:ModelInfo_TopModel').getString(),...
                message('soc:workflow:ModelInfo_ARMModel').getString(),...
                };
                this.ModelInfoTable.Values={
                getModelText(this.Workflow.sys),...
                getModelText(this.getProcessorModelCB)};
            end

            if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                if this.Workflow.HasReferenceDesign
                    this.HelpText.WhatToConsider='';
                    dut=soc.util.getDUT(this.Workflow.FPGAModel);
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_New_ReferenceDesign',dut{1},this.Workflow.FPGAModel).getString();
                    this.HelpText.Additional=message('soc:workflow:ModelInfo_Additional_ReferenceDesign').getString();
                else
                    this.HelpText.WhatToConsider='';
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_New').getString();
                    this.HelpText.Additional=message('soc:workflow:ModelInfo_Additional').getString();
                end
            else
                this.HelpText.WhatToConsider='';
                this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_New_Processor_Only').getString();
                this.HelpText.Additional=message('soc:workflow:ModelInfo_Additional_Processor_Only').getString();
            end
        end

        function screen=getNextScreenID(this)
            if this.NewOrExisting.ValueIndex==2
                this.Workflow.LoadExisting=true;
                screen='soc.ui.SelectProjectFolder';
            else
                this.Workflow.LoadExisting=false;
                switch(this.Workflow.ModelType)
                case this.Workflow.ProcessorOnly
                    if this.Workflow.HasEventDrivenTasks||this.Workflow.SupportsPeripherals
                        screen='soc.ui.ReviewPeripheralConfiguration';
                    else
                        screen='soc.ui.SelectProjectFolder';
                    end
                case this.Workflow.SocFpga
                    if this.Workflow.HasEventDrivenTasks||this.Workflow.SupportsPeripherals

                        screen='soc.ui.ReviewPeripheralConfiguration';
                    else
                        screen='soc.ui.ReviewMemoryMap';
                    end
                case this.Workflow.FpgaOnly
                    screen='soc.ui.ReviewMemoryMap';
                otherwise
                    assert(false,'SoC Builder model: wrong model type');
                end
            end
        end
    end

    methods(Access=private)
        function modelName=getFPGAModelCB(this,~,~)
            modelName=this.Workflow.FPGAModel;
            if isempty(modelName)
                modelName=message('soc:workflow:ModelInfo_None').getString();
            end
        end

        function modelName=getProcessorModelCB(this,~,~)
            modelName=this.Workflow.ProcessorModel;
            if isempty(modelName)
                modelName=message('soc:workflow:ModelInfo_None').getString();
            end
        end

        function NewOrExistingCB(this,~,~)
            if(this.NewOrExisting.ValueIndex==1)
                if this.Workflow.HasReferenceDesign
                    dut=soc.util.getDUT(this.Workflow.FPGAModel);
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_New_ReferenceDesign',dut{1},this.Workflow.FPGAModel).getString();
                    this.HelpText.Additional=message('soc:workflow:ModelInfo_Additional_ReferenceDesign').getString();
                else
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_New').getString();
                    this.HelpText.Additional=message('soc:workflow:ModelInfo_Additional').getString();
                end
            else
                if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_Existing').getString();
                else
                    this.HelpText.AboutSelection=message('soc:workflow:ModelInfo_About_Existing_proc').getString();
                end
            end
        end
    end
end

function str=getModelText(modelName)
    if strcmpi(modelName,message('soc:workflow:ModelInfo_None').getString())
        str=message('soc:workflow:ModelInfo_None').getString();
    else
        if~iscell(modelName)
            str=sprintf('<a href="matlab:open_system(''%s'');">%s</a>',modelName,modelName);
        else
            str=sprintf('<a href="matlab:open_system(''%s'');">%s</a>',modelName{1},modelName{1});
            for i=2:numel(modelName)
                str=[str,sprintf('<br><a href="matlab:open_system(''%s'');">%s</a>',modelName{i},modelName{i})];
            end
        end
    end
end

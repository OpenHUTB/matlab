classdef SelectProjectFolder<soc.ui.TemplateBaseWithSteps





    properties
Description
LocationLabel
Location
LocationError
Browse
    end

    methods
        function this=SelectProjectFolder(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.LocationLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.LocationError=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.Location=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.Browse=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:SelectProjectFolder_Title').getString();

            if this.Workflow.LoadExisting
                this.Description.Text=message('soc:workflow:SelectProjectFolder_Existing_Description').getString();
            else
                this.Description.Text=message('soc:workflow:SelectProjectFolder_New_Description').getString();
            end
            this.Description.shiftVertically(250);
            this.Description.addWidth(350);
            this.Description.addHeight(20);

            this.LocationLabel.Text='Project Folder: ';
            this.LocationLabel.Position(2)=this.Description.Position(2)-30;
            this.LocationLabel.addWidth(20);

            if this.Workflow.LoadExisting
                this.Location.Text='';
                this.NextButton.Enable='off';
            else
                this.Location.Text='soc_prj';
                this.NextButton.Enable='on';
            end
            this.Location.Position(2)=this.LocationLabel.Position(2)+2;
            this.Location.Position(1)=110;
            this.Location.TextAlignment='left';
            if this.Workflow.LoadExisting
                this.Location.ValueChangedFcn=@this.validateExistingLocationCB;
            else
                this.Location.ValueChangedFcn=@this.validateNewLocationCB;
            end

            this.Location.addWidth(150);

            this.Browse.Text='Browse ...';
            this.Browse.Position(2)=this.LocationLabel.Position(2)+2;
            this.Browse.Position(1)=365;
            this.Browse.addHeight(2);
            this.Browse.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.Browse.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
            this.Browse.ButtonPushedFcn=@this.browseCustomDirectoryCB;

            this.LocationError.Text='';
            this.LocationError.Position=[20,220,370,70];
            this.LocationError.FontColor=[1,0,0];
            this.LocationError.FontWeight='bold';


            if this.Workflow.LoadExisting
                this.HelpText.WhatToConsider='';
            else
                if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                    this.HelpText.WhatToConsider=message('soc:workflow:SelectProjectFolder_New_WhatToConsider').getString();
                else
                    this.HelpText.WhatToConsider=message('soc:workflow:SelectProjectFolder_Proc_New_WhatToConsider').getString();
                end
            end
            this.HelpText.AboutSelection='';



            if~this.Workflow.LoadExisting
                this.validateNewLocationCB(this.Location);
            end
        end

        function screen=getNextScreenID(this)

            this.Workflow.ProjectDir=soc.internal.makeAbsolutePath(this.Location.Text);
            if this.Workflow.LoadExisting
                if strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                    if soc.internal.hasProcessor(this.Workflow.sys)||...
                        (this.Workflow.HasReferenceDesign&&this.Workflow.ReferenceDesignInfo.HasProcessingSystem)
                        screen='soc.ui.ConnectHardware';
                    else
                        screen='soc.ui.LoadAndRun';
                    end
                else
                    if this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                        screen='soc.ui.LoadAndRun';
                    else
                        screen='soc.ui.ConnectHardware';
                    end
                end
            else
                screen='soc.ui.SelectBuildAction';
            end
        end

        function screen=getPreviousScreenID(this)
            if this.Workflow.LoadExisting
                screen='soc.ui.ModelInfo';
            else
                switch(this.Workflow.ModelType)
                case this.Workflow.ProcessorOnly
                    if this.Workflow.SupportsPeripherals||...
                        this.Workflow.HasEventDrivenTasks
                        screen='soc.ui.ReviewPeripheralConfiguration';
                    else
                        screen='soc.ui.ModelInfo';
                    end
                case{this.Workflow.SocFpga,this.Workflow.FpgaOnly}
                    screen='soc.ui.ReviewMemoryMap';
                otherwise
                    assert(false,'SoC Builder model: wrong model type');
                end
            end
        end
        function reinit(this)


            if this.Workflow.LoadExisting
                this.Description.Text=message('soc:workflow:SelectProjectFolder_Existing_Description').getString();
                this.NextButton.Enable='off';
                this.Location.ValueChangedFcn=@this.validateExistingLocationCB;
                this.HelpText.WhatToConsider='';
                this.validateExistingLocationCB(this.Location);
            else
                this.Description.Text=message('soc:workflow:SelectProjectFolder_New_Description').getString();
                this.NextButton.Enable='on';
                this.Location.ValueChangedFcn=@this.validateNewLocationCB;
                this.HelpText.WhatToConsider=message('soc:workflow:SelectProjectFolder_New_WhatToConsider').getString();
                this.validateNewLocationCB(this.Location);
            end
        end
    end

    methods(Access=private)
        function browseCustomDirectoryCB(this,~,~)
            dir=uigetdir(this.Location.Text,message('soc:workflow:SelectProjectFolder_New_Description').getString());
            if dir
                this.Location.Text=dir;
            end
            this.Workflow.Window.bringToFront();
        end

        function validateNewLocationCB(this,src,~)

            this.LocationError.Text='';
            this.NextButton.Enable='on';

            lastwarn('');
            warning('off','soc:msgs:LongPath');
            warning('off','soc:workflow:FolderNotEmpty');


            try
                soc.internal.validateProjectDir(src.Text)
                if isfolder(src.Text)&&length(dir(src.Text))>2
                    warning(message('soc:workflow:FolderNotEmpty'))
                end
            catch ME
                this.LocationError.FontColor=[1,0,0];
                this.LocationError.Text=ME.message;
                this.NextButton.Enable='off';
            end


            if~isempty(lastwarn)
                this.LocationError.Text=lastwarn;
                this.LocationError.FontColor=[255,127,80]/255;
            end

            warning('on','soc:msgs:LongPath');
            warning('on','soc:workflow:FolderNotEmpty');
        end
        function validateExistingLocationCB(this,src,~)

            this.LocationError.Text='';
            this.NextButton.Enable='on';


            try
                soc.internal.validateProjectDir(src.Text)

                socsysinfofile=fullfile(src.Text,'socsysinfo.mat');
                if~isfile(socsysinfofile)
                    error(message('soc:workflow:SelectProjectFolder_NoInfoFile'));
                end

                load(socsysinfofile,'socsysinfo');
                if~strcmp(socsysinfo.modelinfo.sys,this.Workflow.sys)
                    error(message('soc:workflow:SelectProjectFolder_TopModelNotMatch',socsysinfo.modelinfo.sys,this.Workflow.sys));
                end
            catch ME
                this.LocationError.FontColor=[1,0,0];
                this.LocationError.Text=ME.message;
                this.NextButton.Enable='off';
            end

        end
    end
end



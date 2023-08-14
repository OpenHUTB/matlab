classdef TemplateBaseWithSteps<matlab.hwmgr.internal.hwsetup.TemplateBase
    properties
CurrentStep
Steps
    end

    methods
        function this=TemplateBaseWithSteps(varargin)
            this@matlab.hwmgr.internal.hwsetup.TemplateBase(varargin{:});

            this.Title.Position=[10,1,470,25];
            this.Steps=matlab.hwmgr.internal.hwsetup.HTMLText.getInstance(this.Banner);
            this.Steps.Position=[10,22,500,20];
            this.setCurrentStep(1);
            if isprop(this.Steps,'BackgroundColor')
                this.Steps.BackgroundColor=[0,0.3294,0.5804];
            end
        end

        function setCurrentStep(this,currentStep)
            steps=this.getStepsToDisplay();
            steps{currentStep}=['<font color="white"><b>',steps{currentStep},'</b></font>'];
            this.Steps.Text=sprintf('<body bgcolor = "#005494"><font color="#C0C0C0">%s</font></body>',strjoin(steps,'&nbsp;&nbsp;>&nbsp;&nbsp;'));
            this.CurrentStep=currentStep;
        end
    end

    methods(Access=private)
        function steps=getStepsToDisplay(~)
            steps={
            'Prepare',...
            'Validate',...
            'Build',...
'Run'
            };
        end
    end
end
classdef ConfigurationTearOff<handle




    properties(Dependent)
AutomateForward
StartAtCurrentTime
ImportROIs
    end

    properties(Access=private)
TearOff
Panel

ForwardDirRadioButton
ReverseDirRadioButton
StartTimeRadioButton
CurrentTimeRadioButton
ImportROIsCheckbox

Tool
Invoker

Listeners
    end

    events
DirectionChanged
StartTimeChanged
ImportROIsChanged
    end

    methods

        function this=ConfigurationTearOff(tool,invoker)

            this.Invoker=invoker;
            this.Tool=tool;
            if useAppContainer()
                layoutContentInWebMode(this);
                wireCallbacksInWebMode(this);
            else
                layoutContent(this);
                wireCallbacks(this);
            end

        end


        function show(this)
            if isempty(this.TearOff)


                createTearOff(this);
            end
            if~this.TearOff.Visible
                showTearOffDialog(this.Tool,this.TearOff,this.Invoker);

                autosizeTearOff(this);
            end
        end


        function popUpList=showConfigureAutomation(this)
            popUpList=this.Panel;
        end


        function hide(this)
            close(this.TearOff);
        end


        function TF=get.AutomateForward(this)
            if useAppContainer()
                TF=this.ForwardDirRadioButton.Value;
            else
                TF=this.ForwardDirRadioButton.Selected;
            end
        end


        function TF=get.StartAtCurrentTime(this)
            if useAppContainer()
                TF=this.CurrentTimeRadioButton.Value;
            else
                TF=this.CurrentTimeRadioButton.Selected;
            end
        end


        function TF=get.ImportROIs(this)
            if useAppContainer()
                TF=this.ImportROIsCheckbox.Value;
            else
                TF=this.ImportROIsCheckbox.Selected;
            end
        end


        function set.ImportROIs(this,tf)
            if useAppContainer()
                this.ImportROIsCheckbox.Value=tf;
            else
                this.ImportROIsCheckbox.Selected=tf;
            end
        end
    end

    methods(Access=private)

        function layoutContent(this)

            this.Panel=toolpack.component.TSPanel('5dlu,f:p:g,5dlu','5dlu,f:p:g,5dlu,f:p:g,5dlu');

            StartTimePanel=toolpack.component.TSPanel('f:p:g,100dlu',['5dlu,f:p:g,2dlu,f:p:g,1dlu,f:p:g,5dlu,','5dlu,f:p:g,2dlu,f:p:g,1dlu,f:p:g,5dlu']);
            ImportROIPanel=toolpack.component.TSPanel('f:p:g,100dlu','5dlu,f:p:g,2dlu,f:p:g,5dlu');
            addTitledBorderToPanel(StartTimePanel);
            addTitledBorderToPanel(ImportROIPanel);

            this.Panel.add(StartTimePanel,'xy(2,2)');
            this.Panel.add(ImportROIPanel,'xy(2,4)');

            label0=toolpack.component.TSLabel(vision.getMessage('vision:labeler:AutomationDirectionLabel'));

            forwardRadioButton=toolpack.component.TSRadioButton(vision.getMessage('vision:labeler:AutomationForward'));
            forwardRadioButton.Name='radioForwardAutomation';
            forwardRadioButton.Selected=true;

            reverseRadioButton=toolpack.component.TSRadioButton(vision.getMessage('vision:labeler:AutomationReverse'),true);
            reverseRadioButton.Name='radioReverseAlgorithm';

            label=toolpack.component.TSLabel(vision.getMessage('vision:labeler:AutomationStartsAtLabel'));

            startRadioButton=toolpack.component.TSRadioButton(vision.getMessage('vision:labeler:Start2EndTime'));
            startRadioButton.Name='radioStartConfigurationAlgorithm';

            currentRadioButton=toolpack.component.TSRadioButton(vision.getMessage('vision:labeler:Current2EndTime'),true);
            currentRadioButton.Name='radioCurrentConfigurationAlgorithm';

            dirGroup=toolpack.component.ButtonGroup;
            dirGroup.add(forwardRadioButton);
            dirGroup.add(reverseRadioButton);
            fromTimeGroup=toolpack.component.ButtonGroup;
            fromTimeGroup.add(startRadioButton);
            fromTimeGroup.add(currentRadioButton);

            importCheckBox=toolpack.component.TSCheckBox(vision.getMessage('vision:labeler:ImportSelectedROIs'),true);
            importCheckBox.Name='chkImportConfigurationAlgorithm';

            this.ForwardDirRadioButton=forwardRadioButton;
            this.ReverseDirRadioButton=reverseRadioButton;
            this.StartTimeRadioButton=startRadioButton;
            this.CurrentTimeRadioButton=currentRadioButton;
            this.ImportROIsCheckbox=importCheckBox;

            setToolTipText(label0,'AutomationDirectionTooltip');
            setToolTipText(this.ForwardDirRadioButton,'AutomationForwardTooltip');
            setToolTipText(this.ReverseDirRadioButton,'AutomationReverseTooltip');

            setToolTipText(label,'AutomationStartsAtTooltip');
            setToolTipText(this.StartTimeRadioButton,'Start2EndTimeTooltip');
            setToolTipText(this.CurrentTimeRadioButton,'Current2EndTimeTooltip');
            setToolTipText(this.ImportROIsCheckbox,'ImportROIsTooltip');

            StartTimePanel.add(label0,'xyw(1,2,2)');
            StartTimePanel.add(forwardRadioButton,'xyw(1,4,2)');
            StartTimePanel.add(reverseRadioButton,'xyw(1,6,2)');

            StartTimePanel.add(label,'xyw(1,9,2)');
            StartTimePanel.add(startRadioButton,'xyw(1,11,2)');
            StartTimePanel.add(currentRadioButton,'xyw(1,13,2)');
            ImportROIPanel.add(importCheckBox,'xyw(1,2,2)');
        end


        function layoutContentInWebMode(this)
            import matlab.ui.internal.toolstrip.*;
            this.Panel=matlab.ui.internal.toolstrip.PopupList();

            dirGroup=matlab.ui.internal.toolstrip.ButtonGroup;
            label0=PopupListHeader(vision.getMessage('vision:labeler:AutomationDirectionLabel'));

            forwardRadioButton=ListItemWithRadioButton(dirGroup,vision.getMessage('vision:labeler:AutomationForward'));
            forwardRadioButton.Value=true;

            label1=PopupListHeader(vision.getMessage('vision:labeler:AutomationStartsAtLabel'));

            reverseRadioButton=ListItemWithRadioButton(dirGroup,vision.getMessage('vision:labeler:AutomationReverse'));

            fromTimeGroup=matlab.ui.internal.toolstrip.ButtonGroup;
            startRadioButton=ListItemWithRadioButton(fromTimeGroup,vision.getMessage('vision:labeler:Start2EndTime'));
            currentRadioButton=ListItemWithRadioButton(fromTimeGroup,vision.getMessage('vision:labeler:Current2EndTime'));
            currentRadioButton.Value=true;

            importCheckBox=ListItemWithCheckBox(vision.getMessage('vision:labeler:ImportSelectedROIs'));
            importCheckBox.Value=true;

            this.ForwardDirRadioButton=forwardRadioButton;
            this.ForwardDirRadioButton.Tag='radioForwardAutomation';

            this.ReverseDirRadioButton=reverseRadioButton;
            this.ReverseDirRadioButton.Tag='radioReverseAutomation';

            this.StartTimeRadioButton=startRadioButton;
            this.StartTimeRadioButton.Tag='radioStartConfigurationAlgorithm';

            this.CurrentTimeRadioButton=currentRadioButton;
            this.CurrentTimeRadioButton.Tag='radioCurrentConfigurationAlgorithm';

            label2=PopupListHeader(vision.getMessage('vision:labeler:ImportROIsInAutomation'));
            this.ImportROIsCheckbox=importCheckBox;
            this.ImportROIsCheckbox.Tag='chkImportConfigurationAlgorithm';


            setToolTipText(this.ForwardDirRadioButton,'AutomationForwardTooltip');
            setToolTipText(this.ReverseDirRadioButton,'AutomationReverseTooltip');
            setToolTipText(this.StartTimeRadioButton,'Start2EndTimeTooltipInWebMode');
            setToolTipText(this.CurrentTimeRadioButton,'Current2EndTimeTooltipInWebMode');
            setToolTipText(this.ImportROIsCheckbox,'ImportROIsTooltipInWebMode');


            this.Panel.add(label0);
            this.Panel.add(this.ForwardDirRadioButton);
            this.Panel.add(this.ReverseDirRadioButton);
            this.Panel.add(label1);
            this.Panel.add(this.StartTimeRadioButton);
            this.Panel.add(this.CurrentTimeRadioButton);
            this.Panel.add(label2);
            this.Panel.add(this.ImportROIsCheckbox);
        end


        function createTearOff(this)

            this.TearOff=toolpack.component.TSTearOffPopup(this.Panel);
            this.TearOff.Title=vision.getMessage('vision:labeler:AutomationConfigurationTitle');
            this.TearOff.Name='tearoffConfigureAlgorithm';
            autosizeTearOff(this);
        end


        function autosizeTearOff(this)
            if~isempty(this.TearOff)&&this.TearOff.Visible
                javaMethodEDT('pack',this.TearOff.Peer.getWrappedComponent());
            end
        end


        function directionChangedCallback(this,~,~)
            if this.ForwardDirRadioButton.Selected
                this.StartTimeRadioButton.Text=vision.getMessage('vision:labeler:Start2EndTime');
                this.CurrentTimeRadioButton.Text=vision.getMessage('vision:labeler:Current2EndTime');
                setToolTipText(this.StartTimeRadioButton,'Start2EndTimeTooltip');
                setToolTipText(this.CurrentTimeRadioButton,'Current2EndTimeTooltip');
            else
                this.StartTimeRadioButton.Text=vision.getMessage('vision:labeler:End2StartTime');
                this.CurrentTimeRadioButton.Text=vision.getMessage('vision:labeler:Current2StartTime');
                setToolTipText(this.StartTimeRadioButton,'End2StartTimeTooltip');
                setToolTipText(this.CurrentTimeRadioButton,'Current2StartTimeTooltip');
            end
        end


        function directionChangedCallbackForWebFigures(this,~,~)
            if this.ForwardDirRadioButton.Value
                this.StartTimeRadioButton.Text=vision.getMessage('vision:labeler:Start2EndTime');
                this.CurrentTimeRadioButton.Text=vision.getMessage('vision:labeler:Current2EndTime');
                setToolTipText(this.StartTimeRadioButton,'Start2EndTimeTooltipInWebMode');
                setToolTipText(this.CurrentTimeRadioButton,'Current2EndTimeTooltipInWebMode');
            else
                this.StartTimeRadioButton.Text=vision.getMessage('vision:labeler:End2StartTime');
                this.CurrentTimeRadioButton.Text=vision.getMessage('vision:labeler:Current2StartTime');
                setToolTipText(this.StartTimeRadioButton,'End2StartTimeTooltipInWebMode');
                setToolTipText(this.CurrentTimeRadioButton,'Current2StartTimeTooltipInWebMode');
            end
        end


        function wireCallbacks(this)
            this.Listeners{1}=addlistener(this.ForwardDirRadioButton,'ItemStateChanged',@this.directionChangedCallback);
            this.Listeners{1}=addlistener(this.ReverseDirRadioButton,'ItemStateChanged',@this.directionChangedCallback);

            this.Listeners{1}=addlistener(this.StartTimeRadioButton,'ItemStateChanged',@(es,ed)notify(this,'StartTimeChanged'));
            this.Listeners{2}=addlistener(this.CurrentTimeRadioButton,'ItemStateChanged',@(es,ed)notify(this,'StartTimeChanged'));

            this.Listeners{3}=addlistener(this.ImportROIsCheckbox,'ItemStateChanged',@(es,ed)notify(this,'ImportROIsChanged'));
        end


        function wireCallbacksInWebMode(this)
            this.Listeners{1}=addlistener(this.ForwardDirRadioButton,'ValueChanged',@this.directionChangedCallbackForWebFigures);
            this.Listeners{1}=addlistener(this.ReverseDirRadioButton,'ValueChanged',@this.directionChangedCallbackForWebFigures);

            this.Listeners{1}=addlistener(this.StartTimeRadioButton,'ValueChanged',@(es,ed)notify(this,'StartTimeChanged'));
            this.Listeners{2}=addlistener(this.CurrentTimeRadioButton,'ValueChanged',@(es,ed)notify(this,'StartTimeChanged'));
            this.Listeners{3}=addlistener(this.ImportROIsCheckbox,'ValueChanged',@(es,ed)notify(this,'ImportROIsChanged'));
        end
    end
end

function setToolTipText(component,tooltipMsg)
    tooltipStr=vision.getMessage(sprintf('vision:labeler:%s',tooltipMsg));
    if useAppContainer()
        component.Description=tooltipStr;
        component.ShowDescription=true;
    else
        component.Peer.setToolTipText(tooltipStr);
    end
end

function addTitledBorderToPanel(panel)
    title='';
    etchedBorder=javaMethodEDT('createEtchedBorder','javax.swing.BorderFactory');
    titledBorder=javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',etchedBorder,title);
    javaObjectEDT(titledBorder);
    panel.Peer.setBorder(titledBorder);
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
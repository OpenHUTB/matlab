







classdef AlgorithmSection<vision.internal.labeler.tool.sections.AlgorithmSection

    properties
SelectSignalsButton
SelectSignals
    end

    properties(Constant)
        SignalSelectionIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=AlgorithmSection(tool)
            this=this@vision.internal.labeler.tool.sections.AlgorithmSection(tool);
        end
    end

    methods(Access=protected)
        function layoutSection(this,toolGroup)

            if isVideoLabeler(this)
                this.addSelectAlgorithmLabel();
            end
            this.addSelectAlgorithmDropDown();

            this.addConfigureButton();
            this.addConfigureTearOff(toolGroup);


            if~isVideoLabeler(this)
                this.addSignalSelectionButton();
                this.addSignalSelection();
            end

            this.addRunAlgorithmButton();

            algChoiceCol=this.addColumn();
            if isVideoLabeler(this)
                algChoiceCol.add(this.SelectAlgorithmLabel);
            end
            algChoiceCol.add(this.SelectAlgorithmDropDown);

            if~isVideoLabeler(this)
                algChoiceCol.add(this.SelectSignalsButton);
            end

            algChoiceCol.add(this.ConfigureButton);

            algRunCol=this.addColumn();
            algRunCol.add(this.AutomateButton);
        end

        function addSignalSelectionButton(this)
            icon=fullfile(this.SignalSelectionIconPath,'signalSelection_16.png');
            titleID='vision:labeler:SelectSignals';
            tag='btnSelectSignals';
            this.SelectSignalsButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectSignalsButtonToolTip';
            this.setToolTipText(this.SelectSignalsButton,toolTipID);
        end

        function addSignalSelection(this)
            this.SelectSignals=...
            vision.internal.labeler.tool.SelectSignalsDlg(this.SelectSignalsButton);
        end
    end
end
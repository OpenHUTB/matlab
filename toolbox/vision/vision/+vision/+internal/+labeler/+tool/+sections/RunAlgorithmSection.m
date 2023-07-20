







classdef RunAlgorithmSection<vision.internal.uitools.NewToolStripSection

    properties
RunButton
StopButton
UndoRunButton
    end

    methods
        function this=RunAlgorithmSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            runAlgSectionTitle=vision.getMessage('vision:labeler:Run');
            runAlgSectionTag='sectionRunAlg';

            this.Section=matlab.ui.internal.toolstrip.Section(runAlgSectionTitle);
            this.Section.Tag=runAlgSectionTag;
        end

        function layoutSection(this)

            this.addRunButton();
            this.addStopButton();
            this.addUndoRunButton();

            runCol=this.addColumn();
            runCol.add(this.RunButton);

            stopCol=this.addColumn();
            stopCol.add(this.StopButton);

            undoRunCol=this.addColumn();
            undoRunCol.add(this.UndoRunButton);
        end

        function addRunButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
            titleID='vision:labeler:Run';
            tag='btnRun';
            this.RunButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectRunAlgorithmTooltip';
            this.setToolTipText(this.RunButton,toolTipID);
        end

        function addStopButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.END_24;
            titleID='vision:labeler:Stop';
            tag='btnStop';
            this.StopButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectStopAlgorithmTooltip';
            this.setToolTipText(this.StopButton,toolTipID);
        end

        function addUndoRunButton(this)

            icon=matlab.ui.internal.toolstrip.Icon.UNDO_24;
            titleID='vision:labeler:UndoRun';
            tag='btnUndoRun';
            this.UndoRunButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:SelectUndoRunAlgorithmTooltip';
            this.setToolTipText(this.UndoRunButton,toolTipID);
        end
    end
end
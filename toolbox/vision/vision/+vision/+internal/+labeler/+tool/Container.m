classdef(Abstract)...
    Container<handle




    events

AppClientActivated

AppClosed

AppResized

AppLayoutUpdated

AppFocusRestored

AppFocusLost

UndoRequested

RedoRequested

HelpRequested

SaveRequested

CutRequested

CopyRequested

PasteRequested

    end

    properties(Constant)
        LABEL_DEF_COL_W=0.2;
        ATTRIB_INSTRCT_COL_W=0.2;
        NAV_CONTROL_ROW_H=0.15;
        OVERVIEW_ROW_H=0.4;
    end

    properties
        NameROILabelSetDisplay='ROI Display';
        NameFrameLabelSetDisplay='Frame Display';
        NameInstructionsSetDisplay='Instruction Display';
        NameAttributesSublabelsDisplay='Attribute Sublabel Display';
        NameSignalNavigationDisplay='Signal Navigation Display';
        NameVisualSummaryDisplay='Visual Summary Display';
        NameOverviewDisplay='Overview Display';
        NameMetadataDisplay='Metadata Display';
    end

    properties(GetAccess={?vision.internal.labeler.tool.ToolgroupContainer,...
        ?vision.internal.labeler.tool.WebContainer,...
        ?vision.internal.videoLabeler.tool.VideoLabelingTool,...
        ?vision.internal.labeler.tool.LabelerTool,...
        ?visiontest.apps.labeler.AppTester,...
        ?lidartest.apps.labeler.AppTester},SetAccess=protected,Transient)

        NoneSignalFigure matlab.ui.Figure

        ROILabelFigure matlab.ui.Figure

        SignalNavFigure matlab.ui.Figure

        FrameLabelFigure matlab.ui.Figure

        InstructionFigure matlab.ui.Figure

        AttribSublabelFigure matlab.ui.Figure

        OverviewFigure matlab.ui.Figure

        MetadataFigure matlab.ui.Figure

        SignalsMap containers.Map

App

    end

    properties(GetAccess={?visiontest.apps.labeler.AppTester,...
        ?vision.internal.labeler.tool.ToolgroupContainer,...
        ?vision.internal.labeler.tool.WebContainer},SetAccess=protected,Transient)

UndoButton
RedoButton
HelpButton
SaveButton
CutButton
CopyButton
PasteButton

    end

    properties(Access=protected)

        ShowAttributeTab=false;
        ShowInstructionTab=false;
        ShowNavControlTab=false;
        ShowOverviewTab=false;
        ShowMetadataTab=false;

ColumnWidths
RowHeights

NumberOfRowTiles
NumberOfColumnTiles

NumSignalFigures
    end

    properties(SetAccess=protected,GetAccess=public)


        CurrentDisplayGridNumRows=1;
        CurrentDisplayGridNumCols=1;
    end

    properties(Access=protected,Hidden,Transient)

ProgressBar

        LayoutFileName char

CachedLayout

UndoListener
RedoListener
SaveListener
CutListener
CopyListener
PasteListener
HelpListener

    end


    methods(Abstract)

        addTabs(this);

        clear(this);
        close(this);

        loc=getLocation(this);

        wait(this);
        resume(this);

        enableQuickAccessBar(this);
        disableQuickAccessBar(this);
        clearQuickAccessBar(this);

        enableUndo(this,TF);
        enableRedo(this,TF);
        enableCut(this,TF);
        enableCopy(this,TF);
        enablePaste(this,TF);

        approveClose(this);
        vetoClose(this);

    end


    methods(Abstract,Access=protected)

        createApp(this);
        openApp(this);

    end

    methods

        function hFig=getDefaultFig(this)

            hFig=this.ROILabelFigure;
        end

        function tf=get.ShowAttributeTab(this)
            tf=strcmp(this.AttribSublabelFigure.Visible,'on');
        end

        function tf=get.ShowInstructionTab(this)
            tf=strcmp(this.InstructionFigure.Visible,'on');
        end

        function tf=get.ShowNavControlTab(this)
            tf=strcmp(this.SignalNavFigure.Visible,'on');
        end

        function tf=get.ShowOverviewTab(this)
            tf=false;
            if isvalid(this.OverviewFigure)
                tf=strcmp(this.OverviewFigure.Visible,'on');
            end
        end

        function tf=get.ShowMetadataTab(this)
            tf=false;
            if isvalid(this.MetadataFigure)
                tf=strcmp(this.MetadataFigure.Visible,'on');
            end
        end


        function colW=get.ColumnWidths(this)
            colW=getColumnWidths(this);
        end


        function colH=get.RowHeights(this)
            colH=getRowHeights(this);
        end


        function numRows=get.NumberOfRowTiles(this)

            numRows=getNumberOfRowTiles(this);
        end


        function numCols=get.NumberOfColumnTiles(this)

            numCols=getNumberOfColumnTiles(this);
        end


        function n=get.NumSignalFigures(this)

            n=length(this.SignalsMap);
        end

        function updateSignalNameInMap(this,oldName,newName)

            if strcmp(oldName,newName)
                return;
            end



            vals=this.SignalsMap(oldName);





            remove(this.SignalsMap,oldName);
            this.SignalsMap(newName)=vals;
        end

        function resetDisplayGridDims(this)
            this.CurrentDisplayGridNumRows=1;
            this.CurrentDisplayGridNumCols=1;
        end
    end
    methods




        function this=Container(title,name)
            createApp(this,title,name);

        end




        function open(this)

            openApp(this);




            drawnow;

        end

        function resetSignalMap(this)
            this.SignalsMap=containers.Map;
        end
    end

    methods(Access=protected)


        function updateAppLayout(this)

            notify(this,'AppLayoutUpdated',images.internal.app.segmenter.volume.events.AppLayoutUpdatedEventData(...
            this.VolumeVisible,this.LabelVisible));

        end


        function reactToAppClientActivation(this,evtData)

            notify(this,'AppClientActivated',evtData);

        end


        function reactToAppClosing(this)

            notify(this,'AppClosed');

        end


        function reactToAppInFocus(this)

            notify(this,'AppFocusRestored');

        end


        function reactToAppFocusLost(this)

            notify(this,'AppFocusLost');

        end


        function reactToAppResize(this)

            this.CachedLayout=getLayout(this);

        end

    end

end



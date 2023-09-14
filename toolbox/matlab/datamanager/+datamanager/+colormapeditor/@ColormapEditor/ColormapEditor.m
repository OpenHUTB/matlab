classdef ColormapEditor<handle


    properties(Access={?datamanager.colormapeditor.ColormapEditorController,...
        ?tcolormapeditor,...
        ?tColormapEditorController,...
        ?tColormapEditor})
        ColormapUIFigure matlab.ui.Figure
ProgressDialog
        EditorMenu matlab.ui.container.Menu
        ImportMenu matlab.ui.container.Menu
        SaveasMenu matlab.ui.container.Menu
        EditMenu matlab.ui.container.Menu
        UndoMenu matlab.ui.container.Menu
        RedoMenu matlab.ui.container.Menu
        ResetCurrent matlab.ui.container.Menu
        ResetAll matlab.ui.container.Menu
        HelpMenu matlab.ui.container.Menu
        OpenDocumentationMenu matlab.ui.container.Menu

        SelectColormapPanel matlab.ui.container.internal.AccordionPanel
        CustomizeColormapPanel matlab.ui.container.internal.AccordionPanel
        EditSizeAndCSpacePanel matlab.ui.container.internal.AccordionPanel
        SetCLimitsPanel matlab.ui.container.internal.AccordionPanel

        ImportButton matlab.ui.control.Button
        ColormapDropDownLabel matlab.ui.control.Label
        ColormapDropDown matlab.ui.control.DropDown
        CustomizeCMapPanel matlab.ui.container.Panel
        TabGroup matlab.ui.container.TabGroup
        ShiftTab matlab.ui.container.Tab
        SpecifyColorTab matlab.ui.container.Tab
        CurrentColorEditFieldLabel matlab.ui.control.Label
        CurrentColorEditField matlab.ui.control.EditField
        CurrentIndexEditFieldLabel matlab.ui.control.Label
        CurrentIndexEditField matlab.ui.control.NumericEditField
        CurrentCDataEditFieldLabel matlab.ui.control.Label
        CurrentCDataEditField matlab.ui.control.NumericEditField
        ColorButton matlab.ui.control.internal.ColorPicker
        EditSizePanel matlab.ui.container.Panel
        ColorspaceDropDownLabel matlab.ui.control.Label
        SizeSpinnerLabel matlab.ui.control.Label
        SizeSpinner matlab.ui.control.Spinner
        ReverseCheckBox matlab.ui.control.CheckBox
        ReverseLabel matlab.ui.control.Label
        ClimMinEditFieldLabel matlab.ui.control.Label
        ClimMinEditField matlab.ui.control.NumericEditField
        ClimMaxEditFieldLabel matlab.ui.control.Label
        ClimMaxEditField matlab.ui.control.NumericEditField
        ShiftAxes matlab.graphics.axis.Axes
        SpecifyColorAxes matlab.graphics.axis.Axes

InteractiveColorbar
SpecifyColorColorbar
ParentFigure
        FigureDataManager datamanager.FigureDataManager
CurrentObject
ColorbarClickInteraction
ColorbarDragInteraction
        ColormapEditorModel datamanager.colormapeditor.ColormapEditorModel
    end

    properties(Access={?datamanager.colormapeditor.ColormapEditorController,...
        ?tcolormapeditor,...
        ?tColormapEditor})
ColorMarkerList
ImportDialog
ExportDialog
MouseMoveListener
        CurrentMarkerIndex=-1
        SelectedMarkersIndices=[]
        ColorspaceDropDown matlab.ui.control.DropDown
        IsCtrlKeyPressed=false
        IsCustomColormap=false
        CachedRGBOriginalColormap=[]
        CachedHSVOriginalColormap=[]
CurrentTitle
ErrorMsgDlg
        LastMouseHoverIndex=-1
    end

    properties(Access={?datamanager.colormapeditor.ColormapEditorController,...
        ?tcolormapeditor,...
        ?tColormapEditor},Constant)
        CUSTOMIZE_PANEL_HEIGHT=239
        DIALOG_WIDTH=536
        DIALOG_HEIGHT=453
        CUSTOM_COLORMAP=getString(message('MATLAB:datamanager:colormapeditor:CustomColormap'))
        COLORBAR_POSITION=[15,50,470,42]
        ROW_HEIGHT=23
        ICON_SIZE=16
        PADDING=[5,5,10,0]
        NOPADDING=[0,0,0,0]
        INNERPADDING=[0,0,10,0]
        FIXED_SPACING=5
        AXES_POSITION=[9,28,486,180]
    end

    events
EditorClosed
    end

    methods(Access={?datamanager.colormapeditor.ColormapEditorController,...
        ?tColormapEditor,...
        ?tcolormapeditor})


        function this=ColormapEditor(parentFigure)

            this.ParentFigure=parentFigure;



            this.ColormapEditorModel=datamanager.colormapeditor.ColormapEditorModel();


            this.FigureDataManager=datamanager.FigureDataManager.getInstance();



            this.createComponents();
        end



        function close(this)

            delete(this.MouseMoveListener);
            delete(this.ImportDialog);
            delete(this.ErrorMsgDlg);
            delete(this.ExportDialog);
            delete(this.ColormapUIFigure);
        end

        function hideDialog(this)
            delete(this.ImportDialog);
            delete(this.ErrorMsgDlg);
            delete(this.ExportDialog);
            set(this.ColormapUIFigure,'Visible','off');



            notify(this,'EditorClosed');
        end





        function setCurrentObject(this,hObj)
            this.CurrentObject=hObj;
            this.initColormapEditorUIAndModel();
        end

        function hObj=getFigure(this)
            hObj=this.ParentFigure;
        end




        function bringToFront(this)
            this.setVisible();
            figure(this.ColormapUIFigure);
        end



        function setBestColormapModel(this,cmap)
            this.updateColormapProperties(this.findStandardColormap(cmap),...
            cmap,...
            this.ColorspaceDropDown.Value,...
            this.isCMapInverse());


            nrgbnodes=testRGBNumberOfMarkers(cmap);
            nhsvnodes=testHSVNumberOfMarkers(cmap);
            this.CachedRGBOriginalColormap=[];
            this.CachedHSVOriginalColormap=[];
            if(nrgbnodes<=nhsvnodes)
                this.setColormapModelRGB(cmap);
                this.ColorspaceDropDown.Value='RGB';
                this.ColormapEditorModel.updateColorspace('RGB');
                this.CachedRGBOriginalColormap=this.ShiftAxes.Colormap;
            else
                this.setColormapModelHSV(cmap);
                this.ColorspaceDropDown.Value='HSV';
                this.ColormapEditorModel.updateColorspace('HSV');
                this.CachedHSVOriginalColormap=this.ShiftAxes.Colormap;
            end
        end

        function editorTitle=getTitle(this)
            editorTitle=this.CurrentTitle;
        end


        function setTitle(this,title)
            this.CurrentTitle=title;
            this.InteractiveColorbar.Label.String=title;
            this.SpecifyColorColorbar.Label.String=title;
        end

        function setFigure(this,parentFigure)
            this.ParentFigure=parentFigure;

            this.addColormapEditorInteractions();
        end

        function removeObject(this)
            this.CurrentObject=[];
        end



        function setVisible(this)
            this.ColormapUIFigure.Visible='on';
        end

        function cSize=getColormapSize(this)
            cSize=this.SizeSpinner.Value;
        end

        function setColorLimits(this,cLimits)


            this.ColormapEditorModel.ColorLimits=cLimits;
            this.ClimMinEditField.Value=cLimits(1);
            this.ClimMaxEditField.Value=cLimits(2);
        end

        function cLim=getColorLimits(this)
            cLim=this.ColormapEditorModel.ColorLimits;
        end



        function setColorLimitsEnabled(this,enableFlag)
            this.ClimMinEditField.Enable=enableFlag;
            this.ClimMaxEditField.Enable=enableFlag;
        end

        function currentTitle=getCurrentItemLabel(this)
            currentTitle=this.ColormapUIFigure.Name;
        end

        function hObj=getCurrentObject(this)
            hObj=this.CurrentObject;
        end

        function setCurrentItemLabel(this,title)
            this.ColormapUIFigure.Name=title;
        end

        function enableResetAxes(this,enableFlag)
            this.ResetCurrent.Enable=enableFlag;
        end
    end


    methods(Access=?tColormapEditor)
        moveMarker(this,currentMarker);



        function dialogPos=getDialogPosition(this)
            figPos=getpixelposition(this.ParentFigure);
            dialogPos=[figPos(1)+figPos(3)+5,figPos(2),this.DIALOG_WIDTH,this.DIALOG_HEIGHT];
            screenSize=get(0,'ScreenSize');
            if strcmpi(this.ParentFigure.WindowState,'maximized')


                dialogPos(1)=figPos(1)+figPos(3)-dialogPos(3);
                dialogPos(2)=figPos(2);
            elseif strcmpi(this.ParentFigure.WindowStyle,'docked')


                dialogPos(1)=screenSize(3)/3;
                dialogPos(2)=screenSize(4)/3;
            else
                xPos=abs(dialogPos(1));

                if xPos>screenSize(3)
                    xPos=xPos-screenSize(3);
                end



                if(xPos+dialogPos(3))>screenSize(3)
                    dialogPos(1)=figPos(1)-dialogPos(3)-5;
                    dialogPos(2)=figPos(2);
                end
            end
        end



        function initColormapEditorUIAndModel(this)
            hObj=this.CurrentObject;
            if~isempty(hObj)
                cmap=hObj.Colormap;
                cmapName=this.findStandardColormap(cmap);


                this.updateModel(cmapName,...
                cmap,...
                'RGB',...
                0);
                this.setCurrentColorProperties(1);
            end
        end



        function createComponents(this)

            if isempty(this.FigureDataManager.PlotToolsAppFigure)||...
                ~isvalid(this.FigureDataManager.PlotToolsAppFigure)||...
                (~isempty(this.FigureDataManager.PlotToolsAppFigure)&&...
                strcmpi(get(this.FigureDataManager.PlotToolsAppFigure,'Visible'),'on'))
                this.ColormapUIFigure=this.FigureDataManager.getWarmedUpFigure();
                set(this.ColormapUIFigure,...
                'AutoResizeChildren','on',...
                'Position',this.getDialogPosition(),...
                'CloseRequestFcn',@(e,d)this.hideDialog(),...
                'Visible','on');
                this.ProgressDialog=uiprogressdlg(this.ColormapUIFigure,'Title',getString(message('MATLAB:datamanager:colormapeditor:ProgressLabel')),...
                'Message',getString(message('MATLAB:datamanager:colormapeditor:InitialLabel')),...
                'ShowPercentage','on');
            else
                this.ColormapUIFigure=this.FigureDataManager.getWarmedUpFigure();
                set(this.ColormapUIFigure,...
                'AutoResizeChildren','on',...
                'Position',this.getDialogPosition(),...
                'CloseRequestFcn',@(e,d)this.hideDialog(),...
                'Visible','off');
            end


            this.FigureDataManager.PlotToolsAppFigure=[];

            if isempty(this.MouseMoveListener)
                this.MouseMoveListener=event.listener(this.ColormapUIFigure,'WindowMouseMotion',@(e,d)this.updateCurrentColorOnMove(d));
                this.MouseMoveListener.Enabled=false;
            end



            this.ColormapUIFigure.Name=getString(message('MATLAB:datamanager:colormapeditor:ColormapUIFigure'));


            mainGridLayout=uigridlayout(this.ColormapUIFigure,'Scrollable','on');
            mainGridLayout.ColumnWidth={'1x'};
            mainGridLayout.RowHeight={'fit'};


            mainAccordion=matlab.ui.container.internal.Accordion('Parent',mainGridLayout);
            mainAccordion.Layout.Row=1;
            mainAccordion.Layout.Column=1;

            this.SelectColormapPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:SelectPanel')));

            this.CustomizeColormapPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:CustomizePanel')));

            this.EditSizeAndCSpacePanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:EditSizePanel')),...
            'Collapsed',true);

            this.SetCLimitsPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:SetLimitsPanel')),...
            'Collapsed',true);

            if~isempty(this.ProgressDialog)&&isvalid(this.ProgressDialog)
                this.ProgressDialog.Value=.98;
                this.ProgressDialog.Message=getString(message('MATLAB:datamanager:colormapeditor:FinishLabel'));
                drawnow limitrate;
            end
            this.createSubViews();

            set(this.ColormapUIFigure,'Visible','on');

            if~isempty(this.ProgressDialog)&&isvalid(this.ProgressDialog)
                delete(this.ProgressDialog);
            end
            internal.matlab.datatoolsservices.executeCmd('datamanager.FigureDataManager.warmUpFigure()');
        end

        function createSubViews(this)
            this.createMenuItems();
            this.createSelectColormapView();
            this.createCustomizeColormapView();
            this.createEditSizeColorspaceView();
            this.createSetColormapLimitsView();
        end

        function createMenuItems(this)

            this.EditorMenu=uimenu(this.ColormapUIFigure,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:EditorMenu')));


            this.ImportMenu=uimenu(this.EditorMenu,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Import')),...
            'Accelerator','I',...
            'MenuSelectedFcn',@(e,d)this.importCustomColormap());


            this.SaveasMenu=uimenu(this.EditorMenu,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Saveas')),...
            'Accelerator','S',...
            'MenuSelectedFcn',@(e,d)this.exportCustomColormap());


            this.EditMenu=uimenu(this.ColormapUIFigure,...
            'Text',['&',getString(message('MATLAB:datamanager:colormapeditor:EditMenu'))]);


            this.UndoMenu=uimenu(this.EditMenu,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Undo')),...
            'Accelerator','Z',...
            'MenuSelectedFcn',@(e,d)uiundo(this.ColormapUIFigure,'execUndo'));


            this.RedoMenu=uimenu(this.EditMenu,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Redo')),...
            'Accelerator','Y',...
            'MenuSelectedFcn',@(e,d)uiundo(this.ColormapUIFigure,'execRedo'));


            this.ResetCurrent=uimenu(this.EditMenu,...
            'Accelerator','R',...
            'MenuSelectedFcn',@(e,d)this.resetCurrentAxesColormap(),...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:ResetCurrent')));


            this.ResetAll=uimenu(this.EditMenu,...
            'MenuSelectedFcn',@(e,d)this.resetAllAxesColormap(),...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:ResetAll')));


            this.HelpMenu=uimenu(this.ColormapUIFigure,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:HelpMenu')));


            this.OpenDocumentationMenu=uimenu(this.HelpMenu,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:OpenDoc')),...
            'Accelerator','D',...
            'MenuSelectedFcn',@(e,d)this.openDocumentation());
        end

        function createSelectColormapView(this)
            selectCMapLayout=uigridlayout(this.SelectColormapPanel,'Padding',this.NOPADDING);
            selectCMapLayout.RowSpacing=this.FIXED_SPACING;
            selectCMapLayout.ColumnSpacing=this.FIXED_SPACING;
            selectCMapLayout.ColumnWidth={'fit','1x','fit'};
            selectCMapLayout.RowHeight={this.ROW_HEIGHT};


            this.ColormapDropDownLabel=uilabel(selectCMapLayout,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:SelectLabel')));
            this.ColormapDropDownLabel.Layout.Row=1;
            this.ColormapDropDownLabel.Layout.Column=1;


            this.ColormapDropDown=uidropdown(selectCMapLayout,...
            'Items',this.ColormapEditorModel.StandardColormaps,...
            'Value','Parula',...
            'ValueChangedFcn',@(e,d)this.changeColormapName(d));
            this.ColormapDropDown.Layout.Row=1;
            this.ColormapDropDown.Layout.Column=2;


            this.ImportButton=uibutton(selectCMapLayout,'push',...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Import')),...
            'Tooltip',getString(message('MATLAB:datamanager:colormapeditor:ImportLabel')),...
            'ButtonPushedFcn',@(e,d)this.importCustomColormap());
            this.ImportButton.Layout.Row=1;
            this.ImportButton.Layout.Column=3;
        end

        function createCustomizeColormapView(this)
            customizeCmapGrid=uigridlayout(this.CustomizeColormapPanel,'Padding',this.NOPADDING);
            customizeCmapGrid.ColumnWidth={'1x'};
            customizeCmapGrid.RowHeight={this.CUSTOMIZE_PANEL_HEIGHT};
            customizeCmapGrid.RowSpacing=this.FIXED_SPACING;
            customizeCmapGrid.ColumnSpacing=this.FIXED_SPACING;


            this.TabGroup=uitabgroup(customizeCmapGrid,...
            'SelectionChangedFcn',@(e,d)this.addColormapEditorInteractions());


            this.ShiftTab=uitab(this.TabGroup,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:Shift')),...
            'Tag','Shift');

            shiftGridLayout=uigridlayout(this.ShiftTab,'Padding',this.NOPADDING);
            shiftGridLayout.ColumnWidth={'1x'};
            shiftGridLayout.RowHeight={130,'fit'};
            shiftGridLayout.RowSpacing=0;
            shiftGridLayout.ColumnSpacing=this.FIXED_SPACING;

            axesPanel=uipanel(shiftGridLayout,...
            'BorderType','none',...
            'AutoResizeChildren','off');
            axesPanel.Layout.Row=1;
            axesPanel.Layout.Column=1;


            this.ShiftAxes=axes(axesPanel,...
            'Toolbar',[],...
            'Units','pixels',...
            'Position',this.AXES_POSITION,...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'AmbientLightColor',[0.9412,0.9412,0.9412],...
            'GridColor',[0.9412,0.9412,0.9412],...
            'MinorGridColor',[0.9412,0.9412,0.9412],...
            'XColor',[0.9412,0.9412,0.9412],...
            'YColor',[0.9412,0.9412,0.9412],...
            'Color',[0.9412,0.9412,0.9412]);

            disableDefaultInteractivity(this.ShiftAxes);


            this.InteractiveColorbar=colorbar(this.ShiftAxes,'southoutside',...
            'Units','pixels',...
            'Position',this.COLORBAR_POSITION,...
            'LabelMode','manual');




            this.removeColorbarListeners(this.InteractiveColorbar);

            this.CurrentTitle=getString(message('MATLAB:datamanager:colormapeditor:ColorData'));
            this.InteractiveColorbar.Label.Interpreter='none';
            this.InteractiveColorbar.Label.String=getString(message('MATLAB:datamanager:colormapeditor:ColorData'));


            this.SpecifyColorTab=uitab(this.TabGroup,...
            'Title',getString(message('MATLAB:datamanager:colormapeditor:SpecifyColor')),...
            'Tag','SpecifyColor');

            specifyColorGridLayout=uigridlayout(this.SpecifyColorTab,'Padding',this.NOPADDING);
            specifyColorGridLayout.ColumnWidth={'1x'};
            specifyColorGridLayout.RowHeight={130,'fit'};
            specifyColorGridLayout.RowSpacing=0;
            specifyColorGridLayout.ColumnSpacing=this.FIXED_SPACING;

            axesPanel=uipanel(specifyColorGridLayout,...
            'BorderType','none',...
            'AutoResizeChildren','off');
            axesPanel.Layout.Row=1;
            axesPanel.Layout.Column=1;


            this.SpecifyColorAxes=axes(axesPanel,...
            'Toolbar',[],...
            'Units','pixels',...
            'Position',this.AXES_POSITION,...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'AmbientLightColor',[0.9412,0.9412,0.9412],...
            'GridColor',[0.9412,0.9412,0.9412],...
            'MinorGridColor',[0.9412,0.9412,0.9412],...
            'XColor',[0.9412,0.9412,0.9412],...
            'YColor',[0.9412,0.9412,0.9412],...
            'Color',[0.9412,0.9412,0.9412]);
            this.SpecifyColorAxes.XAxis.Visible='off';
            this.SpecifyColorAxes.YAxis.Visible='off';
            this.SpecifyColorAxes.ZAxis.Visible='off';
            disableDefaultInteractivity(this.SpecifyColorAxes);

            this.SpecifyColorColorbar=colorbar(this.SpecifyColorAxes,'southoutside',...
            'Units','pixels',...
            'LabelMode','manual',...
            'Position',this.COLORBAR_POSITION);

            this.SpecifyColorColorbar.Label.Interpreter='none';
            this.SpecifyColorColorbar.Label.String=getString(message('MATLAB:datamanager:colormapeditor:ColorData'));

            this.removeColorbarListeners(this.SpecifyColorColorbar);

            controlGridLayout=uigridlayout(specifyColorGridLayout,'Padding',this.PADDING);
            controlGridLayout.ColumnWidth={'fit','1x','fit'};
            controlGridLayout.RowHeight={'fit','fit','fit'};
            controlGridLayout.RowSpacing=this.FIXED_SPACING;
            controlGridLayout.ColumnSpacing=this.FIXED_SPACING;
            controlGridLayout.Layout.Row=2;
            controlGridLayout.Layout.Column=1;


            this.CurrentColorEditFieldLabel=uilabel(controlGridLayout,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:CurrentColor')));
            this.CurrentColorEditFieldLabel.Layout.Row=1;
            this.CurrentColorEditFieldLabel.Layout.Column=1;


            this.CurrentColorEditField=uieditfield(controlGridLayout,'text',...
            'ValueChangedFcn',@(e,d)this.updateCurrentColor(d));
            this.CurrentColorEditField.Layout.Row=1;
            this.CurrentColorEditField.Layout.Column=2;


            this.ColorButton=matlab.ui.control.internal.ColorPicker('Parent',controlGridLayout,...
            'Value',[0.0588,1,1],...
            'ValueChangedFcn',@(e,d)this.showColorPicker(d));
            this.ColorButton.Layout.Row=1;
            this.ColorButton.Layout.Column=3;


            this.CurrentIndexEditFieldLabel=uilabel(controlGridLayout,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:CurrentIndex')));
            this.CurrentIndexEditFieldLabel.Layout.Row=2;
            this.CurrentIndexEditFieldLabel.Layout.Column=1;


            this.CurrentIndexEditField=uieditfield(controlGridLayout,'numeric',...
            'Value',1,...
            'LowerLimitInclusive','off',...
            'RoundFractionalValues','on',...
            'ValueChangedFcn',@(e,d)this.createMarker(d.Value));
            this.CurrentIndexEditField.Layout.Row=2;
            this.CurrentIndexEditField.Layout.Column=[2,3];


            this.CurrentCDataEditFieldLabel=uilabel(controlGridLayout,...
            'Tooltip',getString(message('MATLAB:datamanager:colormapeditor:CurrentCData')),...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:CurrentCData')));
            this.CurrentCDataEditFieldLabel.Layout.Row=3;
            this.CurrentCDataEditFieldLabel.Layout.Column=1;


            this.CurrentCDataEditField=uieditfield(controlGridLayout,'numeric',...
            'Enable','off');
            this.CurrentCDataEditField.Layout.Row=3;
            this.CurrentCDataEditField.Layout.Column=[2,3];


            set(axesPanel,...
            'SizeChangedFcn',@(e,d)this.updateAxesAndChildrenPosition(d));
        end

        function createEditSizeColorspaceView(this)
            editSizeCspaceGrid=uigridlayout(this.EditSizeAndCSpacePanel,'Padding',[0,0,10,0]);
            editSizeCspaceGrid.RowSpacing=this.FIXED_SPACING;
            editSizeCspaceGrid.ColumnSpacing=this.FIXED_SPACING;
            editSizeCspaceGrid.ColumnWidth={'fit','1x'};
            editSizeCspaceGrid.RowHeight={this.ROW_HEIGHT,this.ROW_HEIGHT,this.ROW_HEIGHT};


            this.SizeSpinnerLabel=uilabel(editSizeCspaceGrid,...
            'Tooltip',getString(message('MATLAB:datamanager:colormapeditor:Size')));
            this.SizeSpinnerLabel.Layout.Row=1;
            this.SizeSpinnerLabel.Layout.Column=1;


            this.SizeSpinner=uispinner(editSizeCspaceGrid,...
            'Limits',[1,1000],...
            'ValueChangedFcn',@(e,d)this.changeColormapSize());
            this.SizeSpinner.Layout.Row=1;
            this.SizeSpinner.Layout.Column=2;


            this.ColorspaceDropDownLabel=uilabel(editSizeCspaceGrid,...
            'Tooltip',getString(message('MATLAB:datamanager:colormapeditor:InterpolatingColorspace')),...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Colorspace')));
            this.ColorspaceDropDownLabel.Layout.Row=2;
            this.ColorspaceDropDownLabel.Layout.Column=1;


            this.ColorspaceDropDown=uidropdown(editSizeCspaceGrid,...
            'Items',{'RGB','HSV'},...
            'Value','RGB',...
            'ValueChangedFcn',@(e,d)this.changeColorspace());
            this.ColorspaceDropDown.Layout.Row=2;
            this.ColorspaceDropDown.Layout.Column=2;


            this.ReverseLabel=uilabel(editSizeCspaceGrid,...
            'Tooltip',getString(message('MATLAB:datamanager:colormapeditor:Reverse')),...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Reverse')));
            this.ReverseLabel.Layout.Row=3;
            this.ReverseLabel.Layout.Column=1;


            this.ReverseCheckBox=uicheckbox(editSizeCspaceGrid,...
            'Text','',...
            'ValueChangedFcn',@(e,d)this.inverseColormap());
            this.ReverseCheckBox.Layout.Row=3;
            this.ReverseCheckBox.Layout.Column=2;
        end

        function createSetColormapLimitsView(this)
            setClimitsGrid=uigridlayout(this.SetCLimitsPanel,'Padding',[0,0,10,0]);
            setClimitsGrid.RowSpacing=this.FIXED_SPACING;
            setClimitsGrid.ColumnSpacing=this.FIXED_SPACING;
            setClimitsGrid.ColumnWidth={'fit','1x'};
            setClimitsGrid.RowHeight={this.ROW_HEIGHT,this.ROW_HEIGHT};


            this.ClimMinEditFieldLabel=uilabel(setClimitsGrid,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:ClimMin')));
            this.ClimMinEditFieldLabel.Layout.Row=1;
            this.ClimMinEditFieldLabel.Layout.Column=1;


            this.ClimMinEditField=uieditfield(setClimitsGrid,'numeric',...
            'Value',this.InteractiveColorbar.Limits(1),...
            'ValueChangedFcn',@(e,d)this.changeColormapLimits());
            this.ClimMinEditField.Layout.Row=1;
            this.ClimMinEditField.Layout.Column=2;


            this.ClimMaxEditFieldLabel=uilabel(setClimitsGrid,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:ClimMax')));
            this.ClimMaxEditFieldLabel.Layout.Row=2;
            this.ClimMaxEditFieldLabel.Layout.Column=1;


            this.ClimMaxEditField=uieditfield(setClimitsGrid,'numeric',...
            'Value',this.InteractiveColorbar.Limits(2),...
            'ValueChangedFcn',@(e,d)this.changeColormapLimits());
            this.ClimMaxEditField.Layout.Row=2;
            this.ClimMaxEditField.Layout.Column=2;
        end


        function resetCurrentAxesColormap(this)
            hObj=this.getCurrentObject();


            if isprop(hObj,'ColormapMode')
                hObj.ColormapMode='auto';
            else
                cProp=findprop(hObj,'Colormap');
                hObj.Colormap=cProp.DefaultValue;
            end


            drawnow update;


            this.IsCustomColormap=false;
            newCmapName=this.findStandardColormap(hObj.Colormap);
            newMap=hObj.Colormap;
            isInverse=0;
            this.addUndoRedoAction(newCmapName,newMap,getCMapSize(newMap),'RGB',this.getColorLimits(),isInverse);
            this.updateColormapProperties(newCmapName,newMap,'RGB',isInverse);
        end



        function setColormapName(this,cName)
            if strcmpi(cName,this.CUSTOM_COLORMAP)
                this.IsCustomColormap=true;
            else
                this.IsCustomColormap=false;
            end
            if~ismember(this.ColormapDropDown.Items,cName)
                this.ColormapDropDown.Items{end+1}=cName;
            end
            this.ColormapDropDown.Value=cName;
        end


        function resetAllAxesColormap(this)
            hAx=findall(this.ParentFigure,'-isa','matlab.graphics.axis.AbstractAxes');
            if isempty(hAx)


                for i=1:length(hAx)
                    hObj=hAx(i);

                    if isprop(hObj,'ColormapMode')
                        hObj.ColormapMode='auto';
                    else
                        cProp=findprop(hObj,'Colormap');
                        hObj.Colormap=cProp.DefaultValue;
                    end
                end
            end
            this.resetCurrentAxesColormap();
        end


        function exportCustomColormap(this)



            this.bringToFront();
            if~isempty(this.ExportDialog)&&isvalid(this.ExportDialog)
                figure(this.ExportDialog);
                return;
            end
            this.ExportDialog=export2wsdlg({getString(message('MATLAB:datamanager:colormapeditor:SaveColormap'))},...
            {'CustomColormap'},...
            {this.ColormapEditorModel.ColormapData});
        end


        function importCustomColormap(this)

            baseWSVarContent=evalin('base','whos');
            newVarContent={''};
            Varssize=size(baseWSVarContent,1);
            j=1;

            for index=1:Varssize
                var=baseWSVarContent(index);
                if strcmp(var.class,'double')&&var.size(2)==3
                    matrix=evalin('base',var.name);
                    if size(matrix,2)==3&&all(matrix(:)<=1)&&all(matrix(:)>=0)
                        newVarContent{j}=var.name;
                        j=j+1;
                    end
                end
            end


            dialogXPos=this.ColormapUIFigure.Position(1)+this.ColormapUIFigure.Position(3)/6;
            dialogYPos=this.ColormapUIFigure.Position(2)+this.ColormapUIFigure.Position(4)/2;
            this.ImportDialog=uifigure('WindowStyle','modal',...
            'Visible','off',...
            'Internal',true,...
            'Position',[dialogXPos,dialogYPos,380,81],...
            'Name',getString(message('MATLAB:datamanager:colormapeditor:ImportFromWS')));

            gridLayout=uigridlayout(this.ImportDialog);
            gridLayout.ColumnWidth={'fit','1x'};
            gridLayout.RowHeight={'fit',40};


            dropDownLabel=uilabel(gridLayout,...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:SelectColormapToImport')));

            dropDownLabel.Layout.Row=1;
            dropDownLabel.Layout.Column=1;


            colorMapDropDown=uidropdown(gridLayout,...
            'Items',newVarContent,...
            'Position',[150,49,215,22],...
            'Value',newVarContent{1});

            colorMapDropDown.Layout.Row=1;
            colorMapDropDown.Layout.Column=2;

            gridLayout2=uigridlayout(gridLayout);
            gridLayout2.ColumnWidth={'1x','1x','1x'};
            gridLayout2.RowHeight={'1x'};
            gridLayout2.Layout.Row=2;
            gridLayout2.Layout.Column=2;


            importBtn=uibutton(gridLayout2,'push',...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:Import')),...
            'ButtonPushedFcn',@(e,d)this.importColormap(colorMapDropDown.Value));

            importBtn.Layout.Row=1;
            importBtn.Layout.Column=2;


            cancelBtn=uibutton(gridLayout2,'push',...
            'Text',getString(message('MATLAB:datamanager:colormapeditor:CancelButton')),...
            'ButtonPushedFcn',@(e,d)delete(this.ImportDialog));

            cancelBtn.Layout.Row=1;
            cancelBtn.Layout.Column=3;

            this.ImportDialog.Visible='on';
        end



        function importColormap(this,selectedColormap)

            try
                cmap=evalin('base',selectedColormap);
                this.IsCustomColormap=true;
                isInverse=0;
                this.addUndoRedoAction(this.CUSTOM_COLORMAP,cmap,getCMapSize(cmap),'RGB',this.getColorLimits(),isInverse);

                this.updateColormapProperties(this.CUSTOM_COLORMAP,cmap,'RGB',isInverse);

                this.setAndForceUpdateColormap(this.getCurrentObject(),cmap);
                delete(this.ImportDialog);
            catch
                this.showErrorDialog(getString(message('MATLAB:datamanager:colormapeditor:ErrorWhileImport')));
            end
        end


        function addColormapEditorInteractions(this)
            switch(this.TabGroup.SelectedTab.Tag)




            case 'Shift'
                this.ColorbarDragInteraction=datamanager.colormapeditor.interactions.ColorbarDragInteraction...
                (this.InteractiveColorbar,this);
                canvasContainer=this.InteractiveColorbar.Parent.getCanvas();
                canvasContainer.InteractionsManager.registerInteraction(this.InteractiveColorbar,this.ColorbarDragInteraction);

                this.setMouseMoveListenerState(false);
                set(this.ColormapUIFigure,'WindowButtonDownFcn',[],...
                'KeyPressFcn',[],...
                'KeyReleaseFcn',[]);
            case 'SpecifyColor'
                this.setMouseMoveListenerState(true);
                set(this.ColormapUIFigure,'WindowButtonDownFcn',@(e,d)this.handleMouseDown(e,d),...
                'KeyPressFcn',@(e,d)this.handleKeyPress(d),...
                'KeyReleaseFcn',@(e,d)this.handleKeyRelease());
            end
        end


        function changeColormapName(this,d)
            cmapName=d.Value;
            this.IsCustomColormap=false;
            if~strcmpi(cmapName,getString(message('MATLAB:datamanager:colormapeditor:CustomColormap')))


                newmap=feval(lower(cmapName),this.getColormapSize());

                this.addUndoRedoUpdateColormap(d.PreviousValue,...
                this.ColormapEditorModel.ColormapData,cmapName,newmap);
                this.updateColormapProperties(cmapName,newmap,this.ColorspaceDropDown.Value,this.isCMapInverse());

                this.setAndForceUpdateColormap(this.getCurrentObject(),newmap);

                this.setCurrentColorProperties(1);
            end
        end



        function cmapName=findStandardColormap(this,newColormap)



            cmapName=this.CUSTOM_COLORMAP;
            newColormapSize=getCMapSize(newColormap);

            cmaps={@parula,@turbo,@hsv,@hot,@cool,@spring,...
            @summer,@autumn,@winter,@gray,@bone,@copper,@pink,...
            @jet,@lines,@colorcube,@prism,@flag,@white};

            for k=1:length(cmaps)
                cmap=cmaps{k}(newColormapSize);
                if isequal(newColormap,cmap)

                    cmapName=this.ColormapDropDown.Items{k};
                    break;
                end
            end
        end



        function showColorPicker(this,d)

            if nargin>1
                selectedColor=d.Value;
            else
                selectedColor=uisetcolor(this.ColorButton.Value,...
                getString(message('MATLAB:datamanager:colormapeditor:ChooseColor')));
            end


            formattedColor=getFormattedColor(selectedColor);


            if~strcmpi(this.CurrentColorEditField.Value,formattedColor)
                this.CurrentColorEditField.Value=formattedColor;
                this.setSelectedMarkerColor(selectedColor);
            end
        end


        function updateCurrentColor(this,evd)
            oldColor=evd.PreviousValue;
            newColor=evd.Value;
            try

                newColor=str2num(newColor);%#ok<ST2NM>

                this.ColorButton.Value=newColor;
                this.setSelectedMarkerColor(newColor);
            catch
                this.CurrentColorEditField.Value=oldColor;
                this.showErrorDialog(getString(message('MATLAB:datamanager:colormapeditor:ErrorSettingColorMsg')));
            end
        end




        function changeColorspace(this)
            newValue=this.ColorspaceDropDown.Value;

            if strcmpi(newValue,'RGB')
                if isempty(this.CachedRGBOriginalColormap)
                    cmap=this.recalcCells();
                    this.CachedRGBOriginalColormap=cmap;
                else
                    cmap=this.CachedRGBOriginalColormap;
                end
            else
                if isempty(this.CachedHSVOriginalColormap)
                    cmap=this.recalcCells();
                    this.CachedHSVOriginalColormap=cmap;
                else
                    cmap=this.CachedHSVOriginalColormap;
                end
            end
            this.updateColormap(cmap);
        end


        function setCurrentColorProperties(this,currentIndex)
            cmap=this.ShiftAxes.Colormap;
            if~isempty(cmap)&&currentIndex~=-1
                this.CurrentIndexEditField.Value=currentIndex;

                currentColor=(this.ShiftAxes.Colormap(currentIndex,:,:));
                cLim=this.getColorLimits();

                this.CurrentColorEditField.Value=getFormattedColor(currentColor);


                if isinf(cLim(1))||isinf(cLim(2))
                    this.CurrentCDataEditField.Value=Inf;
                else
                    this.CurrentCDataEditField.Value=cLim(1)+((cLim(2)-cLim(1))*(currentIndex/this.getColormapSize()));
                end
                this.ColorButton.Value=currentColor;
            end
        end


        function xPos=calculateXPositionFromIndex(this,index)
            totalPos=this.SpecifyColorAxes.Position;
            unitWidth=(this.ColormapUIFigure.Position(3)-18)/this.getColormapSize();

            xPos=totalPos(1)+((index-1)*unitWidth);
            xPos=hgconvertunits(this.ColormapUIFigure,[xPos,0,0,0],this.ColormapUIFigure.Units,'normalized',this.ColormapUIFigure);
            xPos=xPos(1);
        end


        function inverseColormap(this)
            inverseCMap=flipud(colormap(this.ShiftAxes));
            this.addUndoRedoAction(this.CUSTOM_COLORMAP,inverseCMap,getCMapSize(inverseCMap),...
            this.ColorspaceDropDown.Value,this.getColorLimits(),this.isCMapInverse());
            this.updateColormapProperties(this.CUSTOM_COLORMAP,inverseCMap,this.ColorspaceDropDown.Value,this.isCMapInverse());

            this.setAndForceUpdateColormap(this.getCurrentObject(),inverseCMap);
        end


        function changeColormapLimits(this)
            try
                oldLimits=this.getColorLimits();
                newLimits=[this.ClimMinEditField.Value,this.ClimMaxEditField.Value];
                this.ColormapEditorModel.updateColorLimits(newLimits);
                set(this.ShiftAxes,'CLim',newLimits);
                set(this.SpecifyColorAxes,'CLim',newLimits);
                set(this.getCurrentObject(),'CLim',newLimits);
                this.addChangeLimitsUndoRedoAction(oldLimits,newLimits);
            catch
                this.ClimMinEditField.Value=oldLimits(1);
                this.ClimMaxEditField.Value=oldLimits(2);
                this.showErrorDialog(getString(message('MATLAB:datamanager:colormapeditor:InvalidCLim')));
            end
        end


        function changeColormapSize(this)
            if strcmpi(this.ColormapDropDown.Value,this.CUSTOM_COLORMAP)
                currentCMap=colormap(this.ShiftAxes);
                currSize=getCMapSize(currentCMap);
                if currSize==1


                    currSize=2;
                    currentCMap(2,:,:)=currentCMap(1,:,:);
                end
                cindex=linspace(1,currSize,this.getColormapSize());
                r=interp1([1:currSize],currentCMap(:,1),cindex);
                g=interp1([1:currSize],currentCMap(:,2),cindex);%#ok<*NBRAK>
                b=interp1([1:currSize],currentCMap(:,3),cindex);

                newCMap=[r',g',b'];
            else


                newCMap=feval(lower(this.ColormapDropDown.Value),this.getColormapSize());
            end
            cmapName=this.ColormapDropDown.Value;
            this.addUndoRedoAction(cmapName,newCMap,this.getColormapSize(),...
            this.ColorspaceDropDown.Value,this.getColorLimits(),this.isCMapInverse());
            this.updateColormapProperties(cmapName,newCMap,this.ColorspaceDropDown.Value,this.isCMapInverse());

            this.setAndForceUpdateColormap(this.getCurrentObject(),newCMap);
        end

        function index=getCurrentIndex(this)
            index=this.CurrentIndexEditField.Value;
        end


        function updateModel(this,cmapName,cMap,cSpace,isInverse)
            this.ColormapEditorModel.updateModel(cmapName,...
            cMap,...
            getCMapSize(cMap),...
            cSpace,...
            this.getColorLimits(),...
            isInverse);
        end

        function updateColormap(this,newColormap)
            this.addUndoRedoAction(this.CUSTOM_COLORMAP,newColormap,getCMapSize(newColormap),...
            this.ColorspaceDropDown.Value,this.getColorLimits(),this.isCMapInverse());

            this.updateColormapProperties(this.CUSTOM_COLORMAP,newColormap,this.ColorspaceDropDown.Value,this.isCMapInverse());
            this.updateObjectColormapNoUpdate(newColormap);
        end


        function updateViewBasedOnModel(this)
            [cmapName,cmap,cSize,cSpace,cLimits,isInverse]=this.ColormapEditorModel.getModelData();

            this.ColorspaceDropDown.Value=cSpace;
            if isInverse
                this.ReverseCheckBox.Value=1;
            else
                this.ReverseCheckBox.Value=0;
            end


            this.updateViewWithColormapData(cmapName,cmap,cSize);


            this.setColorLimits(cLimits);
            this.ShiftAxes.CLim=cLimits;
            this.SpecifyColorAxes.CLim=cLimits;
        end


        function updateViewWithColormapData(this,cmapName,cmap,cSize)
            this.setColormapName(cmapName);
            this.ShiftAxes.Colormap=cmap;
            this.SpecifyColorAxes.Colormap=cmap;
            this.SizeSpinner.Value=cSize;
            if cSize~=0
                this.CurrentIndexEditField.Limits=[0,cSize];
            end
        end


        function addChangeLimitsUndoRedoAction(this,oldLimits,newLimits)
            cmd=matlab.uitools.internal.uiundo.FunctionCommand;
            opName=sprintf('Limits Changed %s','Colormap');
            cmd.Name=opName;
            cmd.Function=@this.changeLimits;
            cmd.Varargin={this.getCurrentObject(),newLimits};
            cmd.InverseFunction=@this.changeLimits;
            cmd.InverseVarargin={this.getCurrentObject(),oldLimits};


            uiundo(this.ColormapUIFigure,'function',cmd);
        end


        function changeLimits(this,currentObj,colorLimits)
            this.ColormapEditorModel.updateColorLimits(colorLimits);
            set(this.ShiftAxes,'CLim',colorLimits);
            set(this.SpecifyColorAxes,'CLim',colorLimits);
            set(currentObj,'CLim',colorLimits);
        end


        function addUndoRedoAction(this,newCName,newCmap,newCSize,newCSpace,newCLimits,newIsInverse)
            [oldCName,oldCData,oldCSize,oldCSpace,oldCLimits,oldIsInverse]=this.ColormapEditorModel.getModelData();

            cmd=matlab.uitools.internal.uiundo.FunctionCommand;
            opName=sprintf('Update %s','Colormap');
            cmd.Name=opName;
            cmd.Function=@this.undoRedoColormapView;
            cmd.Varargin={this.getCurrentObject(),newCName,newCmap,newCSize,newCSpace,newCLimits,newIsInverse};
            cmd.InverseFunction=@this.undoRedoColormapView;
            cmd.InverseVarargin={this.getCurrentObject(),oldCName,oldCData,oldCSize,oldCSpace,oldCLimits,oldIsInverse};


            uiundo(this.ColormapUIFigure,'function',cmd);
        end


        function undoRedoColormapView(this,hObj,cName,cmap,cSize,cSpace,cLimits,isInverse)
            this.ColormapEditorModel.updateModel(cName,cmap,cSize,cSpace,cLimits,isInverse);
            this.updateViewBasedOnModel();
            this.setAndForceUpdateColormap(hObj,cmap);
        end
    end

    methods(Access={?tColormapEditor,?tcolormapeditor,?datamanager.colormapeditor.interactions.ColorbarDragInteraction})

        function updateUIOnDrag(this,cmapName,cmap)
            this.ColormapEditorModel.updateColormap(cmapName,cmap);
            this.setColormapName(cmapName);
            this.ShiftAxes.Colormap=cmap;
            this.SpecifyColorAxes.Colormap=cmap;
            this.setAndForceUpdateColormap(this.getCurrentObject(),cmap);
        end

        function updateColormapProperties(this,cmapName,newMap,cSpace,isInverse)

            this.updateModel(cmapName,...
            newMap,...
            cSpace,...
            isInverse);


            this.updateViewBasedOnModel();
        end

        function updateObjectColormapNoUpdate(this,newColormap)



            axesListener=[];
            if isprop(this.getCurrentObject(),'CMEditAxListeners')
                axesListener=get(this.getCurrentObject(),'CMEditAxListeners');
                axesListener.cmapchanged.Enabled=0;
            end

            this.setAndForceUpdateColormap(this.getCurrentObject(),newColormap);


            if~isempty(axesListener)
                axesListener.cmapchanged.Enabled=1;
            end
        end

        function cList=getColorMarkerList(this)
            cList=this.ColorMarkerList;
        end

        function setMouseMoveListenerState(this,isEnable)
            this.MouseMoveListener.Enabled=isEnable;
        end



        function resetMultiSelectedMarkers(this,currentIndex)
            if~this.IsCtrlKeyPressed
                for i=1:numel(this.SelectedMarkersIndices)
                    if this.ColorMarkerList(this.SelectedMarkersIndices(i))~=0
                        marker=handle(this.ColorMarkerList(this.SelectedMarkersIndices(i)));
                        marker.EdgeColor=[0,0,0];
                    end
                end
                this.CurrentMarkerIndex=-1;
                this.SelectedMarkersIndices=[];
                if nargin>1
                    this.setCurrentMarkerIndex(currentIndex);
                end
            end
        end

        function isInverse=isCMapInverse(this)
            isInverse=this.ReverseCheckBox.Value;
        end

        function cSpace=getColorSpace(this)
            cSpace=this.ColorspaceDropDown.Value;
        end

        function cMapName=getCurrentColorMapName(this)
            cMapName=this.ColormapDropDown.Value;
        end


        function currentMarker=updateMarkerPosition(this,oldIndex,newIndex)
            currentMarker=handle(this.ColorMarkerList(oldIndex));
            cmap=this.getColormap();
            currentColor=cmap(oldIndex,:);
            delete(currentMarker);
            this.ColorMarkerList(oldIndex)=0;
            this.createMarker(newIndex);
            currentMarker=handle(this.ColorMarkerList(newIndex));

            currentMarker.FaceVertexCData(2,:)=currentColor;
            this.setCurrentMarkerIndex(newIndex);
        end

        function cmap=getColormap(this)
            cmap=this.SpecifyColorAxes.Colormap;
        end



        function addUndoRedoUpdateColormap(this,oldCName,oldCMap,newCName,newCMap)
            cmd=matlab.uitools.internal.uiundo.FunctionCommand;
            opName=sprintf('Update %s','Colormap');
            cmd.Name=opName;
            cmd.Function=@this.undoRedoColormap;
            cmd.Varargin={this.getCurrentObject(),newCName,newCMap};
            cmd.InverseFunction=@this.undoRedoColormap;
            cmd.InverseVarargin={this.getCurrentObject(),oldCName,oldCMap};


            uiundo(this.ColormapUIFigure,'function',cmd);
        end

        function undoRedoColormap(this,hObj,cmapName,cmap)

            this.updateModel(cmapName,...
            cmap,...
            this.ColorspaceDropDown.Value,...
            this.isCMapInverse());


            this.updateViewWithColormapData(cmapName,cmap,getCMapSize(cmap));

            this.setCurrentColorProperties(1);


            this.setAndForceUpdateColormap(hObj,cmap);
        end
    end

    methods(Access=private)
        function showErrorDialog(this,errorMsg)

            dialogXPos=this.ColormapUIFigure.Position(1)+this.ColormapUIFigure.Position(3)/6;
            dialogYPos=this.ColormapUIFigure.Position(2)+this.ColormapUIFigure.Position(4)/2;
            this.ErrorMsgDlg=uifigure('WindowStyle','modal',...
            'Visible','off',...
            'Internal',true,...
            'Position',[dialogXPos,dialogYPos,380,90],...
            'Name',getString(message('MATLAB:datamanager:colormapeditor:ErrorInSave')));


            gridLayout=uigridlayout(this.ErrorMsgDlg);
            gridLayout.ColumnWidth={'1x'};
            gridLayout.RowHeight={'fit',50};
            gridLayout.ColumnSpacing=0;
            gridLayout.RowSpacing=0;
            gridLayout.Padding=[0,0,0,0];


            gridLayout1=uigridlayout(gridLayout);
            gridLayout1.ColumnWidth={12,'1x'};
            gridLayout1.RowHeight={50};
            gridLayout1.ColumnSpacing=5;
            gridLayout1.RowSpacing=0;
            gridLayout1.Padding=[10,0,10,0];
            gridLayout1.Layout.Row=1;
            gridLayout1.Layout.Column=1;

            errorImage=uiimage(gridLayout1,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+colormapeditor','ColormapEditor','error_12.png'));
            errorImage.Layout.Row=1;
            errorImage.Layout.Column=1;


            errorLabel=uilabel(gridLayout1);
            errorLabel.Layout.Row=1;
            errorLabel.Layout.Column=2;
            errorLabel.Text=errorMsg;


            gridLayout2=uigridlayout(gridLayout);
            gridLayout2.ColumnWidth={'1x',80};
            gridLayout2.RowHeight={25};
            gridLayout2.Layout.Row=2;
            gridLayout2.Layout.Column=1;
            gridLayout2.ColumnSpacing=0;
            gridLayout2.RowSpacing=0;
            gridLayout2.Padding=[0,10,10,5];


            oKButton=uibutton(gridLayout2,'push');
            oKButton.Layout.Row=1;
            oKButton.Layout.Column=2;
            oKButton.Text=getString(message('MATLAB:datamanager:colormapeditor:OkLabel'));
            oKButton.ButtonPushedFcn=@(e,d)close(this.ErrorMsgDlg);


            this.ErrorMsgDlg.Visible='on';
        end



        function updateAxesAndChildrenPosition(this,eventData)
            this.SpecifyColorAxes.Position(3)=(eventData.Source.Position(3)-18);
            this.SpecifyColorColorbar.Position(3)=this.SpecifyColorAxes.Position(3)-16;
            this.ShiftAxes.Position(3)=this.SpecifyColorAxes.Position(3);
            this.InteractiveColorbar.Position(3)=this.SpecifyColorAxes.Position(3)-16;
            this.updateMarkerPositionOnResize();
        end



        function updateMarkerPositionOnResize(this)
            for ind=1:numel(this.ColorMarkerList)
                if this.ColorMarkerList(ind)~=0
                    xPos=this.calculateXPositionFromIndex(ind);
                    marker=handle(this.ColorMarkerList(ind));
                    marker.NodeParent.NodeParent.NodeParent.Anchor(1)=xPos;
                end
            end
        end
    end

    methods(Access=?tColormapEditor)


        function createMarker(this,index)
            xPos=this.calculateXPositionFromIndex(index);
            cmap=this.getColormap();
            if numel(this.ColorMarkerList)>=index&&this.ColorMarkerList(index)~=0
                delete(this.ColorMarkerList(index));
            end

            mhandle=matlab.graphics.primitive.Marker('Parent',this.SpecifyColorAxes,...
            'Internal',true,...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off');
            primitiveObj=patch('Faces',[1,2,3,4,5;6,7,8,9,NaN],...
            'Vertices',7*[0,-1,-1,1,1,-0.55,-0.55,0.55,0.55;0,1,2,2,1,1.25,1.75,1.75,1.25]',...
            'Parent',mhandle,...
            'Internal',true,...
            'Clipping','off',...
            'FaceVertexCData',[1,1,1;cmap(index,:,:)],...
            'FaceColor','flat',...
            'EdgeColor',[0,0,0]);
            if index==1||index==this.getColormapSize()
                primitiveObj.FaceVertexCData(1,:,:)=[0.7,0.7,0.7];
            end
            mhandle.Anchor=[xPos,0.36,0];
            this.ColorMarkerList(index)=primitiveObj;
        end

        function markerList=findMarkersFromList(this)
            markerList=this.ColorMarkerList(this.ColorMarkerList~=0);
        end


        function setColormapModelRGB(this,cmap)
            this.ColorMarkerList(this.ColorMarkerList==0)=[];
            for i=1:numel(this.ColorMarkerList)
                delete(this.ColorMarkerList(i));
            end
            this.ColorMarkerList=[];
            cmapSize=getCMapSize(cmap);
            for i=1:cmapSize
                if i==1||i==cmapSize||isColorGradientChange(cmap,i)
                    this.createMarker(i);
                end
            end
        end


        function setColormapModelHSV(this,cmap)
            this.ColorMarkerList(this.ColorMarkerList==0)=[];
            for i=1:numel(this.ColorMarkerList)
                delete(this.ColorMarkerList(i));
            end
            this.ColorMarkerList=[];
            cmapSize=getCMapSize(cmap);
            hcvMap=zeros(cmapSize,3);
            hcvMap=convertRGB2HSV(cmap,hcvMap);
            dhuecum=0.0;
            for i=1:cmapSize
                if i==1||i==cmapSize
                    this.createMarker(i);
                else

                    dr1=hcvMap(i,1)-hcvMap(i-1,1);

                    dr2=hcvMap(i+1,1)-hcvMap(i,1);



                    dhuecum=dhuecum+dr1;
                    if(isColorGradientChange(hcvMap,i)||(dhuecum+dr2)>0.4)
                        this.createMarker(i);

                        dhuecum=0.0;
                    end
                end
            end
        end



        function handleKeyRelease(this)
            this.IsCtrlKeyPressed=false;
        end




        function isDraggable=isMarkerDraggable(this,markerIndex)
            isDraggable=(markerIndex>1&&...
            markerIndex<this.getColormapSize());
        end

        function handleKeyPress(this,evd)
            if strcmpi(evd.Modifier,'Control')
                this.IsCtrlKeyPressed=true;
                return;
            end
            if this.isMarkerDraggable(this.CurrentMarkerIndex)
                keypressed=evd.Key;

                switch keypressed

                case 'leftarrow'
                    this.resetMultiSelectedMarkers(this.CurrentMarkerIndex);
                    this.moveSelectedMarker(this.CurrentMarkerIndex,this.CurrentMarkerIndex-1);

                case 'rightarrow'
                    this.resetMultiSelectedMarkers(this.CurrentMarkerIndex);
                    this.moveSelectedMarker(this.CurrentMarkerIndex,this.CurrentMarkerIndex+1);

                case 'delete'
                    this.deleteSelectedMarkers();
                end
            end
        end

        function multiSelectMarkers(this,currentIndex)

            this.CurrentMarkerIndex=currentIndex;
            if isempty(this.SelectedMarkersIndices(this.SelectedMarkersIndices==currentIndex))
                this.SelectedMarkersIndices(end+1)=currentIndex;
            end
            if this.ColorMarkerList(currentIndex)~=0
                currentMarker=handle(this.ColorMarkerList(currentIndex));
                currentMarker.EdgeColor=[0,0.6,1];
            end
        end







        function handleMouseDown(this,e,d)


            this.resetMultiSelectedMarkers();

            hObj=d.HitObject;
            if isa(hObj,'matlab.graphics.primitive.Patch')
                currentIndex=find(this.ColorMarkerList==double(hObj));


                this.createMarker(currentIndex);
                hObj=handle(this.ColorMarkerList(currentIndex));


                if this.IsCtrlKeyPressed
                    this.multiSelectMarkers(currentIndex);
                    return;
                end
                this.setCurrentMarkerIndex(currentIndex);


                if strcmpi(e.SelectionType,'open')
                    this.setCurrentColorProperties(currentIndex);
                    this.showColorPicker();


                elseif this.isMarkerDraggable(currentIndex)
                    this.moveMarker(hObj);
                end
            elseif isa(hObj,'matlab.graphics.illustration.ColorBar')
                index=this.LastMouseHoverIndex;
                if index==-1
                    index=this.getCurrentIndex();
                end
                this.createMarker(index);

                this.setCurrentColorProperties(index);
            end
        end



        function moveSelectedMarker(this,currentIndex,newIndex)
            cList=this.ColorMarkerList;
            if cList(currentIndex)==0
                return;
            end
            prevIndex=find(cList(1:currentIndex-1),1,'last');
            nextIndex=currentIndex+find(cList(currentIndex+1:end),1,'first');
            if newIndex<=currentIndex
                if newIndex<=prevIndex
                    return;
                end
            elseif newIndex>=nextIndex
                return;
            end

            newMap=this.getColormap();
            if currentIndex~=newIndex
                this.updateMarkerPosition(currentIndex,newIndex);
                newMap=this.updateColorCellsBetweenMarkers(prevIndex,newIndex,newMap);
                newMap=this.updateColorCellsBetweenMarkers(newIndex,nextIndex,newMap);
                this.updateColormapProperties(getString(message('MATLAB:datamanager:colormapeditor:CustomColormap')),...
                newMap,this.getColorSpace(),this.isCMapInverse());
                this.updateObjectColormapNoUpdate(newMap);
            end
        end


        function setCurrentMarkerIndex(this,index)
            this.CurrentMarkerIndex=index;
            this.SelectedMarkersIndices=index;
            this.setCurrentColorProperties(index);


            if this.ColorMarkerList(index)~=0
                currentMarker=handle(this.ColorMarkerList(index));
                currentMarker.EdgeColor=[0,0.6,1];
            end
        end


        function cmap=recalcCells(this)
            cList=this.getColorMarkerList();
            cmap=this.getColormap();
            newList=cList(cList~=0);
            for i=1:length(newList)-1
                cmark=handle(newList(i));
                nmark=handle(newList(i+1));
                startIndex=find(cList==double(cmark));
                endIndex=find(cList==double(nmark));
                firstColor=cmap(startIndex,:);
                firstHSVColor=rgb2hsv(firstColor);
                lastColor=cmap(endIndex,:);
                lastHSVColor=rgb2hsv(lastColor);

                if strcmpi(this.ColorspaceDropDown.Value,'RGB')
                    for colorMapInd=startIndex+1:endIndex-1
                        interval=(lastColor-firstColor)./(endIndex-startIndex);
                        cmap(colorMapInd,:)=firstColor+interval*(colorMapInd-startIndex);
                    end
                else
                    for colorMapInd=startIndex+1:endIndex-1
                        frx=(colorMapInd-startIndex)/(endIndex-startIndex);


                        firstHue=firstHSVColor(1);
                        lastHue=lastHSVColor(1);


                        if firstHue<lastHue
                            df=lastHue-firstHue;
                            db=(1.0-lastHue)+firstHue;
                            if df<=db
                                cmap(colorMapInd,1)=firstHue+(lastHue-firstHue)*frx;
                            else

                                bfrx=(1.0-endIndex)/db;
                                ffrx=startIndex/db;
                                if frx<ffrx
                                    cmap(colorMapInd,1)=firstHue*(1.0-frx/ffrx);
                                elseif frx==ffrx
                                    cmap(colorMapInd,1)=0;
                                else
                                    cmap(colorMapInd,1)=1.0-((1.0-lastHue)*((frx-ffrx)/bfrx));
                                end
                            end
                        else

                            df=firstHue-lastHue;
                            db=(1.0-firstHue)+lastHue;

                            if df<=db
                                cmap(colorMapInd,1)=firstHue+((lastHue-firstHue)*frx);
                            else

                                bfrx=(1.0-firstHue)/db;
                                ffrx=lastHue/db;
                                if frx<bfrx
                                    cmap(colorMapInd,1)=firstHue+((1.0-firstHue)*(frx/bfrx));
                                elseif frx==bfrx
                                    cmap(colorMapInd,1)=1;
                                else
                                    cmap(colorMapInd,1)=lastHue*((frx-bfrx)/ffrx);
                                end
                            end
                        end
                        cmap(colorMapInd,2:3)=firstHSVColor(2:3)+(lastHSVColor(2:3)-firstHSVColor(2:3))*frx;

                        cmap(colorMapInd,:)=hsv2rgb(cmap(colorMapInd,:));
                    end
                end
            end
        end



        function deleteSelectedMarkers(this)

            if isempty(this.SelectedMarkersIndices)
                return;
            end
            selectedIndices=this.SelectedMarkersIndices(this.SelectedMarkersIndices~=1);
            selectedIndices=selectedIndices(selectedIndices~=this.getColormapSize());

            if~isempty(selectedIndices)
                for i=1:numel(selectedIndices)
                    selectedMarkerInd=selectedIndices(i);

                    currentMarker=handle(this.ColorMarkerList(selectedMarkerInd));
                    delete(currentMarker);
                    this.ColorMarkerList(selectedMarkerInd)=0;

                    newMap=this.getColormap();
                    prevIndex=find(this.ColorMarkerList(1:selectedMarkerInd-1),1,'last');
                    nextIndex=selectedMarkerInd+find(this.ColorMarkerList(selectedMarkerInd+1:end),1,'first');
                    newMap=this.updateColorCellsBetweenMarkers(prevIndex,nextIndex,newMap);
                    this.updateColormap(newMap);
                end
                this.SelectedMarkersIndices=[];
                this.CurrentMarkerIndex=-1;
            end
        end



        function setSelectedMarkerColor(this,newColor)

            cList=this.ColorMarkerList;
            currInd=this.CurrentIndexEditField.Value;
            prevInd=find(cList(1:currInd-1),1,'last');
            nextInd=currInd+find(cList(currInd+1:end),1,'first');

            this.createMarker(currInd);
            currMarker=handle(this.ColorMarkerList(currInd));
            currMarker.FaceVertexCData(2,:)=newColor;
            oldMap=colormap(this.ShiftAxes);
            cMap=oldMap;
            cMap(currInd,:,:)=newColor;
            cLims=this.getColorLimits();
            cSpace=this.ColormapEditorModel.Colorspace;
            this.ShiftAxes.Colormap=cMap;
            this.SpecifyColorAxes.Colormap=cMap;

            newMap=this.getColormap();
            if currInd==1
                newMap=this.updateColorCellsBetweenMarkers(currInd,nextInd,newMap);
            elseif currInd==this.getColormapSize()
                newMap=this.updateColorCellsBetweenMarkers(prevInd,currInd,newMap);
            else
                newMap=this.updateColorCellsBetweenMarkers(prevInd,currInd,newMap);
                newMap=this.updateColorCellsBetweenMarkers(currInd,nextInd,newMap);
            end

            this.addUndoRedoAction(this.CUSTOM_COLORMAP,newMap,getCMapSize(newMap),cSpace,cLims,this.isCMapInverse());
            this.updateColormapProperties(this.CUSTOM_COLORMAP,newMap,cSpace,this.isCMapInverse());
            this.updateObjectColormapNoUpdate(newMap);
        end

        function index=getIndexFromXPos(this,xPos)
            axesPos=this.SpecifyColorAxes.Position;
            unitWidth=axesPos(3)-axesPos(1);
            index=ceil(((xPos-axesPos(1))/unitWidth)*this.getColormapSize());

            if index<1
                index=1;
            end
            if index>this.getColormapSize()
                index=this.getColormapSize();
            end
        end

        function cmap=updateColorCellsBetweenMarkers(this,index1,index2,cmap)
            if index1~=index2
                rgb12=zeros(2,3);
                hsv12=zeros(2,3);


                fltColor1=cmap(index1,:);
                for i=1:3
                    rgb12(1,i)=fltColor1(i);
                end


                fltColor2=cmap(index2,:);
                for i=1:3
                    rgb12(2,i)=fltColor2(i);
                end

                if strcmpi(this.ColorspaceDropDown.Value,'RGB')
                    for j=index1:index2
                        frx=(j-index1)/(index2-index1);
                        rgbj=zeros(3);
                        for i=1:3
                            rgbj(i)=rgb12(1,i)+((rgb12(2,i)-rgb12(1,i))*frx);
                        end
                        newColor=[rgbj(1),rgbj(2),rgbj(3)];
                        cmap(j,:)=newColor;
                    end
                else
                    hsv12=convertRGB2HSV(rgb12,hsv12);
                    hsvj=zeros(2,3);
                    rgbj=zeros(2,3);
                    for j=index1:index2
                        h1=hsv12(1,1);
                        h2=hsv12(2,1);
                        frx=(j-index1)/(index2-index1);


                        if(h2>h1)
                            df=h2-h1;
                            db=(1.0-h2)+h1;
                            if(df<=db)
                                hsvj(1,1)=h1+((h2-h1)*frx);
                            else
                                bfrx=(1.0-h2)/db;
                                ffrx=h1/db;
                                if(frx<ffrx)
                                    hsvj(1,1)=h1*(1.0-frx/ffrx);
                                elseif(frx==ffrx)
                                    hsvj(1,1)=0.0;
                                else
                                    hsvj(1,1)=1.0-((1.0-h2)*((frx-ffrx)/bfrx));
                                end
                            end
                        else
                            df=h1-h2;
                            db=(1.0-h1)+h2;
                            if(df<=db)
                                hsvj(1,1)=h1+((h2-h1)*frx);
                            else
                                bfrx=(1.0-h1)/db;
                                ffrx=h2/db;
                                if(frx<bfrx)
                                    hsvj(1,1)=h1+((1.0-h1)*(frx/bfrx));
                                elseif(frx==bfrx)
                                    hsvj(1,1)=1;
                                else
                                    hsvj(1,1)=h2*((frx-bfrx)/ffrx);
                                end
                            end
                        end
                    end
                    for i=1:2
                        hsvj(1,i)=hsv12(1,i)+((hsv12(2,i)-hsv12(1,i))*frx);
                    end
                    rgbj=convertHSV2RGB(hsvj,rgbj);
                    newColor=[rgbj(1,1),rgbj(1,2),rgbj(1,3)];
                    cmap(j,:)=newColor;
                end
            end
        end



        function updateCurrentColorOnMove(this,d)
            if isa(d.HitObject,'matlab.graphics.illustration.ColorBar')


                colorbarLimits=this.SpecifyColorColorbar.Limits;
                unitWidth=(colorbarLimits(2)-colorbarLimits(1));
                currentIndex=ceil(((d.IntersectionPoint(1)-colorbarLimits(1))/unitWidth)*this.getColormapSize());

                if currentIndex<1
                    currentIndex=1;
                end
                if currentIndex>this.getColormapSize()
                    currentIndex=this.getColormapSize();
                end
                this.LastMouseHoverIndex=currentIndex;


                if this.CurrentMarkerIndex==-1
                    this.setCurrentColorProperties(currentIndex);
                end
            end
        end
    end

    methods(Access=?tcolormapeditor,Static)



        function setAndForceUpdateColormap(hObj,cmap)
            colormap(hObj,cmap);
            drawnow;
        end

        function openDocumentation()
            doc('colormapeditor');
        end

        function removeColorbarListeners(cbar)





            for i=1:numel(cbar.AxesListenerList)
                listener=cbar.AxesListenerList{i};
                if strcmpi(listener.EventName,'PostSet')||...
                    (isa(listener.Source{1},'matlab.graphics.axis.colorspace.MapColorSpace')&&strcmpi(listener.EventName,'MarkedDirty'))
                    delete(cbar.AxesListenerList{i});
                end
            end
        end
    end
end


function color=getFormattedColor(selectedColor)
    color=sprintf("[%s,%s,%s]",sprintf("%0.1f",selectedColor(1)),...
    sprintf("%0.1f",selectedColor(2)),...
    sprintf("%0.1f",selectedColor(3)));
end

function hsv=RGBtoHSV(rgb)
    cmapSize=getCMapSize(rgb);
    hsv=zeros(cmapSize,1);
    for i=1:cmapSize
        r=rgb(i,1)*255;
        g=rgb(i,2)*255;
        b=rgb(i,3)*255;

        if r>g
            cmax=r;
        else
            cmax=g;
        end

        if b>cmax
            cmax=b;
        end

        if r<g
            cmin=r;
        else
            cmin=g;
        end

        if b<cmin
            cmin=b;
        end

        brightness=cmax/255.0;
        if cmax~=0
            saturation=(cmax-cmin)/cmax;
        else
            saturation=0;
        end

        if saturation==0
            hue=0;
        else
            redc=(cmax-r)/(cmax-cmin);
            greenc=(cmax-g)/(cmax-cmin);
            bluec=(cmax-b)/(cmax-cmin);
            if r==cmax
                hue=bluec-greenc;
            elseif g==cmax
                hue=2.0+redc-bluec;
            else
                hue=4.0+greenc-redc;
            end

            hue=hue/6.0;
            if hue<0
                hue=hue+1.0;
            end
        end

        hsv(i,1)=hue;
        hsv(i,2)=saturation;
        hsv(i,3)=brightness;
    end
end

function rgb=HSVtoRGB(hsv)
    cmapSize=getCMapSize(hsv);
    rgb=zeros(cmapSize,1);
    for i=1:cmapSize
        r=0;g=0;b=0;
        hue=hsv(i,1);
        saturation=hsv(i,2);
        brightness=hsv(i,3);

        if saturation==0
            r=(brightness*255+0.5);
            g=r;
            b=r;
        else
            h=(hue-floor(hue))*6;
            f=h-floor(h);
            p=brightness*(1-saturation);
            q=brightness*(1-saturation*f);
            t=brightness*(1-(saturation*(1-f)));

            switch(floor(h))
            case 0
                r=brightness*255.0+0.5;
                g=t*255.0+0.5;
                b=p*255.0+0.5;
            case 1
                r=q*255.0+0.5;
                g=brightness*255.0+0.5;
                b=p*255.0+0.5;
            case 2
                r=p*255.0+0.5;
                g=brightness*255.0+0.5;
                b=t*255.0+0.5;
            case 3
                r=p*255.0+0.5;
                g=q*255.0+0.5;
                b=brightness*255.0+0.5;
            case 4
                r=t*255.0+0.5;
                g=p*255.0+0.5;
                b=brightness*255.0+0.5;
            case 5
                r=brightness*255.0+0.5;
                g=p*255.0+0.5;
                b=q*255.0+0.5;
            end
        end

        rgb(i,1)=min(r/255,1);
        rgb(i,2)=min(g/255,1);
        rgb(i,3)=min(b/255,1);
    end
end

function isGradientChanged=isColorGradientChange(cmap,index)

    dr1=cmap(index,1)-cmap(index-1,1);
    dg1=cmap(index,2)-cmap(index-1,2);
    db1=cmap(index,3)-cmap(index-1,3);

    dr2=cmap(index+1,1)-cmap(index,1);
    dg2=cmap(index+1,2)-cmap(index,2);
    db2=cmap(index+1,3)-cmap(index,3);

    isGradientChanged=(abs(dr1-dr2)*getCMapSize(cmap)>0.32)||...
    (abs(dg1-dg2)*getCMapSize(cmap)>0.32)||...
    (abs(db1-db2)*getCMapSize(cmap)>0.32);
end

function nnodes=testRGBNumberOfMarkers(cmap)


    nnodes=0;
    cmapSize=getCMapSize(cmap);
    for CI=2:cmapSize-2

        if(isColorGradientChange(cmap,CI))
            nnodes=nnodes+1;
        end
    end
end

function nnodes=testHSVNumberOfMarkers(cmap)
    nnodes=0;
    cmapSize=getCMapSize(cmap);
    hcmap=zeros(cmapSize,3);
    hcmap=convertRGB2HSV(cmap,hcmap);

    for CI=2:cmapSize-2
        if(isColorGradientChange(hcmap,CI))
            nnodes=nnodes+1;
        end
    end
end

function hsvMap=convertRGB2HSV(rgbMap,hsvMap)
    results=RGBtoHSV(rgbMap);
    cmapSize=getCMapSize(results);
    if~isempty(results)
        hsvMap=zeros(cmapSize,3);
        for i=1:cmapSize
            hsvMap(i,1)=results(i,1);
            hsvMap(i,2)=results(i,2);
            hsvMap(i,3)=results(i,3);
        end
    end
end

function rgbMap=convertHSV2RGB(hsvMap,rgbMap)
    results=HSVtoRGB(hsvMap);
    cmapSize=getCMapSize(results);
    if~isempty(results)
        rgbMap=zeros(cmapSize,3);
        for i=1:cmapSize
            rgbMap(i,1)=results(i,1);
            rgbMap(i,2)=results(i,2);
            rgbMap(i,3)=results(i,3);
        end
    end
end

function cmapSize=getCMapSize(cmap)
    cmapSize=size(cmap);
    cmapSize=cmapSize(1);
end
classdef BasicFitDialog<handle







    properties(Access={?datamanager.basicfit.BasicFittingManager,?tbasicfit,?tBasicFittingManager,?tBasicFitDialog})
        BasicFitFigure matlab.ui.Figure
        TypesOfFitPanel matlab.ui.container.internal.AccordionPanel
        FitResultsPanel matlab.ui.container.internal.AccordionPanel
        ResidualsPanel matlab.ui.container.internal.AccordionPanel
        EvaluatePanel matlab.ui.container.internal.AccordionPanel


        SelectDataGrid matlab.ui.container.GridLayout
        SelectDataDropDown matlab.ui.control.DropDown
        HelpImage matlab.ui.control.Image
        NormalizeXCheckBox matlab.ui.control.CheckBox


        SplineinterpolantCheckBox matlab.ui.control.CheckBox
        ShapePreservingCheckBox matlab.ui.control.CheckBox
        LinearCheckBox matlab.ui.control.CheckBox
        QuadraticCheckBox matlab.ui.control.CheckBox
        CubicCheckBox matlab.ui.control.CheckBox
        Degree4CheckBox matlab.ui.control.CheckBox
        Degree5CheckBox matlab.ui.control.CheckBox
        Degree6CheckBox matlab.ui.control.CheckBox
        Degree7CheckBox matlab.ui.control.CheckBox
        Degree8CheckBox matlab.ui.control.CheckBox
        Degree9CheckBox matlab.ui.control.CheckBox
        Degree10CheckBox matlab.ui.control.CheckBox


        SignificantDigitsDropDown matlab.ui.control.DropDown
ResultTabGridLayout
        ResultsTabGroup matlab.ui.container.TabGroup
        ShowRCheckBox matlab.ui.control.CheckBox
        ShowNormCheckBox matlab.ui.control.CheckBox
        ShowEquationCheckBox matlab.ui.control.CheckBox
        EquationLabel matlab.ui.control.Label
        R2Label matlab.ui.control.Label
        NormLabel matlab.ui.control.Label
        MoreResultsButton matlab.ui.control.Button
        ExportResultsButton matlab.ui.control.Button


        PlotLocationDropDown matlab.ui.control.DropDown
        PlotStyleDropDown matlab.ui.control.DropDown
        ShowNormResidCheckBox matlab.ui.control.CheckBox


        EnterDataField matlab.ui.control.EditField
        PlotDataCheckBox matlab.ui.control.CheckBox
        ExportEvaluationButton matlab.ui.control.Button
        EvaluationTable matlab.ui.control.Table
    end

    properties(Access={?datamanager.basicfit.BasicFittingManager,?tbasicfit,?tBasicFittingManager,?tBasicFitDialog})

ProgressDialog
MoreResultsDialog
ExportResultsDialog
ExportEvaluatedDataDialog
    end


    properties(Access={?datamanager.basicfit.BasicFittingManager,?tBasicFittingManager,?tBasicFitDialog})

DataObjectHandles


DisplayedFitResults

ParentFigure


BasicFitManager


CurrentObject

FitResults

FitTypesCheckboxGroup

        FigureDataManager datamanager.FigureDataManager
    end

    properties(Access=?tBasicFitDialog,Constant)



        FIT_TYPES=["Spline","Shape",...
        "Linear","Quadratic","Cubic","4 degree",...
        "5 degree","6 degree","7 degree",...
        "8 degree","9 degree","10 degree"]

        RESIDUALS_PLOT_STYLES=[...
        string(getString(message('MATLAB:datamanager:basicfit:barVal'))),...
        string(getString(message('MATLAB:datamanager:basicfit:scatterVal'))),...
        string(getString(message('MATLAB:datamanager:basicfit:lineVal')))];

        RESIDUALS_PLOT_LOCATION=[string(getString(message('MATLAB:datamanager:basicfit:subplotVal'))),...
        string(getString(message('MATLAB:datamanager:basicfit:newFigureVal')))];


        NUM_OF_FITS=12
        DIALOG_WIDTH=475
        DIALOG_HEIGHT=473
        RESULT_PANEL_HEIGHT=124;
        FITTYPE_PANEL_HEIGHT=78
        ROW_HEIGHT=23
        ICON_SIZE=16
        PADDING=[5,5,10,0]
        NOPADDING=[0,0,0,0]
        FIXED_SPACING=5
    end

    methods(Access={?datamanager.basicfit.BasicFittingManager,?tBasicFittingManager,?tBasicFitDialog})

        function this=BasicFitDialog(BasicFitManager,parentFig)
            try
                this.ParentFigure=parentFig;
                addlistener(parentFig,'ObjectBeingDestroyed',@(e,d)this.delete());
                this.BasicFitManager=BasicFitManager;

                this.FigureDataManager=datamanager.FigureDataManager.getInstance();
                this.createComponents();
            catch
                this.delete();
            end
        end

        function delete(this)

            delete(this.MoreResultsDialog);
            delete(this.ExportEvaluatedDataDialog);
            delete(this.ExportResultsDialog);
            delete(this.BasicFitFigure);
        end

        function close(this)
            delete(this.MoreResultsDialog);
            delete(this.ExportEvaluatedDataDialog);
            delete(this.ExportResultsDialog);
            set(this.BasicFitFigure,'Visible','off');
        end

        function state=isClosed(this)
            state=isempty(this.BasicFitFigure)||~isvalid(this.BasicFitFigure)||...
            this.BasicFitFigure.Visible=="off";
        end

        function bringToFront(this)


            set(this.BasicFitFigure,'Visible','on');
            figure(this.BasicFitFigure);
        end




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

        function createComponents(this)
            this.createFigureAndMainGrid();
            this.createSubViews();
            if isempty(this.ProgressDialog)
                set(this.BasicFitFigure,...
                'Visible','on',...
                'Position',this.getDialogPosition());
            end
        end

        function createFigureAndMainGrid(this)
            if isempty(this.FigureDataManager.PlotToolsAppFigure)||...
                ~isvalid(this.FigureDataManager.PlotToolsAppFigure)||...
                (~isempty(this.FigureDataManager.PlotToolsAppFigure)&&...
                strcmpi(get(this.FigureDataManager.PlotToolsAppFigure,'Visible'),'on'))
                this.BasicFitFigure=this.FigureDataManager.getWarmedUpFigure();
                set(this.BasicFitFigure,...
                'Visible','on',...
                'Position',this.getDialogPosition(),...
                'AutoResizeChildren','on',...
                'CloseRequestFcn',@(e,d)this.close());
                this.ProgressDialog=uiprogressdlg(this.BasicFitFigure,'Title',getString(message('MATLAB:datamanager:basicfit:ProgressLabel')),...
                'Message',getString(message('MATLAB:datamanager:basicfit:InitialLabel')),...
                'ShowPercentage','on');
            else
                this.BasicFitFigure=this.FigureDataManager.getWarmedUpFigure();
                set(this.BasicFitFigure,'Position',this.getDialogPosition(),...
                'AutoResizeChildren','on',...
                'CloseRequestFcn',@(e,d)this.close());
            end



            dialogName=getString(message('MATLAB:datamanager:basicfit:FigureName'));
            figureNum=this.ParentFigure.Number;
            if isempty(figureNum)
                figureNum="";
            end
            if~isempty(this.ParentFigure.Name)
                this.BasicFitFigure.Name="Figure "+figureNum+" "+this.ParentFigure.Name+": "+dialogName;
            else
                this.BasicFitFigure.Name="Figure "+figureNum+": "+dialogName;
            end


            mainGridLayout=uigridlayout(this.BasicFitFigure,'Padding',[10,0,0,10]);
            mainGridLayout.ColumnWidth={'1x'};
            mainGridLayout.RowHeight={'fit','1x'};

            this.createSelectDataView(mainGridLayout);


            mainAccordion=matlab.ui.container.internal.Accordion('Parent',mainGridLayout);
            mainAccordion.Layout.Row=2;
            mainAccordion.Layout.Column=1;

            this.TypesOfFitPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:basicfit:FitTypes')));

            this.FitResultsPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:basicfit:Results')),...
            'Collapsed',true);

            this.ResidualsPanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:basicfit:Residuals')),...
            'Collapsed',true);

            this.EvaluatePanel=matlab.ui.container.internal.AccordionPanel('Parent',mainAccordion,...
            'Title',getString(message('MATLAB:datamanager:basicfit:Evaluate')),...
            'Collapsed',true);
        end

        function createSubViews(this)
            this.createFitTypesView();
            this.createFitResultsView();
            this.createResidualsView();
            this.createEvaluationView();
        end

        function createSelectDataView(this,mainGrid)
            dataGridLayout=uigridlayout(mainGrid,'Padding',[0,0,10,0]);
            dataGridLayout.RowSpacing=this.FIXED_SPACING;
            dataGridLayout.ColumnSpacing=this.FIXED_SPACING;
            dataGridLayout.ColumnWidth={'fit','1x',this.ICON_SIZE,'fit'};
            dataGridLayout.RowHeight={this.ROW_HEIGHT};
            dataGridLayout.Layout.Row=1;
            dataGridLayout.Layout.Column=1;


            dataDropDownLabel=uilabel(dataGridLayout,...
            'Text',strcat(getString(message('MATLAB:datamanager:basicfit:DropDownLabel')),':'),...
            'Tooltip',getString(message('MATLAB:datamanager:basicfit:DropDownLabel')));
            dataDropDownLabel.Layout.Row=1;
            dataDropDownLabel.Layout.Column=1;


            this.SelectDataDropDown=uidropdown(dataGridLayout,...
            'ValueChangedFcn',@(e,d)this.dropDownSelectionChanged(d));
            this.SelectDataDropDown.Layout.Row=1;
            this.SelectDataDropDown.Layout.Column=2;


            this.HelpImage=uiimage(dataGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:HelpLabel'))},...
            'ImageSource',fullfile('toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','help.png'),...
            'ImageClickedFcn',@(e,d)this.BasicFitManager.openHelpPage());

            this.HelpImage.Layout.Row=1;
            this.HelpImage.Layout.Column=3;


            this.NormalizeXCheckBox=uicheckbox(dataGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:NormalizeXTooltip'))},...
            'Text',getString(message('MATLAB:datamanager:basicfit:NormalizeXData')),...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.normalizeXData(d.Value,this.CurrentObject));

            this.NormalizeXCheckBox.Layout.Row=1;
            this.NormalizeXCheckBox.Layout.Column=4;
        end

        function createFitTypesView(this)
            if~isempty(this.ProgressDialog)&&isvalid(this.ProgressDialog)
                this.ProgressDialog.Value=.33;
                this.ProgressDialog.Message=getString(message('MATLAB:datamanager:basicfit:LoadLabel'));
            end

            dataGridLayout=uigridlayout(this.TypesOfFitPanel,'Padding',this.PADDING);
            dataGridLayout.ColumnWidth={'1x'};
            dataGridLayout.RowHeight={this.FITTYPE_PANEL_HEIGHT};
            dataGridLayout.RowSpacing=this.FIXED_SPACING;
            dataGridLayout.ColumnSpacing=this.FIXED_SPACING;


            fitPanel=uipanel(dataGridLayout,...
            'BorderType','line',...
            'Scrollable','off');
            fitPanel.Layout.Row=1;
            fitPanel.Layout.Column=1;

            fitTypeGridLayout=uigridlayout(fitPanel,'Padding',[this.FIXED_SPACING,this.FIXED_SPACING,0,0],'Scrollable','on');
            fitTypeGridLayout.ColumnWidth={'fit',this.ICON_SIZE,'fit','1x','fit',this.ICON_SIZE,'fit','1x'};
            fitTypeGridLayout.RowHeight={this.ROW_HEIGHT,this.ROW_HEIGHT,this.ROW_HEIGHT,this.ROW_HEIGHT,this.ROW_HEIGHT,this.ROW_HEIGHT};
            fitTypeGridLayout.RowSpacing=0;
            fitTypeGridLayout.ColumnSpacing=this.FIXED_SPACING;

            this.LinearCheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(3),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.LinearCheckBox.Layout.Row=1;
            this.LinearCheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','linear.png'));
            ui_image.Layout.Row=1;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:LinearFit')));
            checkboxLabel.Layout.Row=1;
            checkboxLabel.Layout.Column=3;

            this.QuadraticCheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(4),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.QuadraticCheckBox.Layout.Row=1;
            this.QuadraticCheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','quadratic.png'));
            ui_image.Layout.Row=1;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:QuadraticFit')));
            checkboxLabel.Layout.Row=1;
            checkboxLabel.Layout.Column=7;

            this.CubicCheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(5),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.CubicCheckBox.Layout.Row=2;
            this.CubicCheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','cubic.png'));
            ui_image.Layout.Row=2;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:CubicFit')));
            checkboxLabel.Layout.Row=2;
            checkboxLabel.Layout.Column=3;

            this.SplineinterpolantCheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(1),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.SplineinterpolantCheckBox.Layout.Row=2;
            this.SplineinterpolantCheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','spline.png'));
            ui_image.Layout.Row=2;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:SplineFit')));
            checkboxLabel.Layout.Row=2;
            checkboxLabel.Layout.Column=7;

            this.Degree4CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(6),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree4CheckBox.Layout.Row=3;
            this.Degree4CheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=3;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree4Fit')));
            checkboxLabel.Layout.Row=3;
            checkboxLabel.Layout.Column=3;

            this.Degree5CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(7),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree5CheckBox.Layout.Row=3;
            this.Degree5CheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=3;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree5Fit')));
            checkboxLabel.Layout.Row=3;
            checkboxLabel.Layout.Column=7;

            this.Degree6CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(8),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree6CheckBox.Layout.Row=4;
            this.Degree6CheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=4;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree6Fit')));
            checkboxLabel.Layout.Row=4;
            checkboxLabel.Layout.Column=3;

            this.Degree7CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(9),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree7CheckBox.Layout.Row=4;
            this.Degree7CheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=4;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree7Fit')));
            checkboxLabel.Layout.Row=4;
            checkboxLabel.Layout.Column=7;

            this.Degree8CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(10),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree8CheckBox.Layout.Row=5;
            this.Degree8CheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=5;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree8Fit')));
            checkboxLabel.Layout.Row=5;
            checkboxLabel.Layout.Column=3;

            this.Degree9CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(11),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree9CheckBox.Layout.Row=5;
            this.Degree9CheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=5;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree9Fit')));
            checkboxLabel.Layout.Row=5;
            checkboxLabel.Layout.Column=7;

            this.Degree10CheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(12),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.Degree10CheckBox.Layout.Row=6;
            this.Degree10CheckBox.Layout.Column=1;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','polynomial.png'));
            ui_image.Layout.Row=6;
            ui_image.Layout.Column=2;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:Degree10Fit')));
            checkboxLabel.Layout.Row=6;
            checkboxLabel.Layout.Column=3;

            this.ShapePreservingCheckBox=uicheckbox(fitTypeGridLayout,...
            'Text','',...
            'Tag',this.FIT_TYPES(2),...
            'ValueChangedFcn',@(e,d)this.updateFitResultsPanel(d.Source.Tag,d.Value));
            this.ShapePreservingCheckBox.Layout.Row=6;
            this.ShapePreservingCheckBox.Layout.Column=5;

            ui_image=uiimage(fitTypeGridLayout,...
            'ImageSource',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','shape.png'));
            ui_image.Layout.Row=6;
            ui_image.Layout.Column=6;

            checkboxLabel=uilabel(fitTypeGridLayout,...
            'Text',getString(message('MATLAB:datamanager:basicfit:ShapeFit')));
            checkboxLabel.Layout.Row=6;
            checkboxLabel.Layout.Column=7;

            this.setFitTypesCheckboxGroup();
        end


        function setFitTypesCheckboxGroup(this)
            this.FitTypesCheckboxGroup=[this.SplineinterpolantCheckBox,...
            this.ShapePreservingCheckBox,this.LinearCheckBox,...
            this.QuadraticCheckBox,this.CubicCheckBox,this.Degree4CheckBox,...
            this.Degree5CheckBox,this.Degree6CheckBox,this.Degree7CheckBox,...
            this.Degree8CheckBox,this.Degree9CheckBox,this.Degree10CheckBox];
        end

        function createFitResultsView(this)
            resultsGridLayout=uigridlayout(this.FitResultsPanel,'Padding',this.PADDING);
            resultsGridLayout.ColumnWidth={'1x'};
            resultsGridLayout.RowHeight={'fit',this.RESULT_PANEL_HEIGHT,'fit'};
            resultsGridLayout.RowSpacing=this.FIXED_SPACING;
            resultsGridLayout.ColumnSpacing=this.FIXED_SPACING;

            signDigitsGridLayout=uigridlayout(resultsGridLayout,'Padding',this.NOPADDING);
            signDigitsGridLayout.ColumnWidth={'fit','fit'};
            signDigitsGridLayout.RowHeight={'fit'};
            signDigitsGridLayout.Layout.Row=1;
            signDigitsGridLayout.RowSpacing=this.FIXED_SPACING;
            signDigitsGridLayout.ColumnSpacing=this.FIXED_SPACING;


            uilabel(signDigitsGridLayout,...
            'HorizontalAlignment','left',...
            'Text',strcat(getString(message('MATLAB:datamanager:basicfit:Digits')),':'));


            this.SignificantDigitsDropDown=uidropdown(signDigitsGridLayout,...
            'Items',{'2','3','4','5','6','7','8','9','10'},...
            'Editable','off',...
            'Enable','on',...
            'Value','4',...
            'ValueChangedFcn',@(e,d)this.significantDigitsChanged(d));


            this.ResultsTabGroup=uitabgroup(resultsGridLayout,...
            'SelectionChangedFcn',@(e,d)this.selectedTabChanged(d.NewValue));
            this.ResultsTabGroup.Layout.Row=2;

            fitResultsTab=uitab(this.ResultsTabGroup,...
            'Title','',...
            'ForegroundColor',[0.3725,0.3765,0.3804],...
            'Tag','');

            this.ResultTabGridLayout=uigridlayout(fitResultsTab,...
            'Padding',[2*this.FIXED_SPACING,2*this.FIXED_SPACING,this.FIXED_SPACING,this.FIXED_SPACING],...
            'Scrollable','on');
            this.ResultTabGridLayout.ColumnWidth={'fit','fit'};
            this.ResultTabGridLayout.RowHeight={'fit','fit','fit'};
            this.ResultTabGridLayout.RowSpacing=this.FIXED_SPACING;
            this.ResultTabGridLayout.ColumnSpacing=this.FIXED_SPACING;


            this.ShowEquationCheckBox=uicheckbox(this.ResultTabGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:ShowEquationTooltip'))},...
            'Text',getString(message('MATLAB:datamanager:basicfit:Equation')),...
            'Value',1,...
            'Enable','off',...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.showEquationCallback...
            (d.Value,...
            this.SignificantDigitsDropDown.Value,this.CurrentObject,this.getCurrentFitIndex()));
            this.ShowEquationCheckBox.Layout.Row=1;
            this.ShowEquationCheckBox.Layout.Column=1;

            this.EquationLabel=uilabel(this.ResultTabGridLayout,'Interpreter','latex','Text','');
            this.EquationLabel.Layout.Row=1;
            this.EquationLabel.Layout.Column=2;


            this.ShowRCheckBox=uicheckbox(this.ResultTabGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:ShowR2Tooltip'))},...
            'Text',sprintf(strrep('R\u00B2','\u','\x')),...
            'Value',0,...
            'Enable','off',...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.showR2Callback(...
            d.Value,this.SignificantDigitsDropDown.Value,...
            this.CurrentObject,this.getCurrentFitIndex()));
            this.ShowRCheckBox.Layout.Row=2;
            this.ShowRCheckBox.Layout.Column=1;

            this.R2Label=uilabel(this.ResultTabGridLayout,'Interpreter','latex','Text','');
            this.R2Label.Layout.Row=2;
            this.R2Label.Layout.Column=2;


            this.ShowNormCheckBox=uicheckbox(this.ResultTabGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:NormOfResidualsTooltip'))},...
            'Text',getString(message('MATLAB:datamanager:basicfit:NormOfResidualsLabel')),...
            'Value',0,...
            'Enable','off',...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.showRMSECallback...
            (d.Value,this.SignificantDigitsDropDown.Value,this.CurrentObject,this.getCurrentFitIndex()));
            this.ShowNormCheckBox.Layout.Row=3;
            this.ShowNormCheckBox.Layout.Column=1;

            this.NormLabel=uilabel(this.ResultTabGridLayout,'Interpreter','latex','Text','');
            this.NormLabel.Layout.Row=3;
            this.NormLabel.Layout.Column=2;


            resultsButtonsGrid=uigridlayout(resultsGridLayout);
            resultsButtonsGrid.ColumnWidth={'1x','fit','fit'};
            resultsButtonsGrid.RowHeight={'fit'};
            resultsButtonsGrid.Padding=0;
            resultsButtonsGrid.ColumnSpacing=this.FIXED_SPACING;
            resultsButtonsGrid.Layout.Row=3;
            resultsButtonsGrid.Layout.Column=1;


            this.MoreResultsButton=uibutton(resultsButtonsGrid,'push',...
            'Icon',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','expand.png'),...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:expandResults'))},...
            'Text','',...
            'Tag','Expand Results',...
            'ButtonPushedFcn',@(e,d)this.showMoreResultsDialog());
            this.MoreResultsButton.Layout.Row=1;
            this.MoreResultsButton.Layout.Column=2;


            this.ExportResultsButton=uibutton(resultsButtonsGrid,'push',...
            'Icon',fullfile(...
            'toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','export.png'),...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:ExportResultsToWorkspace'))},...
            'Text','',...
            'Tag','Export Results',...
            'ButtonPushedFcn',...
            @(e,d)this.BasicFitManager.exportResultsToWorkspace(this.CurrentObject,this.getCurrentFitIndex()));
            this.ExportResultsButton.Layout.Row=1;
            this.ExportResultsButton.Layout.Column=3;
        end

        function createResidualsView(this)
            resultsGridLayout=uigridlayout(this.ResidualsPanel,'Padding',[this.FIXED_SPACING,this.FIXED_SPACING,2*this.FIXED_SPACING,2*this.FIXED_SPACING]);
            resultsGridLayout.ColumnWidth={'fit','1x','fit'};
            resultsGridLayout.RowHeight={'fit','fit'};
            resultsGridLayout.RowSpacing=this.FIXED_SPACING;
            resultsGridLayout.ColumnSpacing=this.FIXED_SPACING;


            plotStyleDropDownLabel=uilabel(resultsGridLayout,...
            'Tooltip',getString(message('MATLAB:datamanager:basicfit:PlotStyleLabel')),...
            'Text',strcat(getString(message('MATLAB:datamanager:basicfit:PlotStyleLabel')),':'));
            plotStyleDropDownLabel.Layout.Row=1;
            plotStyleDropDownLabel.Layout.Column=1;


            this.PlotStyleDropDown=uidropdown(resultsGridLayout,...
            'Items',{getString(message('MATLAB:datamanager:basicfit:noneVal')),...
            getString(message('MATLAB:datamanager:basicfit:barVal')),...
            getString(message('MATLAB:datamanager:basicfit:scatterVal')),...
            getString(message('MATLAB:datamanager:basicfit:lineVal'))},...
            'Value',getString(message('MATLAB:datamanager:basicfit:noneVal')),...
            'ValueChangedFcn',@(e,d)this.reComputeResiduals());
            this.PlotStyleDropDown.Layout.Row=1;
            this.PlotStyleDropDown.Layout.Column=2;


            this.ShowNormResidCheckBox=uicheckbox(resultsGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:NormOfResidualsTooltip'))},...
            'Text',getString(message('MATLAB:datamanager:basicfit:NormOfResidualsLabel')),...
            'Value',1,...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.displayNormOfResiduals(...
            d.Value,this.CurrentObject),...
            'Enable','off');
            this.ShowNormResidCheckBox.Layout.Row=1;
            this.ShowNormResidCheckBox.Layout.Column=3;


            plotLocationDropDownLabel=uilabel(resultsGridLayout,...
            'Tooltip',getString(message('MATLAB:datamanager:basicfit:PlotLocationLabel')),...
            'Text',strcat(getString(message('MATLAB:datamanager:basicfit:PlotLocationLabel')),':'));
            plotLocationDropDownLabel.Layout.Row=2;
            plotLocationDropDownLabel.Layout.Column=1;


            this.PlotLocationDropDown=uidropdown(resultsGridLayout,...
            'Items',{getString(message('MATLAB:datamanager:basicfit:subplotVal')),...
            getString(message('MATLAB:datamanager:basicfit:newFigureVal'))},...
            'Value',getString(message('MATLAB:datamanager:basicfit:subplotVal')),...
            'ValueChangedFcn',@(e,d)this.reComputeResiduals(),...
            'Enable','off');
            this.PlotLocationDropDown.Layout.Row=2;
            this.PlotLocationDropDown.Layout.Column=2;
        end

        function createEvaluationView(this)
            evaluateGridLayout=uigridlayout(this.EvaluatePanel,'Padding',[this.FIXED_SPACING,this.FIXED_SPACING,2*this.FIXED_SPACING,2*this.FIXED_SPACING]);
            evaluateGridLayout.ColumnWidth={'1x'};
            evaluateGridLayout.RowHeight={'fit','fit'};
            evaluateGridLayout.RowSpacing=this.FIXED_SPACING;
            evaluateGridLayout.ColumnSpacing=0;

            evaluateDataGridLayout=uigridlayout(evaluateGridLayout,'Padding',this.NOPADDING);
            evaluateDataGridLayout.ColumnWidth={'fit','1x',this.ROW_HEIGHT,'fit'};
            evaluateDataGridLayout.RowHeight={'fit'};
            evaluateDataGridLayout.Layout.Row=1;
            evaluateDataGridLayout.Layout.Column=1;
            evaluateDataGridLayout.RowSpacing=0;
            evaluateDataGridLayout.ColumnSpacing=this.FIXED_SPACING;

            xLabel=uilabel(evaluateDataGridLayout,...
            'Text',[getString(message('MATLAB:datamanager:basicfit:XData')),' = ']);
            xLabel.Layout.Row=1;
            xLabel.Layout.Column=1;

            this.EnterDataField=uieditfield(evaluateDataGridLayout,'text',...
            'Placeholder',getString(message('MATLAB:datamanager:basicfit:NewDataFieldTooltip')),...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:NewDataFieldTooltip'))},...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.evaluateAndDisplayNewData(...
            d.Value,this.PlotDataCheckBox.Value,this.CurrentObject,this.getCurrentFitIndex()));
            this.EnterDataField.Layout.Row=1;
            this.EnterDataField.Layout.Column=2;


            this.ExportEvaluationButton=uibutton(evaluateDataGridLayout,...
            'Text','',...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:ExportEvaluationToWorkspace'))},...
            'Icon',fullfile('toolbox','matlab','datamanager','+datamanager','+basicfit','+icons','export.png'),...
            'ButtonPushedFcn',@(e,d)this.BasicFitManager.exportEvaluatedDataToWorkspace(this.CurrentObject));
            this.ExportEvaluationButton.Layout.Row=1;
            this.ExportEvaluationButton.Layout.Column=3;


            this.PlotDataCheckBox=uicheckbox(evaluateDataGridLayout,...
            'Tooltip',{getString(message('MATLAB:datamanager:basicfit:PlotDataCheckboxTooltip'))},...
            'Text',getString(message('MATLAB:datamanager:basicfit:PlotDataCheckboxLabel')),...
            'Value',1,...
            'ValueChangedFcn',@(e,d)this.BasicFitManager.evaluateAndDisplayNewData(...
            this.EnterDataField.Value,d.Value,this.CurrentObject,this.getCurrentFitIndex()));
            this.PlotDataCheckBox.Layout.Row=1;
            this.PlotDataCheckBox.Layout.Column=4;

            evaluateTableGridLayout=uigridlayout(evaluateGridLayout,'Padding',this.NOPADDING);
            evaluateTableGridLayout.ColumnWidth={'1x'};
            evaluateTableGridLayout.RowHeight={'1x'};
            evaluateTableGridLayout.Layout.Row=2;
            evaluateTableGridLayout.Layout.Column=1;
            evaluateTableGridLayout.RowSpacing=0;
            evaluateTableGridLayout.ColumnSpacing=this.FIXED_SPACING;

            this.EvaluationTable=uitable(evaluateTableGridLayout,...
            'ColumnName',{'X';'Y'},...
            'ColumnEditable',[false,false],...
            'RowStriping','off',...
            'Enable','off',...
            'Visible','off');
            this.EvaluationTable.Layout.Row=1;
            this.EvaluationTable.Layout.Column=1;
        end






        function setDependentViewState(this,state)
            set([this.ExportEvaluationButton,...
            this.ExportResultsButton,...
            this.EnterDataField,...
            this.PlotStyleDropDown,...
            this.PlotDataCheckBox,...
            this.SignificantDigitsDropDown,...
            this.ShowEquationCheckBox,...
            this.ShowRCheckBox,...
            this.ShowNormCheckBox],...
            'Enable',state);

            if strcmpi(state,'off')
                this.MoreResultsButton.Enable=state;
                this.collapsePanels();
            end

            set([this.EquationLabel,...
            this.R2Label,...
            this.NormLabel],...
            'Visible',state);
        end




        function collapsePanels(this)
            this.FitResultsPanel.Collapsed=true;
            this.ResidualsPanel.Collapsed=true;
            this.EvaluatePanel.Collapsed=true;
        end


        function fitIndex=getCurrentFitIndex(this)



            fitIndex=find(strcmpi(this.FIT_TYPES,this.ResultsTabGroup.SelectedTab.Tag))-1;
        end



        function updateView(this,dataObjs,dispNames,selectedFits,viewState,evaluatedData,results)

            if~isempty(this.ProgressDialog)&&isvalid(this.ProgressDialog)
                this.ProgressDialog.Value=.98;
                this.ProgressDialog.Message=getString(message('MATLAB:datamanager:basicfit:FinishLabel'));
                drawnow;
            end

            this.DataObjectHandles=dataObjs;



            if isempty(dataObjs)
                this.setFitTypeCheckBoxState('off');
            else
                this.setFitTypeCheckBoxState('on');
            end

            this.updateDataSelectionDropDown(dispNames);
            this.setDependentViewState(any(selectedFits));

            this.populateData(viewState,evaluatedData);

            this.updateFitSelectionAndResults(selectedFits,results);
            if~isempty(this.ProgressDialog)&&isvalid(this.ProgressDialog)
                delete(this.ProgressDialog);
            end
            internal.matlab.datatoolsservices.executeCmd('datamanager.FigureDataManager.warmUpFigure()');
        end














        function populateData(this,viewState,evaluatedData)
            if isempty(viewState)
                return;
            end
            this.SignificantDigitsDropDown.Value=num2str(viewState(3));
            this.NormalizeXCheckBox.Value=viewState(1);
            if viewState(4)

                this.PlotStyleDropDown.Value=this.RESIDUALS_PLOT_STYLES(viewState(5)+1);
                this.PlotLocationDropDown.Value=this.RESIDUALS_PLOT_LOCATION(viewState(6)+1);
            else
                this.PlotStyleDropDown.Value=getString(message(strcat('MATLAB:datamanager:basicfit:noneVal')));
            end
            this.updateResidualsPlotStyle();

            this.ShowNormResidCheckBox.Value=viewState(7);
            this.PlotDataCheckBox.Value=viewState(8);
            if~strcmpi(evaluatedData,' ')
                this.EnterDataField.Value=evaluatedData;
            end
        end




        function updateDataSelectionDropDown(this,displayNames)
            this.SelectDataDropDown.Items=displayNames;
            this.SelectDataDropDown.ItemsData=this.DataObjectHandles;
            if isempty(this.DataObjectHandles)
                this.CurrentObject=[];
            else
                this.CurrentObject=this.DataObjectHandles{1};
            end
        end







        function createFitResultsTab(this,fitType)




            if contains(fitType,'degree')
                fitNum=split(fitType);
                tabTitle=getString(message('MATLAB:datamanager:basicfit:ntab',fitNum(1)));
            else
                tabTitle=getString(message(strcat('MATLAB:datamanager:basicfit:',lower(fitType),'tab')));
            end
            if isempty(this.DisplayedFitResults)
                fitResultsTab=this.ResultsTabGroup.Children(1);
                set(fitResultsTab,'Title',tabTitle,'Tag',fitType);
                this.DisplayedFitResults=fitType;
            else
                fitResultsIndex=find(strcmpi(this.DisplayedFitResults,fitType));
                if~isempty(fitResultsIndex)
                    fitResultsTab=this.ResultsTabGroup.Children(fitResultsIndex);
                    this.ResultTabGridLayout.Parent=fitResultsTab;
                else
                    fitResultsTab=uitab(this.ResultsTabGroup,...
                    'Title',tabTitle,...
                    'ForegroundColor',[0.3725,0.3765,0.3804],...
                    'Tag',fitType);
                    this.ResultTabGridLayout.Parent=fitResultsTab;
                    this.ShowEquationCheckBox.Value=1;
                    this.ShowRCheckBox.Value=0;
                    this.ShowNormCheckBox.Value=0;


                    this.DisplayedFitResults(end+1)=fitType;
                end


                this.ResultsTabGroup.SelectedTab=fitResultsTab;
            end
        end




        function updateFitSelectionAndResults(this,selectedFits,results)
            fitsSelectionState=false(this.NUM_OF_FITS,1);
            if~isempty(selectedFits)
                fitsSelectionState=selectedFits;
            end
            this.FitResults=[];
            for i=1:this.NUM_OF_FITS

                this.FitTypesCheckboxGroup(i).Value=double(fitsSelectionState(i));
                fitName=string(this.FitTypesCheckboxGroup(i).Tag);
                this.FitResults{i}=results{i};
                if fitsSelectionState(i)
                    this.FitResultsPanel.Collapsed=false;
                    this.createFitResultsTab(fitName);
                    fitResult=results{i};
                    this.updateFitResults(fitResult);
                    this.setDependentViewState('on');
                else
                    fitResultsIndex=find(strcmpi(this.DisplayedFitResults,fitName));
                    if~isempty(fitResultsIndex)&&numel(this.ResultsTabGroup.Children)>1
                        resultsTab=this.ResultsTabGroup.Children(fitResultsIndex);%#ok<*FNDSB>
                        tabChild=resultsTab.Children;
                        resultsTab.Parent=[];





                        if~isempty(tabChild)
                            tabChild.Parent=this.ResultsTabGroup.SelectedTab;
                        end
                        delete(resultsTab);
                    end
                    this.DisplayedFitResults(fitResultsIndex)=[];
                end
            end


            if~this.FitResultsPanel.Collapsed&&isempty(this.DisplayedFitResults)
                this.setDependentViewState('off');
                this.ResultsTabGroup.SelectedTab.Title='';
                this.ResultsTabGroup.SelectedTab.Tag='';
                this.FitResultsPanel.Collapsed=true;
            end
        end





        function updateFitResultsPanel(this,fitName,isSelected)

            fitName=string(fitName);
            if isSelected


                this.FitResultsPanel.Collapsed=false;
                this.createFitResultsTab(fitName);
                results=this.computeFitResults(fitName,isSelected);
                this.updateFitResults(results);
                this.setDependentViewState('on');
            else

                this.computeFitResults(fitName,isSelected);
                fitResultsIndex=find(strcmpi(this.DisplayedFitResults,fitName));
                if~isempty(fitResultsIndex)&&numel(this.ResultsTabGroup.Children)>1
                    resultsTab=this.ResultsTabGroup.Children(fitResultsIndex);%#ok<*FNDSB>
                    tabChild=resultsTab.Children;
                    resultsTab.Parent=[];





                    if~isempty(tabChild)
                        tabChild.Parent=this.ResultsTabGroup.SelectedTab;
                        fitIndex=this.getCurrentFitIndex()+1;
                        this.updateFitResults(this.FitResults{fitIndex});
                    end
                    delete(resultsTab);
                end
                this.DisplayedFitResults(fitResultsIndex)=[];
            end



            if~this.FitResultsPanel.Collapsed&&isempty(this.DisplayedFitResults)
                this.setDependentViewState('off');
                this.ResultsTabGroup.SelectedTab.Title='';
                this.ResultsTabGroup.SelectedTab.Tag='';
                this.FitResultsPanel.Collapsed=true;
            end
        end

        function results=computeFitResults(this,fitName,isSelected)
            fitIndex=find(this.FIT_TYPES==fitName);
            residualType=find(strcmpi(this.RESIDUALS_PLOT_STYLES,this.PlotStyleDropDown.Value))-1;
            if isempty(residualType)
                residualType=-1;
            end
            viewState=struct("SelectedFit",isSelected,...
            "isEquationOn",1,...
            "CurrentFitIndex",fitIndex-1,...
            "DataObjects",this.CurrentObject,...
            "sigDigits",str2double(this.SignificantDigitsDropDown.Value),...
            "showResiduals",~strcmpi(this.PlotStyleDropDown.Value,getString(message('MATLAB:datamanager:basicfit:noneVal'))),...
            "ResidPlotType",residualType,...
            "IsSubplotLocation",strcmpi(this.PlotLocationDropDown.Value,getString(message('MATLAB:datamanager:basicfit:subplotVal'))),...
            "showRMSE",this.ShowNormResidCheckBox.Value);
            results=this.BasicFitManager.getFitResults(viewState);
            this.FitResults{fitIndex}=strtrim(results);
        end

        function updateResultsCheckboxState(this)
            resultsState=getappdata(this.getCurrentObject(),"Basic_Fit_Results_State");
            fitIndex=this.getCurrentFitIndex()+1;
            this.ShowEquationCheckBox.Value=double(resultsState.showEquations(fitIndex));
            this.ShowRCheckBox.Value=double(resultsState.showR2(fitIndex));
            this.ShowNormCheckBox.Value=double(resultsState.showRMSE(fitIndex));
        end



        function updateFitResults(this,fitResults)

            this.updateResultsCheckboxState();

            if strcmpi(this.ResultsTabGroup.SelectedTab.Tag,'Spline')||strcmpi(this.ResultsTabGroup.SelectedTab.Tag,'Shape')
                this.EquationLabel.Text='';
                this.NormLabel.Text='';
                this.R2Label.Text=['        ',getString(message('MATLAB:datamanager:basicfit:NoResultsFound'))];
                this.R2Label.Interpreter='none';
                this.R2Label.FontAngle='italic';
                this.R2Label.FontColor=[0.6510,0.6510,0.6510];
                this.MoreResultsButton.Enable='off';
                return;
            end
            equation=fitResults(1);
            this.EquationLabel.Text=sprintf("$%s$",equation);
            this.R2Label.Text=sprintf('$%s$',fitResults(2));
            this.R2Label.Interpreter='latex';
            this.R2Label.FontColor=[0,0,0];
            this.R2Label.FontAngle='normal';
            this.NormLabel.Text=sprintf('$%s$',fitResults(3));
            this.MoreResultsButton.Enable='on';
        end


        function currentObj=getCurrentObject(this)
            dropDown=this.SelectDataDropDown;
            currentObj=[];
            if~isempty(dropDown.ItemsData)
                objIndex=find(cellfun(@(x)isequal(x,dropDown.Value),dropDown.ItemsData));
                currentObj=this.DataObjectHandles{objIndex};
            end
        end

        function updateResidualsPlotStyle(this)


            residualsPlotStyle=this.PlotStyleDropDown.Value;
            if strcmpi(residualsPlotStyle,'none')
                this.PlotLocationDropDown.Enable='off';
                this.ShowNormResidCheckBox.Enable='off';
            else
                this.PlotLocationDropDown.Enable='on';
                this.ShowNormResidCheckBox.Enable='on';
            end
        end

        function reComputeResiduals(this)
            doShowResiduals=1;
            residualsPlotStyle=this.PlotStyleDropDown.Value;
            this.updateResidualsPlotStyle();
            if strcmpi(residualsPlotStyle,getString(message('MATLAB:datamanager:basicfit:noneVal')))
                doShowResiduals=0;
            end
            residualPlotStyle=find(strcmpi(this.RESIDUALS_PLOT_STYLES,residualsPlotStyle))-1;
            residualPlotLocation=strcmpi(this.PlotLocationDropDown.Value,getString(message('MATLAB:datamanager:basicfit:subplotVal')));
            showResidualsRMSE=this.ShowNormResidCheckBox.Value;
            this.BasicFitManager.reComputeAndShowResiduals(this.CurrentObject,...
            doShowResiduals,residualPlotStyle,residualPlotLocation,showResidualsRMSE);
        end



        function significantDigitsChanged(this,eventData)
            sigDigits=str2double(eventData.Value);
            currentObject=this.CurrentObject;
            guistate=getappdata(currentObject,'Basic_Fit_Gui_State');
            guistate.digits=sigDigits;
            setappdata(currentObject,'Basic_Fit_Gui_State',guistate);
            this.BasicFitManager.normalizeXData(this.NormalizeXCheckBox.Value,...
            this.getCurrentObject);
        end


        function dropDownSelectionChanged(this,d)
            set(this.BasicFitFigure,'Pointer','watch');

            drawnow nocallbacks;
            this.CurrentObject=d.Value;
            this.BasicFitManager.dropDownSelectionChanged(this.CurrentObject);
            set(this.BasicFitFigure,'Pointer','arrow');
        end


        function selectedTabChanged(this,selectedTab)
            this.ResultTabGridLayout.Parent=selectedTab;
            fitIndex=this.getCurrentFitIndex()+1;
            this.updateFitResults(this.FitResults{fitIndex});
        end

        function updateTabularView(this,data)
            this.EvaluationTable.Data=data;
            this.EvaluationTable.Visible='on';
            this.EvaluationTable.Enable='on';
        end

        function doShowOnChart=doShowResultsOnChart(this)
            doShowOnChart=this.ShowEquationCheckBox.Value||...
            this.ShowRCheckBox.Value||this.ShowNormCheckBox.Value;
        end

        function showMoreResultsDialog(this)
            if~isempty(this.MoreResultsDialog)&&isvalid(this.MoreResultsDialog)
                delete(this.MoreResultsDialog)
            end
            this.MoreResultsDialog=datamanager.basicfit.expandedResultsDialog...
            (this.ResultsTabGroup.SelectedTab.Title,...
            this.getCurrentFitIndex(),...
            this.getCurrentObject(),this.BasicFitFigure);
        end


        function setFitTypeCheckBoxState(this,state)
            set([this.SelectDataDropDown,this.NormalizeXCheckBox,this.LinearCheckBox,this.QuadraticCheckBox,...
            this.CubicCheckBox,this.Degree4CheckBox,this.Degree5CheckBox,...
            this.Degree6CheckBox,this.Degree7CheckBox,this.Degree8CheckBox,...
            this.Degree9CheckBox,this.Degree10CheckBox,this.ShapePreservingCheckBox,...
            this.SplineinterpolantCheckBox],'Enable',state);
        end
    end
end
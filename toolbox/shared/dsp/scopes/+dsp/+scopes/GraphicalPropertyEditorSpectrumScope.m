classdef GraphicalPropertyEditorSpectrumScope<uiservices.GraphicalPropertyEditor















    methods
        function this=GraphicalPropertyEditorSpectrumScope(varargin)
            this@uiservices.GraphicalPropertyEditor(varargin{:});
        end

        function initialize(this,ip)



            viewType=[];
            if isfield(ip,'ViewType')
                viewType=ip.ViewType;
                ip=rmfield(ip,'ViewType');
            end

            normalTraceFlag=true;
            if isfield(ip,'NormalTraceFlag')
                normalTraceFlag=ip.NormalTraceFlag;
                ip=rmfield(ip,'NormalTraceFlag');
            end

            initialize@uiservices.GraphicalPropertyEditor(this,ip);

            if~isempty(viewType)
                updateLineWidgets(this,viewType,normalTraceFlag);
            end
        end
    end

    methods(Access=protected)

        function create(this,ip,okCallback,applyCallback,...
            displaySelectedCallback,closeCallback)

            viewType=[];
            if isfield(ip,'ViewType')
                viewType=ip.ViewType;
                ip=rmfield(ip,'ViewType');
            end

            normalTraceFlag=true;
            if isfield(ip,'NormalTraceFlag')
                normalTraceFlag=ip.NormalTraceFlag;
                ip=rmfield(ip,'NormalTraceFlag');
            end


            create@uiservices.GraphicalPropertyEditor(this,ip,okCallback,...
            applyCallback,displaySelectedCallback,closeCallback);


            this.Widgets.DisplaySelectorLabel.Visible='off';
            this.Widgets.DisplaySelector.Enable=false;
            this.Widgets.DisplaySelector.Visible='off';
            if~matlabshared.scopes.useWebFigure()&&~this.UseNewStyleDialog

                pf=uiservices.getPixelFactor;
                shortVerticalOffset=10*pf;
                offFactor=this.Widgets.DisplaySelectorLabel.Position(4)+shortVerticalOffset;


                editDlgPos=get(this.EditorDialog,'Position');
                newPos=[editDlgPos(1),editDlgPos(2),editDlgPos(3),editDlgPos(4)-offFactor];
                set(this.EditorDialog,'Position',newPos);


                this.Widgets.FigureColorLabel.Position(2)=this.Widgets.FigureColorLabel.Position(2)-offFactor;
                this.Widgets.FigureColorPicker.Position(2)=this.Widgets.FigureColorPicker.Position(2)-offFactor;

                this.Widgets.PlotTypeLabel.Position(2)=this.Widgets.PlotTypeLabel.Position(2)-offFactor;
                this.Widgets.PlotTypeSelector.Position(2)=this.Widgets.PlotTypeSelector.Position(2)-offFactor;

                sepLinePos=get(this.Widgets.SeparatorLine2,'Position');
                newPos=[sepLinePos(1),sepLinePos(2)-offFactor,sepLinePos(3:4)];
                set(this.Widgets.SeparatorLine2,'Position',newPos);

                newAxesWidgetsBottom=newPos(2)+newPos(4)+shortVerticalOffset;
                this.Widgets.AxesColorsLabel.Position(2)=newAxesWidgetsBottom;
                this.Widgets.AxesBackgroundPicker.Position(2)=newAxesWidgetsBottom;
                this.Widgets.AxesForegroundPicker.Position(2)=newAxesWidgetsBottom;
            else
                this.Widgets.LinePropPanel.Layout.Row=1;
            end

            if~isempty(viewType)
                updateLineWidgets(this,viewType,normalTraceFlag);
            end
        end

        function updateLineWidgets(this,viewType,normalTraceFlag)



            flag=~strcmp(viewType,'Spectrogram');

            this.Widgets.LineSelectorLabel.Enable=flag;
            this.Widgets.LineSelector.Enable=flag;
            this.Widgets.LineVisibleCheckbox.Enable=flag;
            this.Widgets.LinePanel.Enable=flag;
            this.Widgets.AxesBackgroundPicker.Enable=flag;
            this.Widgets.AxesForegroundPicker.Enable=flag;
            this.Widgets.AxesColorsLabel.Enable=flag;
            this.Widgets.FigureColorLabel.Enable=flag;
            this.Widgets.FigureColorPicker.Enable=flag;
            this.Widgets.PlotTypeLabel.Enable=flag;
            this.Widgets.PlotTypeSelector.Enable=flag&&normalTraceFlag;
            this.Widgets.ApplyButton.Enable=flag;
            this.Widgets.OkButton.Enable=flag;
        end
    end
end

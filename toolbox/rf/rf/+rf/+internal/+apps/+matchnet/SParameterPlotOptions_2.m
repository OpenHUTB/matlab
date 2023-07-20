
classdef SParameterPlotOptions_2<handle





    properties(Access=public)

        myParent matlab.ui.container.Panel


        MainGrid matlab.ui.container.GridLayout


        ParametersMainGrid matlab.ui.container.GridLayout
        ParamLabel matlab.ui.control.Label
        ParamGrid matlab.ui.container.GridLayout
        S11CheckBox matlab.ui.control.CheckBox
        S12CheckBox matlab.ui.control.CheckBox
        S21CheckBox matlab.ui.control.CheckBox
        S22CheckBox matlab.ui.control.CheckBox


        FormatPanel matlab.ui.container.ButtonGroup
        MagPhaseRadioButton matlab.ui.control.RadioButton
        MagnitudeCheckBox matlab.ui.control.CheckBox
        MagnitudeFormatDropDown matlab.ui.control.DropDown
        PhaseCheckBox matlab.ui.control.CheckBox
        RealImaginaryRadioButton matlab.ui.control.RadioButton
        RealCheckBox matlab.ui.control.CheckBox
        ImaginaryCheckBox matlab.ui.control.CheckBox
    end

    properties(Access=public,Constant)
        CONTROL_HEIGHT=20
        CONTROL_HEIGHT_ADJ=30
        SUB_CONTROL_INDENT=30
    end

    events
ParameterOptionChanged
FormatOptionChanged
    end

    methods(Access=public)
        function this=SParameterPlotOptions_2(parent,currentPlotParams,currentPlotFormat)
            this.myParent=parent;

            this.initializeUI();
            this.setInitialSelections(currentPlotParams,currentPlotFormat);
            this.assignUICallbacks();
        end
    end

    methods(Access=protected)
        function initializeUI(this)

            this.myParent.AutoResizeChildren='off';
            this.MainGrid=uigridlayout(this.myParent,...
            'ColumnWidth',210,...
            'RowHeight',{'fit','1x'},...
            'Visible',matlab.lang.OnOffSwitchState.off);

            this.initializeParameterPanel();
            this.initializeFormatPanel();

            this.MainGrid.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function initializeParameterPanel(this)

            this.ParametersMainGrid=uigridlayout(this.MainGrid,...
            'ColumnWidth',{'fit'},'RowHeight',{'fit','fit'},...
            'Padding',[0,0,0,0]);

            this.ParamLabel=uilabel(this.ParametersMainGrid,'Text','Parameters');
            this.ParamLabel.Layout.Row=1;

            this.ParamGrid=uigridlayout(this.ParametersMainGrid,...
            'RowHeight',{'fit','fit'},...
            'ColumnWidth',{'fit','fit'},...
            'Padding',[this.SUB_CONTROL_INDENT,0,0,0]);
            this.ParamGrid.Layout.Row=2;


            this.S11CheckBox=uicheckbox(this.ParamGrid,'Text','S11');
            this.S11CheckBox.Layout.Row=1;
            this.S11CheckBox.Layout.Column=1;

            this.S12CheckBox=uicheckbox(this.ParamGrid,'Text','S12');
            this.S12CheckBox.Layout.Row=1;
            this.S12CheckBox.Layout.Column=2;

            this.S21CheckBox=uicheckbox(this.ParamGrid,'Text','S21');
            this.S21CheckBox.Layout.Row=2;
            this.S21CheckBox.Layout.Column=1;

            this.S22CheckBox=uicheckbox(this.ParamGrid,'Text','S22');
            this.S22CheckBox.Layout.Row=2;
            this.S22CheckBox.Layout.Column=2;
        end

        function initializeFormatPanel(this)
            this.FormatPanel=uibuttongroup(this.MainGrid,...
            'BorderType','none','Title','Format','Scrollable','on');
            this.FormatPanel.Layout.Row=2;
            this.FormatPanel.Layout.Column=1;
            this.FormatPanel.AutoResizeChildren='on';








            this.MagPhaseRadioButton=uiradiobutton(this.FormatPanel,...
            'Text','Magnitude/Phase','Position',...
            [10,this.FormatPanel.Position(4)-this.CONTROL_HEIGHT,180,this.CONTROL_HEIGHT]);

            this.MagnitudeCheckBox=uicheckbox(this.FormatPanel,...
            'Text','Magnitude','Position',...
            [this.SUB_CONTROL_INDENT,this.MagPhaseRadioButton.Position(2)-this.CONTROL_HEIGHT,75,this.CONTROL_HEIGHT]);

            this.MagnitudeFormatDropDown=uidropdown(this.FormatPanel,...
            'Items',{'dB','abs'},'Value','dB','Position',...
            [this.SUB_CONTROL_INDENT+85,this.MagnitudeCheckBox.Position(2),60,this.CONTROL_HEIGHT]);


            this.PhaseCheckBox=uicheckbox(this.FormatPanel,...
            'Text','Phase','Position',...
            [this.SUB_CONTROL_INDENT,this.MagnitudeCheckBox.Position(2)-this.CONTROL_HEIGHT,75,this.CONTROL_HEIGHT]);


            this.RealImaginaryRadioButton=...
            uiradiobutton(this.FormatPanel,'Text','Real/Imaginary',...
            'Position',[10,this.PhaseCheckBox.Position(2)-2*this.CONTROL_HEIGHT,180,this.CONTROL_HEIGHT]);

            this.RealCheckBox=uicheckbox(this.FormatPanel,...
            'Text','Real Component','Position',...
            [this.SUB_CONTROL_INDENT,this.RealImaginaryRadioButton.Position(2)-this.CONTROL_HEIGHT,180,this.CONTROL_HEIGHT],...
            'Value',true);

            this.ImaginaryCheckBox=uicheckbox(this.FormatPanel,...
            'Text','Imaginary Component','Position',...
            [this.SUB_CONTROL_INDENT,this.RealCheckBox.Position(2)-this.CONTROL_HEIGHT,180,this.CONTROL_HEIGHT],...
            'Value',true);
        end


        function setInitialSelections(this,currentPlotParams,currentPlotFormat)

            for j=1:length(currentPlotParams)
                switch(currentPlotParams{j})
                case 'S11'
                    this.S11CheckBox.Value=true;
                case 'S21'
                    this.S21CheckBox.Value=true;
                case 'S12'
                    this.S12CheckBox.Value=true;
                case 'S22'
                    this.S22CheckBox.Value=true;
                end
            end


            for j=1:length(currentPlotFormat)
                switch(currentPlotFormat{j})
                case 'magdB'
                    selectedBtn='magphase';
                    this.MagnitudeCheckBox.Value=true;
                    this.MagnitudeFormatDropDown.Value='dB';
                case 'magabs'
                    selectedBtn='magphase';
                    this.MagnitudeCheckBox.Value=true;
                    this.MagnitudeFormatDropDown.Value='abs';
                case 'phase'
                    selectedBtn='magphase';
                    this.PhaseCheckBox.Value=true;
                case 'real'
                    selectedBtn='realimag';
                    this.RealCheckBox.Value=true;
                case 'imaginary'
                    selectedBtn='realimag';
                    this.ImaginaryCheckBox.Value=true;
                end
            end

            if(~isempty(currentPlotFormat))
                if(strcmp(selectedBtn,'magphase'))
                    this.MagPhaseRadioButton.Value=true;
                elseif(strcmp(selectedBtn,'realimag'))
                    this.RealImaginaryRadioButton.Value=true;
                end
            end
            this.overallFormatChangedCallback();

        end

        function assignUICallbacks(this)
            this.S11CheckBox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
            this.S12CheckBox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
            this.S21CheckBox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
            this.S22CheckBox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());


            this.FormatPanel.SelectionChangedFcn=@(~,~)(this.overallFormatChangedCallback());
            this.MagnitudeCheckBox.ValueChangedFcn=@(~,~)(this.formatChangedCallback());
            this.MagnitudeFormatDropDown.ValueChangedFcn=@(~,~)(this.formatChangedCallback());
            this.PhaseCheckBox.ValueChangedFcn=@(~,~)(this.formatChangedCallback());


            this.RealCheckBox.ValueChangedFcn=@(~,~)(this.formatChangedCallback());
            this.ImaginaryCheckBox.ValueChangedFcn=@(~,~)(this.formatChangedCallback());
        end
    end


    methods(Access=public)



        function parameterChangedCallback(this)
            parameters={};
            if(this.S11CheckBox.Value)
                parameters{end+1}='S11';
            end
            if(this.S21CheckBox.Value)
                parameters{end+1}='S21';
            end
            if(this.S12CheckBox.Value)
                parameters{end+1}='S12';
            end
            if(this.S22CheckBox.Value)
                parameters{end+1}='S22';
            end

            this.notify('ParameterOptionChanged',rf.internal.apps.matchnet.PlotParameterSetEventData([],parameters));
        end


        function overallFormatChangedCallback(this)
            if(this.MagPhaseRadioButton.Value)
                this.MagnitudeCheckBox.Enable=true;
                this.MagnitudeFormatDropDown.Enable=true;
                this.PhaseCheckBox.Enable=true;

                this.RealCheckBox.Enable=false;
                this.ImaginaryCheckBox.Enable=false;

            elseif(this.RealImaginaryRadioButton.Value)
                this.MagnitudeCheckBox.Enable=false;
                this.MagnitudeFormatDropDown.Enable=false;
                this.PhaseCheckBox.Enable=false;

                this.RealCheckBox.Enable=true;
                this.ImaginaryCheckBox.Enable=true;
            end
            this.formatChangedCallback();
        end



        function formatChangedCallback(this)
            format={};
            if(this.MagPhaseRadioButton.Value)
                if(this.MagnitudeCheckBox.Value)
                    if(strcmp(this.MagnitudeFormatDropDown.Value,'dB'))
                        format{end+1}='magdB';
                    elseif(strcmp(this.MagnitudeFormatDropDown.Value,'abs'))
                        format{end+1}='magabs';
                    end
                end
                if(this.PhaseCheckBox.Value)
                    format{end+1}='phase';
                end
            elseif(this.RealImaginaryRadioButton.Value)
                if(this.RealCheckBox.Value)
                    format{end+1}='real';
                end
                if(this.ImaginaryCheckBox.Value)
                    format{end+1}='imaginary';
                end
            end

            this.notify('FormatOptionChanged',rf.internal.apps.matchnet.PlotFormatSetEventData([],format));
        end
    end

    methods(Access=public)
        function delete(this)
            delete(this.MainGrid);
        end
    end
end

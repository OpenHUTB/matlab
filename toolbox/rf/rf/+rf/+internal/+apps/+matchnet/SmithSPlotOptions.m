
classdef SmithSPlotOptions<handle



    properties(Access=public)
        myParent matlab.ui.container.Panel

        ParametersMainGrid matlab.ui.container.GridLayout
        ParametersLabel matlab.ui.control.Label
        ParamGrid matlab.ui.container.GridLayout
        S11Checkbox matlab.ui.control.CheckBox
        S22Checkbox matlab.ui.control.CheckBox
    end

    events
ParameterOptionChanged
FormatOptionChanged
    end

    methods(Access=public)
        function this=SmithSPlotOptions(parent,currentPlotStatus)
            this.myParent=parent;
            this.initializeUI();
            this.setInitialSelections(currentPlotStatus);
            this.assignUICallbacks();
        end
    end

    methods(Access=protected)
        function initializeUI(this)

            this.ParametersMainGrid=uigridlayout(this.myParent,...
            'ColumnWidth',{'fit'},'RowHeight',{'fit'},...
            'Visible',matlab.lang.OnOffSwitchState.off);







            this.ParamGrid=uigridlayout(this.ParametersMainGrid,...
            'RowHeight',{'fit'},'ColumnWidth',{'fit','fit'});


            this.S11Checkbox=uicheckbox(this.ParamGrid,'Text','S11');


            this.S22Checkbox=uicheckbox(this.ParamGrid,'Text','S22');


            this.ParametersMainGrid.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function setInitialSelections(this,currentPlotStatus)
            for j=1:length(currentPlotStatus)
                switch(currentPlotStatus{j})
                case 'S11'
                    this.S11Checkbox.Value=true;
                case 'S22'
                    this.S22Checkbox.Value=true;
                end
            end
        end

        function assignUICallbacks(this)
            this.S11Checkbox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
            this.S22Checkbox.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
        end

    end


    methods(Access=public)
        function parameterChangedCallback(this)
            parameters={};
            if(this.S11Checkbox.Value)
                parameters{end+1}='S11';
            end
            if(this.S22Checkbox.Value)
                parameters{end+1}='S22';
            end

            this.notify('ParameterOptionChanged',rf.internal.apps.matchnet.PlotParameterSetEventData([],parameters));
        end
    end


    methods(Access=public)
        function delete(this)
            delete(this.ParametersMainGrid);
        end
    end
end

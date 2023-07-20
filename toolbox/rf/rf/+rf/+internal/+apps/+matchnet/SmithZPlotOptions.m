classdef SmithZPlotOptions<handle





    properties(Access=public)
        myParent matlab.ui.container.Panel

        ParametersMainGrid matlab.ui.container.GridLayout
        ParamGrid matlab.ui.container.GridLayout
        PathLabel matlab.ui.control.Label
        PathDropDown matlab.ui.control.DropDown
        Z0Label matlab.ui.control.Label
        Z0Edit matlab.ui.control.NumericEditField
    end

    properties(Access=public,Constant)
        CONTROL_HEIGHT=20
        SUB_CONTROL_INDENT=10
    end

    events
ParameterOptionChanged
FormatOptionChanged
    end

    methods(Access=public)
        function this=SmithZPlotOptions(parent,currentPlotStatus)
            this.myParent=parent;
            this.initializeUI();
            this.setInitialSelections(currentPlotStatus);
            this.assignUICallbacks();
        end
    end

    methods(Access=protected)
        function initializeUI(this)

            this.ParametersMainGrid=uigridlayout(this.myParent,...
            'ColumnWidth',{'fit'},'RowHeight',{'fit','fit'},...
            'Padding',[10,10,30,10],...
            'Visible',matlab.lang.OnOffSwitchState.off);


            this.ParamGrid=uigridlayout(this.ParametersMainGrid,...
            'RowHeight',{'fit','fit'},'ColumnWidth',{'fit','fit'},...
            'Padding',[this.SUB_CONTROL_INDENT,0,0,0]);
            this.ParamGrid.Layout.Row=2;

            this.PathLabel=uilabel(this.ParamGrid,'Text',...
            getString(message('rf:matchingnetworkgenerator:SmithZlabel')));
            this.PathLabel.Layout.Row=1;
            this.PathLabel.Layout.Column=1;

            PathTypes=[string(getString(message('rf:matchingnetworkgenerator:PathSL'))),...
            string(getString(message('rf:matchingnetworkgenerator:PathLS')))];
            this.PathDropDown=uidropdown(this.ParamGrid,...
            'Items',PathTypes);
            this.PathDropDown.Layout.Row=1;
            this.PathDropDown.Layout.Column=2;

            this.Z0Label=uilabel(this.ParamGrid,...
            'Text','Z0');
            this.Z0Label.Layout.Row=2;
            this.Z0Label.Layout.Column=1;
            this.Z0Label.Tooltip=getString(message('rf:matchingnetworkgenerator:SmithZdesc'));

            this.Z0Edit=uieditfield(this.ParamGrid,'numeric',...
            'Limits',[0,Inf],'LowerLimitInclusive','off',...
            'UpperLimitInclusive','off',...
            'ValueDisplayFormat',['%11.4g ',char(937)]);
            this.Z0Edit.Layout.Row=2;
            this.Z0Edit.Layout.Column=2;

            this.ParametersMainGrid.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function setInitialSelections(this,currentPlotStatus)
            this.PathDropDown.Value=currentPlotStatus{1};
            this.Z0Edit.Value=currentPlotStatus{2};
        end

        function assignUICallbacks(this)
            this.PathDropDown.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
            this.Z0Edit.ValueChangedFcn=@(~,~)(this.parameterChangedCallback());
        end

    end


    methods(Access=public)
        function parameterChangedCallback(this)
            parameters={this.PathDropDown.Value,this.Z0Edit.Value};
            this.notify('ParameterOptionChanged',rf.internal.apps.matchnet.PlotParameterSetEventData([],parameters));
        end
    end


    methods(Access=public)
        function delete(this)
            delete(this.ParametersMainGrid);
        end
    end
end

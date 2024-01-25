classdef DateSelector<icomm.pi.app.Container

    properties(GetAccess=public,SetAccess=public,Dependent)
        Label string
        Datetime(1,1)datetime
        Limits(1,2)datetime
    end

    properties(GetAccess=public,SetAccess=private)
        LabelText matlab.ui.control.Label
        UiDateSelector matlab.ui.control.DatePicker
        EditBox matlab.ui.control.EditField
    end


    properties(GetAccess=private,Constant)
        DateFormat=icomm.pi.internal.Locale.DateFormat
        TimeFormat=icomm.pi.internal.Locale.TimeFormat
        DatetimeFormat=icomm.pi.internal.Locale.DatetimeFormat
    end

    properties(GetAccess=private,SetAccess=private)
PreviousValue
    end

    events(ListenAccess=public,NotifyAccess=private)
DatetimeChanged
    end


    methods

        function value=get.Label(this)
            value=this.LabelText.Text;
        end


        function set.Label(this,value)
            this.LabelText.Text=value;
        end


        function value=get.Datetime(this)
            value=datetime(...
            sprintf('%s %s',char(this.UiDateSelector.Value),this.EditBox.Value),...
            'InputFormat',this.DatetimeFormat,...
            'Format',this.DatetimeFormat,...
            'TimeZone',icomm.pi.internal.defaultTimeZone());
        end


        function set.Datetime(this,value)
            if this.Limits(1)>value||value>this.Limits(2)
                uialert(...
                ancestor(this.Parent,'figure'),...
                'The date is not within the limits',...
                'Invalid date');
            else
                value.Format=this.DateFormat;
                this.UiDateSelector.Value=value;
                value.Format=this.TimeFormat;
                this.EditBox.Value=char(value);
                this.PreviousValue=this.EditBox.Value;
            end
        end


        function value=get.Limits(this)
            value=this.UiDateSelector.Limits;
            value.TimeZone=icomm.pi.internal.defaultTimeZone();
        end


        function set.Limits(this,value)
            this.UiDateSelector.Limits=value;
        end

    end


    methods(Access=public)

        function this=DateSelector(varargin)
            box=uigridlayout(...
            'Parent',[],...
            'Padding',0);
            this@icomm.pi.app.Container(box,varargin{:});
        end

    end


    methods(Access=protected)

        function initialize(this)
            this.UiContainer.ColumnWidth={'1x',120,60};
            this.UiContainer.RowHeight={'1x'};
            this.LabelText=uilabel(...
            'HorizontalAlignment','right',...
            'VerticalAlignment','center',...
            'Parent',this.UiContainer,...
            'Text','Date:');
            limits=[...
            datetime(0,1,1,'TimeZone',icomm.pi.internal.defaultTimeZone()),...
            datetime(9999,1,1,'TimeZone',icomm.pi.internal.defaultTimeZone())];
            this.UiDateSelector=uidatepicker(...
            'Parent',this.UiContainer,...
            'Limits',limits,...
            'Value',datetime('now','Format',this.DateFormat,'TimeZone',icomm.pi.internal.defaultTimeZone()),...
            'ValueChangedFcn',@this.onDateChanged);
            this.UiDateSelector.Limits.TimeZone=icomm.pi.internal.defaultTimeZone();
            this.EditBox=uieditfield('text',...
            'HorizontalAlignment','center',...
            'Parent',this.UiContainer,...
            'Value',char(datetime('now','Format',this.TimeFormat,'TimeZone',icomm.pi.internal.defaultTimeZone())),...
            'ValueChangedFcn',@this.onDateChanged);
            this.PreviousValue=this.EditBox.Value;
        end

    end


    methods(Access=private)

        function onDateChanged(this,varargin)
            try
                newDate=this.Datetime;

                if this.Limits(1)>newDate||newDate>this.Limits(2)
                    uialert(...
                    ancestor(this.Parent,'figure'),...
                    'The date is not within the limits',...
                    'Invalid date');
                    this.EditBox.Value=this.PreviousValue;
                else
                    this.PreviousValue=this.EditBox.Value;
                    this.notify('DatetimeChanged');
                end
            catch matlabException
                uialert(...
                ancestor(this.Parent,'figure'),...
                matlabException.message,...
                'Invalid format');
                this.EditBox.Value=this.PreviousValue;
            end
        end

    end

end
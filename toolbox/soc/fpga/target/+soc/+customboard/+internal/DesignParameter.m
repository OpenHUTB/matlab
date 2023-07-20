classdef DesignParameter<handle

    methods
        function obj=DesignParameter(name,gname,defval,minval,maxval,units,possvals,widgettype,envis,valchgcb,defvalcb)
            obj.Name=name;
            obj.GroupName=gname;
            obj.MinValue=minval;
            obj.MaxValue=maxval;
            obj.Units=units;
            obj.PossibleValues=possvals;
            obj.WidgetType=widgettype;
            obj.Enabled=envis{1};
            obj.Visible=envis{2};
            obj.Entries=possvals;
            switch valchgcb
            case 'default',obj.Callback='codertarget.fpgadesign.internal.fpgaDesignCallbackForCustomBoard';
            otherwise,obj.Callback=valchgcb;
            end
            switch defvalcb
            case 'default',obj.DefaultValueType='callback';obj.DefaultValue=sprintf('codertarget.fpgadesign.internal.fpgaDesignCallbackForCustomBoard(hObj,''default'',fieldName, ''%s'')',defval);
            case '',obj.DefaultValueType='';obj.DefaultValue=defval;
            otherwise,obj.DefaultValueType='callback';obj.DefaultValue=defvalcb;
            end
        end

        function cObj=getValueConstraints(obj)
            cObj=soc.customboard.internal.ValueConstraints(...
            obj.DefaultValue,obj.MinValue,obj.MaxValue,obj.PossibleValues);
        end
    end


    properties
DefaultValue
DefaultValueType
MinValue
MaxValue
PossibleValues
Enabled
Entries
    end


    properties(SetAccess=private)
Name
GroupName
Units
Visible
Callback
WidgetType
    end


end
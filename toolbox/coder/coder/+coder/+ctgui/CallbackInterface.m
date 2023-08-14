classdef(Sealed)CallbackInterface<handle
    properties(Constant,Access=private)
        USER_DATA_FIELDS={'Storage','ValueType','ValueRange','Entries'};
    end

    properties(SetAccess=private)
CoderTargetData
    end

    properties(Access=private)
callbackContext
fauxConfigSet
udCache
    end

    methods
        function this=CallbackInterface(callbackContext,fauxConfigSet)
            assert(isa(callbackContext,'com.mathworks.toolbox.coder.target.JavaCallbackContext'));

            this.callbackContext=callbackContext;
            this.udCache=containers.Map();

            if isempty(fauxConfigSet)
                this.fauxConfigSet=coder.ctgui.FauxConfigSet(callbackContext.getDataView());
            else
                this.fauxConfigSet=fauxConfigSet;
            end

            this.setTransientMode(false);
        end

        function configSet=getConfigSet(this)
            configSet=this.fauxConfigSet;
        end

        function ud=getUserData(this,tag)
            function propValue=getParameterProperty(propKey)
                propValue=char(this.callbackContext.getParameterProperty(tag,propKey));
            end

            if this.udCache.isKey(tag)
                ud=this.udCache(tag);
            else
                udValues=cell(length(this.USER_DATA_FIELDS),1);
                for i=1:length(udValues)
                    udValues{i}=getParameterProperty(this.USER_DATA_FIELDS{i});
                end

                ud=cell2struct(udValues,this.USER_DATA_FIELDS,1);
                if isfield(ud,'Entries')
                    ud.Entries=strsplit(ud.Entries,';');
                end
                this.udCache(tag)=ud;
            end
        end

        function widgetValue=getWidgetValue(this,tag)
            widgetValue=coder.ctgui.CallbackInterface.convertFromJava(this.callbackContext.getWidgetValue(tag));
        end

        function text=getComboBoxText(this,tag)
            ud=this.getUserData(tag);
            if~isempty(ud)&&isfield(ud,'Entries')
                if ischar(ud.Entries)
                    ud.Entries=strsplit(ud.Entries,';');
                end
                val=this.getWidgetValue(tag);
                if isnumeric(val)
                    text=ud.Entries{val+1};
                else
                    text=val;
                end
            else
                text='';
            end
        end

        function setWidgetValue(this,tag,value)
            this.callbackContext.setWidgetValue(tag,value);
        end

        function data=get.CoderTargetData(this)
            data=this.fauxConfigSet.dataStructView;
        end
    end

    methods(Hidden)
        function setTransientMode(this,useTransientMode)
            this.fauxConfigSet.setTransientMode(useTransientMode);
        end
    end

    methods(Static)
        function converted=convertFromJava(obj)
            if isempty(obj)
                converted=[];
            elseif strfind(class(obj),'java')==1
                if isa(obj,'java.lang.String')
                    converted=char(obj);
                elseif isa(obj,'java.lang.Number')
                    converted=obj.doubleValue();
                elseif isa(obj,'java.lang.Boolean')
                    converted=obj.booleanValue();
                else
                    converted=char(obj);
                end
            else
                converted=obj;
            end
        end
    end
end
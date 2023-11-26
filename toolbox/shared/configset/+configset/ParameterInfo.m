classdef ParameterInfo<configset.ParameterStaticInfo

    properties(Hidden)
CS
Adp
    end

    properties(Dependent)
Value
DisplayValue
IsReadable
IsWritable
    end

    methods
        function obj=ParameterInfo(cs,d,varargin)
            obj=obj@configset.ParameterStaticInfo(d);
            obj.CS=cs;

            if nargin<3
                obj.Adp=configset.internal.data.ConfigSetAdapter(cs);
            else
                obj.Adp=varargin{1};
            end
        end

        function out=get.Value(obj)
            out=obj.Adp.getParamValue(obj.Name);
        end

        function out=get.DisplayValue(obj)
            v=obj.Value;
            out=v;
            av=obj.AllowedValues;
            if~isempty(av)
                dv=obj.AllowedDisplayValues;


                if isnumeric(v)
                    display=dv(arrayfun(@(val)isequal(val,v),av));
                else
                    display=dv(strcmp(av,v));
                end

                if~isempty(display)
                    out=display{1};
                end
            end
        end


        function out=get.IsReadable(obj)
            status=obj.Adp.getParamStatus(obj.Name,obj.ParamInfo);
            out=(status<configset.internal.data.ParamStatus.InAccessible);
        end


        function out=get.IsWritable(obj)
            status=obj.Adp.getParamStatus(obj.Name,obj.ParamInfo);
            out=(status<configset.internal.data.ParamStatus.ReadOnly);

            if out
                component=obj.Adp.getParamOwner(obj.Name);
                try
                    if component.isReadonlyProperty(obj.Name)
                        out=false;
                    end
                catch

                end
            end
        end



        function out=getAllowedValues(obj)

            out=obj.ParamInfo.getAllowedValues(obj.CS);
            if isempty(out)&&length(obj.ParamInfo.WidgetList)==1
                out=obj.ParamInfo.WidgetList{1}.getAllowedValues(obj.CS);
            end
        end

        function out=getAllowedDisplayValues(obj)
            out=obj.ParamInfo.getDisplayedValues(obj.CS);
            if isempty(out)&&length(obj.ParamInfo.WidgetList)==1
                out=obj.ParamInfo.WidgetList{1}.getDisplayedValues(obj.CS);
            end
        end

        function out=getDescription(obj)
            out=obj.ParamInfo.getPrompt(obj.CS);
            if isempty(out)

                out=obj.ParamInfo.getDescription();
            end
        end

        function out=getLongDescription(obj)
            out=obj.ParamInfo.getToolTip(obj.CS);
        end

        function out=getIsUI(obj)
            if obj.ParamInfo.Hidden
                out=false;
            else
                status=obj.Adp.getParamStatus(obj.Name);
                out=(status<configset.internal.data.ParamStatus.UnAvailable);
            end

            if strcmp(obj.ParamInfo.Component,'Target')
                target=obj.CS.getComponent('Code Generation').getComponent('Target');
                if isa(target,'Simulink.STFCustomTargetCC')&&isempty(target.Components)
                    out=false;
                end
            end
        end

        function out=getDisplayPath(obj,delimiter)





            if nargin<2
                delimiter='/';
            end
            layout=configset.internal.getConfigSetCategoryLayout;
            out=layout.getParamDisplayPath(obj.Name,obj.CS,delimiter);
        end

        function out=getWidgetType(obj)

            widgets=obj.Adp.getWidgetDataList(obj.Name,obj.ParamInfo);
            out=configset.internal.util.getDDGWidgetType(widgets{1});
        end
    end
end


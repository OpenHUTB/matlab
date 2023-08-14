

classdef(Sealed=true)WidgetStaticData<configset.internal.data.ParamStaticData


    properties
        WidgetType='';
Parameter
        ShowCommandLineName=true
    end

    methods

        function obj=WidgetStaticData(widgetNode,param,component)
            pName=param.Name;
            obj@configset.internal.data.ParamStaticData(widgetNode,component,pName);
        end

        function name=getParamName(obj)
            name=obj.Parameter.Name;
        end

        function name=getParamFullName(obj)
            name=obj.Parameter.FullName;
        end
    end

    methods(Access=protected)
        createFromXmlNode(obj,wNode,cp)
        checkXmlSyntax(obj,pNode,allowDeprecated)
    end
    methods(Access=?configset.internal.data.ParamStaticData)
        setupWidget(obj,param)
    end

    methods(Hidden)
        out=getInfo(obj,varargin)
    end
end



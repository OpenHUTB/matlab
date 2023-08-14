function createFromXmlNode(obj,wNode,cp)



    obj.createFromXmlNode@configset.internal.data.ParamStaticData(wNode,cp);

    node=configset.internal.helper.getChildNodeByTagName(wNode,'widgetType');
    if isempty(node)
        node=configset.internal.helper.getChildNodeByTagName(wNode,'widget_type');
    end
    if~isempty(node)
        obj.WidgetType=node{1}.getFirstChild.getNodeValue;
    end




    if ismember(obj.WidgetType,{'pushbutton','hyperlink','table'})

        if strcmp(obj.WidgetType,'table')
            str=node{1}.getAttribute('function');



            obj.f_AvailableValues=configset.internal.util.createCustomFunction(class(obj),str);
        end

    elseif strcmp(obj.WidgetType,'image')

        obj.UI.f_image=strsplit(obj.UI.f_prompt,':');
        obj.UI.f_prompt='';
    end


    if wNode.hasAttribute('showCommandLineName')
        obj.ShowCommandLineName=jsondecode(wNode.getAttribute('showCommandLineName'));
    end

    if~isempty(obj.WidgetList)
        error(['Widget ',obj.Name,' cannot contain other widgets']);
    end
end


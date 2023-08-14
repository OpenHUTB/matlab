function editElement(configname,type,name)





    model=dig.config.Model.getOrCreate(configname);
    switch lower(type)
    case 'widget'
        element=model.findWidget(name);
    case 'action'
        element=model.findAction(name);
    case 'icon'
        element=model.findIcon(name);
    otherwise
        throw(MException(message('dig:config:resources:InvalidElementType')));
    end

    if~isempty(element)

        edit(element);
    else
        throw(MException(message('dig:config:resources:NoSuchElement',type,name)));
    end
end
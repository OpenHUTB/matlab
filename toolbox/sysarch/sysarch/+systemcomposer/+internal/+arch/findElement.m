function element=findElement(namedFullPath,context)












    if(isa(context,'systemcomposer.architecture.model.design.Architecture'))
        element=context.findElement(namedFullPath);
    else

        assert(isa(context,'systemcomposer.internal.view.View'));
        element=systemcomposer.internal.view.ViewComponent.empty;
        pathElementNames=strsplit(namedFullPath,'/');

        if(length(pathElementNames)==1)
            if(contains(pathElementNames{1},':'))
                elems=strsplit(pathElementNames{1},':');
                if(strcmp(elems{1},context.Name))
                    element=getPortConnectorElement(pathElementNames{1},context,context);
                end
            elseif(contains(pathElementNames{1},'#'))
                elems=strsplit(pathElementNames{1},'#');
                if(strcmp(elems{1},context.Name))
                    element=getPortConnectorElement(pathElementNames{1},context,context);
                end
            else
                if(strcmp(pathElementNames{1},context.Name))
                    element=context;
                end
            end
            return
        end

        if(strcmp(pathElementNames{1},context.Name))
            if(length(pathElementNames)==1)
                element=context;
                return
            elseif(length(pathElementNames)==2)
                element=getPortConnectorElement(pathElementNames{2},context,context);
                if(~isempty(element))
                    return;
                end
            end
        else

        end

        element=context.getChild(pathElementNames{2});
        if(isempty(element))
            return;
        end

        for i=3:length(pathElementNames)
            if(i==length(pathElementNames))
                if(contains(pathElementNames{i},':'))
                    element=getPortConnectorElement(pathElementNames{i},element,context);
                elseif(contains(pathElementNames{i},'#'))
                    element=getPortConnectorElement(pathElementNames{i},element,context);
                else
                    element=findElementByName(element.getChildrenInView(context),pathElementNames(i));
                end
                return;
            else

                element=findElementByName(context.ChildComponents.toArray,pathElementNames(i));
                if(isempty(element))
                    return;
                end
            end
        end

    end
end

function element=findElementByName(elements,name)
    element=[];
    for i=1:length(elements)
        if strcmp(elements(i).Name,name)
            element=elements(i);
            return;
        end
    end
end

function element=getPortConnectorElement(pathElement,curParent,view)
    if(contains(pathElement,':'))
        elems=strsplit(pathElement,':');
        if(isa(curParent,'systemcomposer.internal.view.View'))
            comp=curParent.getChild(elems{1});
            port=comp.getPort(elems{2});
        else

            comp=findElementByName(curParent.getChildrenInView(view),elems{1});
            port=comp.getPort(elems{2});
        end
        if(~isempty(port))
            element=port;
        else
            element=systemcomposer.internal.view.ViewComponentPort.empty;
        end
        return;
    elseif(contains(pathElement,'#'))
        elems=strsplit(pathElement,'#');
        connector=findElementByName(view.getConnectors,elems{2});
        if(~isempty(connector))
            element=connector;
        else
            element=systemcomposer.internal.view.ViewConnector.empty;
        end
        return;
    end
    element=[];
    return;
end

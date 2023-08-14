function[childElem,parentElem]=resolveSLObj(obj)






    childElem=[];
    parentElem=[];

    if~ishandle(obj)
        return;
    end

    if strcmp(get_param(obj,'Type'),'block')
        elem=systemcomposer.utils.getArchitecturePeer(obj);
        if~isempty(elem)
            parentElem=elem;

            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                if elem.hasReferencedArchitecture

                    if sysarch.isReferenceModelLoaded(obj)
                        childElem=elem.getArchitecture;
                    end
                else
                    childElem=elem.getArchitecture;
                end
                views=elem.getTopLevelArchitecture.p_Model.getViews;
                for view=views
                    compInView=view.getComponentInArchitecture(elem);
                    if~isempty(compInView)
                        parentElem=[parentElem,compInView];

                    end
                end
            elseif isa(elem,'systemcomposer.architecture.model.design.Port')
                childElem=[];
                if elem.isArchitecturePort
                    elem=elem.getParentComponentPort;
                end
                if~isempty(elem)
                    occur=elem.p_OccurrencePorts;
                    parentElem=[elem,occur];
                    if~isempty(occur)
                        childElem=[childElem,occur.getViewArchitecture];
                    end
                end
            end
        end

    elseif strcmp(get_param(obj,'Type'),'block_diagram')
        childElem=systemcomposer.utils.getArchitecturePeer(obj);
        if(childElem.hasParentComponent)
            parentComp=childElem.getParentComponent;
            occur=parentComp.p_Occurrence;
            if(~isempty(occur))
                childElem=[childElem,occur.getViewArchitecture];
            end
        end
    end
end

function result=selectionLink(reqsys,modelName,diagElemUUID)










    linkType=rmi.linktype_mgr('resolveByRegName',reqsys);
    if isempty(linkType)
        error(message('Slvnv:rmitm:IsInvalidDomainName',reqsys));
    end
    if isempty(linkType.SelectionLinkFcn)
        error(message('Slvnv:rmitm:NoSupportForSelectionLinking',reqsys));
    end
    ids={};
    elems={};

    if~iscell(diagElemUUID)
        diagElemUUID={diagElemUUID};
    end

    for i=1:numel(diagElemUUID)

        curHlgtedElem=sysarch.getSemanticElementFromDiagram(modelName,diagElemUUID{i});

        curHlgtedElem=sysarch.getLinkableObjectFromViewObject(curHlgtedElem);
        if isa(curHlgtedElem,'systemcomposer.architecture.model.design.BaseComponent')
            curHlgtedElem=systemcomposer.utils.getSimulinkPeer(curHlgtedElem);
            ids=[ids,{curHlgtedElem}];
            elems=[elems,{curHlgtedElem}];
        elseif isa(curHlgtedElem,'systemcomposer.architecture.model.views.BaseViewPort')
            if isa(curHlgtedElem,'systemcomposer.architecture.model.views.ViewComponentPort')
                curHlgtedElem=curHlgtedElem.getArchitecturePort;
            end
            if isa(curHlgtedElem,'systemcomposer.architecture.model.views.BaseOccurrencePort')
                curHlgtedElem=curHlgtedElem.getDesignComponentPort;
                curHlgtedElem=sysarch.getLinkableCompositionPort(curHlgtedElem);
            else
                error('systemcomposer:Requirements:UnsupportedPort',message('SystemArchitecture:Requirements:UnsupportedPort').getString);
            end
            ids=[ids,{curHlgtedElem.getZCIdentifier}];
            elems=[elems,{curHlgtedElem}];
        else
            ids=[ids,{curHlgtedElem.getZCIdentifier}];
            elems=[elems,{curHlgtedElem}];
        end
    end

    if numel(ids)==1
        ids=ids{1};
    end
    make2way=rmipref('BiDirectionalLinking');
    result=feval(linkType.SelectionLinkFcn,ids,make2way);
    if iscell(result)


        req=result{1};
    else

        req=result;
    end

    if~isempty(req)
        for i=1:numel(elems)
            src=slreq.utils.resolveSrc(elems{i});
            slreq.internal.catLinks(src,req);
        end
    end
end


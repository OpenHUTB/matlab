function objs=removeLink(this,link)






    slreq.utils.assertValid(link);

    if~isa(link,'slreq.data.Link')
        error('Invalid argument: expected slreq.data.Link');
    end

    modelObj=link.getModelObj();



    this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('BeforeDeleteLink',link));


    connectors=[link.connector,link.diagramConnector];
    if~isempty(connectors)
        this.removeConnectors(connectors);
    end

    objs={};




    dataObjs=slreq.cpputils.collectTags(modelObj,true,true);
    for i=1:length(dataObjs)
        dataObj=dataObjs{i};


        dasObj=dataObj.getDasObject();
        if~isempty(dasObj)



            objs{end+1}=dasObj;%#ok<AGROW>
        end
    end

    if~isempty(modelObj)
        modelObjSource=modelObj.source;
        modelLinkSet=modelObjSource.artifact;








        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Link Deleted',link));

























        modelLinkSet.links.remove(modelObj);


        modelObj.destroy;
        link.delete;
    end
end

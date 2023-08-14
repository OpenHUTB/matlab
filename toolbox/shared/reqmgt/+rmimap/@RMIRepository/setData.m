function setData(this,srcName,elementId,linkData)





    if~ischar(srcName)
        isSlModel=true;
        srcHandle=srcName;

        [~,srcName]=rmisl.modelFileParts(srcHandle);
    else
        isSlModel=false;
    end


    rootObj=rmimap.RMIRepository.getRoot(this.graph,srcName);


    if isempty(rootObj)
        if isSlModel
            rootObj=this.addModel(srcHandle);
        else

            if rmimap.isSupportedSourceType(srcName)
                rootObj=this.addRoot(srcName);
            else
                error(message('Slvnv:rmigraph:UnmatchedModelName',srcName));
            end
        end
    end

    t1=M3I.Transaction(this.graph);


    elt=rmimap.RMIRepository.getNode(rootObj,elementId);


    if isempty(elt)
        elt=this.addNode(rootObj,elementId);
    else

        this.clearLinks(elt,false);
    end


    for i=1:length(linkData)



        description=linkData(i).description;
        reqsys=linkData(i).reqsys;
        if isempty(reqsys)
            reqsys='other';
        end
        targetDoc=linkData(i).doc;
        if isempty(targetDoc)
            targetDoc=['__UNSPECIFIED__',reqsys];
        end
        if strcmp(reqsys,'linktype_rmi_simulink')&&strcmp(targetDoc,'$ModelName$')

            targetNode=this.findOrAddNode(rootObj.url,linkData(i).id,'linktype_rmi_simulink');
            if description(1)=='/'
                description=[rootObj.url,description];%#ok<AGROW>
            end
        else
            targetNode=this.findOrAddNode(targetDoc,linkData(i).id,reqsys);
        end
        link=elt.addLink(targetNode);


        link.setProperty('description',description);
        link.setProperty('linked',num2str(linkData(i).linked));
        link.setProperty('keywords',linkData(i).keywords);
    end
    t1.commit;
end



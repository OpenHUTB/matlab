



function dasObj=findDASbyUUID(uuid)

    dasObj=slreq.das.BaseObject.empty();


    if isempty(uuid)
        return;
    end

    appmgr=slreq.app.MainManager.getInstance;
    if~appmgr.hasDAS

        appmgr.init();
    end


    if appmgr.markupManager.uuid2DASObjMap.isKey(uuid)
        dasObj=appmgr.markupManager.uuid2DASObjMap(uuid);
    else





        if contains(uuid,':')
            return;
        end

        reqData=slreq.data.ReqData.getInstance();

        try
            dataObj=reqData.findObject(uuid);

        catch ex %#ok<NASGU>
            dataObj=slreq.data.DataModelObj.empty;
        end

        if isempty(dataObj)

            return;
        end

        if isa(dataObj,'slreq.data.DataModelObj')
            dasObj=dataObj.getDasObject();



        end

        if isempty(dasObj)


            thisData=dataObj.parent;
            if isempty(thisData)

                thisData=dataObj.getReqSet;
            end

            while true

                parentDas=thisData.getDasObject();
                if~isempty(parentDas)

                    parentDas.createChildren();
                    break;
                end
                thisData=thisData.parent;

                if isempty(thisData)

                    thisData=dataObj.getReqSet;
                end

                if isempty(thisData)

                    break;
                end
            end
            dasObj=dataObj.getDasObject();
        end
    end
end

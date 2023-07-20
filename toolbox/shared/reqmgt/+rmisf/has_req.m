function out=has_req(apiObj,skipChart)






    out=false;




    if nargin<2
        skipChart=true;
    end
    if skipChart&&isa(apiObj,'Stateflow.Chart')
        return;
    end

    if any(strcmp(class(apiObj),rmisf.sfisa('supportedTypes')))
        filterSettings=rmi.settings_mgr('get','filterSettings');
        out=rmi('hasrequirements',apiObj,filterSettings);
    end



    if~out&&any(strcmp(class(apiObj),{'Stateflow.EMChart','Stateflow.EMFunction'}))
        sid=Simulink.ID.getSID(apiObj);
        [mdlName,id]=strtok(sid,':');
        if rmidata.isExternal(mdlName)
            linkSet=slreq.utils.getLinkSet(mdlName);
            if~isempty(linkSet)
                textItem=linkSet.getTextItem(id);
                out=~isempty(textItem)&&rmiml.hasLinks(sid);
            end
        end
    end
end


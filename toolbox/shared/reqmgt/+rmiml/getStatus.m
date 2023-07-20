function result=getStatus(fPath)





    if rmisl.isSidString(fPath)
        mdlName=strtok(fPath,':');
        fPath=get_param(mdlName,'FileName');
    end
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(fPath);
    if isempty(linkSet)
        result='unknown';
    else

        if linkSet.dirty
            result=num2str(now);
        else
            result='saved';
        end
    end
end



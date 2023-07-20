function msg=getMessageCatalog(msgId,paramList)





    if(isempty(paramList))
        msg=getString(message(msgId));
    else
        nParams=length(paramList);
        if(nParams==1)
            msg=getString(message(msgId,paramList{1}));
        elseif(nParams==2)
            msg=getString(message(msgId,paramList{1},paramList{2}));
        elseif(nParams==3)
            msg=getString(message(msgId,paramList{1},paramList{2},paramList{3}));
        end
    end
end
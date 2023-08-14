function b=saveReqSet(absoluteReqFilePath)







    reqSet=slreq.find("Type","ReqSet","Filename",fullfile(absoluteReqFilePath));

    if~isempty(reqSet)
        reqSet.save();
        b=true;
    else
        b=false;
    end

end

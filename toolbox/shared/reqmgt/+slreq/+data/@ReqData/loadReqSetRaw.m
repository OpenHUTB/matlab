





function mfReqSet=loadReqSetRaw(this,reqSetFullFilepath)








    mfReqSet=slreq.datamodel.RequirementSet.empty();

    if~isfile(reqSetFullFilepath)
        return;
    end

    try

        [content,msgId]=this.readOPCpackage(reqSetFullFilepath);


        mfReqSet=this.parseMf0File(reqSetFullFilepath,msgId,content,false);
    catch ex


        rethrow(ex);
    end

end

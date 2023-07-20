







function mfLinkSet=loadLinkSetRaw(this,linkSetFile)








    mfLinkSet=slreq.datamodel.LinkSet.empty();

    if~isfile(linkSetFile)
        return;
    end

    try

        [content,msgId]=this.readOPCpackage(linkSetFile);



        mfLinkSet=this.parseMf0File(linkSetFile,msgId,content,true);
    catch ex




        rethrow(ex);
    end

end

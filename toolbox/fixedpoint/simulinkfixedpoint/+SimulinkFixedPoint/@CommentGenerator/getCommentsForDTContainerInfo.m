function comments=getCommentsForDTContainerInfo(this,DTConInfo)





    commentsForSpecifiedDT=this.getCommentsForSpecifiedDT(DTConInfo);

    commentsNamedDTClients={};
    isMutableNamedDT=DTConInfo.traceVar();



    if isMutableNamedDT
        commentsNamedDTClients=this.getCommentsForNamedDTClients(DTConInfo);
    end

    comments=[commentsForSpecifiedDT;commentsNamedDTClients];
end

function onLinkToSelectedDD()



    [dFile,dpath,label]=rmide.getSelection;
    guid=rmide.getGuid(dFile,dpath,label);

    src.domain='linktype_rmi_data';
    src.artifact=dFile;
    src.id=guid;

    reqLinkType=linktypes.linktype_rmi_slreq;
    linkInfo=reqLinkType.SelectionLinkFcn('',false);

    slreq.internal.catLinks(src,linkInfo);

end

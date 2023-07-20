function[navcmd,dispstr,iconFile]=getReqObjInfo(reqSetFile,reqItemId)

    [~,rName,rExt]=fileparts(reqSetFile);
    if isempty(rExt)
        reqSetArg=[reqSetFile,'.slreqx'];
    elseif~strcmpi(rExt,'.slreqx')
        error('First argument must be .slreqx file');
    else
        reqSetArg=[rName,rExt];
    end

    navcmd=sprintf('rmi.navigate(''linktype_rmi_slreq'',''%s'',''%s'');',reqSetArg,reqItemId);


    dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetArg);
    linkTarget=dataReqSet.getItemFromID(reqItemId);






    dispstr=slreq.internal.makeLabel(linkTarget);

    if nargout>2
        iconFile=rmiut.getMwIcon();
    end

end

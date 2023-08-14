function[success,info]=rmidlg_apply(dlgSrc,dlgH)




    if~ReqMgr.rmidlg_hasChanges(dlgH.getTitle)
        success=true;
        info='';
        return;
    end


    if builtin('_license_checkout','Simulink_Requirements','quiet')
        success=false;
        info=getString(message('Slvnv:reqmgt:rmidlg_apply:NoLicense'));
        return;
    end

    if~isempty(dlgSrc.reqItems)

        IDs={dlgSrc.reqItems(:).id};
        reqSys={dlgSrc.reqItems(:).reqsys};

        docTypes=rmi.linktype_mgr('all');
        for i=1:length(dlgSrc.reqItems)
            typeIdx=dlgSrc.typeItems(i);
            if typeIdx==0
                continue;
            end
            linkType=docTypes(typeIdx);
            if~isempty(linkType.ItemIdFcn)&&~isempty(IDs{i})
                try

                    myId=IDs{i};
                    if myId(1)=='@'||myId(1)=='#'






                        IDs{i}=feval(linkType.ItemIdFcn,dlgSrc.reqItems(i).doc,myId(2:end),true);
                    end
                catch
                    success=false;
                    info=getString(message('Slvnv:reqmgt:rmidlg_apply:NoValidSelectionIn',dlgSrc.reqItems(i).doc));
                    return;
                end
            end
        end





        isLinked=[dlgSrc.reqItems(:).linked];
        isSurr=find(~isLinked);
        for i=isSurr
            myReqSys=reqSys{i};
            if strcmp(myReqSys,'linktype_rmi_doors')
                reqSys{i}='doors';
                myId=IDs{i};
                if~isempty(myId)&&myId(1)=='#'
                    IDs{i}=myId(2:end);
                end
            end
        end

        reqs=rmi.reqstruct({dlgSrc.reqItems(:).doc},...
        IDs,...
        {dlgSrc.reqItems(:).description},...
        {dlgSrc.reqItems(:).keywords},...
        {dlgSrc.reqItems(:).linked},...
        reqSys);











        if any(strcmp({reqs(:).reqsys},'linktype_rmi_matlab'))
            reqs=slreq.uri.correctDestinationUriAndId(reqs);
        end

    else
        reqs=[];
    end

    switch dlgSrc.source
    case 'matlab'

        [success,info,newCount]=rmiml.rmidlgApply(dlgSrc.objectH,reqs);
    case 'data'

        [success,info,newCount]=rmide.rmidlgApply(dlgSrc.objectH,reqs);
    case 'testmgr'

        [success,info,newCount]=rmitm.rmidlgApply(dlgSrc.objectH,reqs);
    case 'slreq'

        [success,info,newCount]=slreq.utils.rmidlgApply(dlgSrc.objectH,reqs);
    case 'fault'

        [success,info,newCount]=rmifa.rmidlgApply(dlgSrc.objectH,reqs);
    case 'safetymanager'

        [success,info,newCount]=rmism.rmidlgApply(dlgSrc.objectH,reqs);
    otherwise

        [success,info,newCount]=rmisl.rmidlgApply(dlgSrc,reqs);
        if success

            rmiut.hiliteAndFade(dlgSrc.objectH);



            if length(dlgSrc.objectH)>1
                dlgSrc.count=0;
                dlgSrc.reset(dlgH);
                return;
            end
        end
    end

    if success
        dlgH.enableApplyButton(false);
        dlgSrc.count=newCount;
    else



    end

end



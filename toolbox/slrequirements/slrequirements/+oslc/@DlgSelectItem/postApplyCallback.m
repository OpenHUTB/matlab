function[isValid,msg]=postApplyCallback(this,~)

    isValid=true;
    msg='';


    reqstruct=rmi.createEmptyReqs(length(this.reqs));
    for i=1:length(this.reqs)
        try
            reqstruct(i)=oslc.makeReq(this.reqs(i));

            if this.make2way
                [targetURL,mwObjLabel]=slreq.connector.getMwItemUrlAndLabel(this.sourceInfo);
                oslc.addLinkFromResource(this.reqs(i),targetURL,mwObjLabel);
            end
        catch Mex
            msg=Mex.message;
            isValid=false;
            return;
        end
    end

    if~this.allowMultiselect



        parentDlgH=ReqMgr.activeDlgUtil();
        if~isempty(parentDlgH)
            [isValid,msg]=oslc.DlgSelectItem.updateFieldsInParentDialog(parentDlgH,reqstruct);
            ReqMgr.activeDlgUtil('clear');
        else

            msg=['Parent dialog not known for processing ',reqstruct.description];
            isValid=false;
        end

    else


        try


            slreq.createLink(this.sourceInfo,reqstruct);


            oslc.manualSelectionLink();

        catch Mex
            msg=Mex.message;
            isValid=false;
        end
    end

end

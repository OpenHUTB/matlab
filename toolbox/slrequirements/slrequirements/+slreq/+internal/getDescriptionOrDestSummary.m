function destInfo=getDescriptionOrDestSummary(linkTargetInfo)











    destInfo=linkTargetInfo.description;

    if strcmp(linkTargetInfo.reqsys,'linktype_rmi_slreq')



        userLinkLabelPref=rmipref('MWReqLinkLabelProvider');

        if isempty(userLinkLabelPref)

            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            destInfo=adapter.getSummary(linkTargetInfo.doc,linkTargetInfo.id);

        elseif strcmp(userLinkLabelPref,'$link.Description$')

            return;

        elseif userLinkLabelPref(1)=='@'

            try
                userCallback=userLinkLabelPref(2:end);
                destInfo=feval(userCallback,linkTargetInfo.doc,linkTargetInfo.id);
            catch ex
                rmiut.warnNoBacktrace('Slvnv:slreq:CustomCallbackFailed',userCallback,ex.message);
            end

        else


            destInfo=slreq.internal.getMWReqAttribute(linkTargetInfo,userLinkLabelPref);
            if isempty(destInfo)
                destInfo=getString(message('Slvnv:reqmgt:InvalidAttributeName',userLinkLabelPref,linkTargetInfo.id,linkTargetInfo.doc));
            end
        end
    end
end


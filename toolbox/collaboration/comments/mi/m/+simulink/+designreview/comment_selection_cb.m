function comment_selection_cb(~,in)

    if~isempty(in)
        if(simulink.designreview.UriProvider.isStateflowUri(in))
            simulink.designreview.Util.highlightStateflowElement(in);
        else
            modelName=simulink.designreview.Util.getModelName();
            uriWithoutModel=extractBefore(in,":"+modelName);
            sid=extractAfter(uriWithoutModel,"simulink:");
            blockSid=modelName+":"+sid;
            if Simulink.ID.isValid(blockSid)
                simulink.designreview.DesignReviewApp.getInstance().getCommentsManager(bdroot(blockSid)).highlightBlock(convertStringsToChars(blockSid));
            else
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('designreview_comments:Command:InvalidBlock'),DAStudio.message('designreview_comments:Command:Error'),true);
            end
        end
    end

end

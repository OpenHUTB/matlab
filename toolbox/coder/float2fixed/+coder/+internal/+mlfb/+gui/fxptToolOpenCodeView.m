function varargout=fxptToolOpenCodeView()



    fpt=coder.internal.mlfb.FptFacade.getInstance();
    sud=fpt.getSud();
    nodeBlock=fpt.getSelectedTreeNode();

    if~isempty(sud)&&~isempty(nodeBlock)
        sudSid=Simulink.ID.getSID(sud);
        initialSid=coder.internal.mlfb.gui.MlfbUtils.getInitialBlock(nodeBlock);
        codeView=coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView();

        if~isempty(codeView)

            assert(strcmp(sudSid,codeView.SudId.SID));
            if~isempty(initialSid)
                codeView.publishToCodeView(...
                coder.internal.mlfb.gui.MessageTopics.CodeViewManipulation,...
                'selectBlock',...
                initialSid,...
                '');
            end
            codeView.show();
        else

            codeView=coder.internal.mlfb.gui.openCodeView(sudSid,initialSid);
        end
    else
        codeView=[];
    end

    if nargout>0
        varargout={codeView};
    else
        varargout={};
    end
end
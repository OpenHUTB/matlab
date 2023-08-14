function updateFpCodeView(updateType,id,arg)





    try
        codeView=getCodeView();
        if isempty(codeView)
            return;
        end

        validatestring(updateType,{'script','state'});
        validateattributes(id,{'double'},{'numel',1});
        validateattributes(arg,{'char'},{'nonempty'});

        messageBus=codeView.MessageService;

        if strcmp(updateType,'script')


            block=sfprivate('chart2block',sfprivate('eml_fcn_source',id));

            if~isempty(block)
                messageBus.publish(coder.internal.mlfb.gui.MessageTopics.StateflowUpdate,...
                'blockCodeChanged',coder.internal.mlfb.idForBlock(block),arg);
            end
        else
            assert(strcmp(updateType,'state'));


            machineModel=sfprivate('machine2model',id);
            sudModelName=bdroot(codeView.SudSid);

            if strcmp(sudModelName,machineModel.Name)

                busy=~strcmp(arg,'idle');
                coder.internal.mlfb.gui.MlfbUtils.forEachFunctionBlock(codeView.SudSid,...
                @(sid)messageBus.publish(coder.internal.mlfb.gui.MessageTopics.StateflowUpdate,'stateflowUiUpdate',sid,arg,busy));
            end
        end
    catch me
        coder.internal.gui.asyncDebugPrint(me);
    end
end

function codeView=getCodeView()
    if coder.internal.gui.isFixedPointCodeViewOpen()

        codeView=coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView();
    else
        codeView=[];
    end
end


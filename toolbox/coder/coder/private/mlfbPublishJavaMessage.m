function mlfbPublishJavaMessage(blockSids,topic,methodName,varargin)




    assert(isa(topic,'com.mathworks.toolbox.coder.mb.MessageTopic'),...
    'Topic argument must an actual MessageTopic instance');

    if ischar(blockSids)
        blockSids={blockSids};
    end

    cellfun(@(blockSid)publishToBlock(blockSid),blockSids);

    function publishToBlock(blockSid)
        import com.mathworks.toolbox.coder.mlfb.FunctionBlockCodeView;
        messageBus=FunctionBlockCodeView.getMessageBusForBlock(blockSid);

        if~isempty(messageBus)
            messagingPeer=coder.internal.gui.MessageService.getInstance(messageBus);
            messagingPeer.publish(topic,methodName,varargin{:});
        end
    end
end




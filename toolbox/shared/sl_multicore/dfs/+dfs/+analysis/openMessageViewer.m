function openMessageViewer(modelName)

    aSLMsgViewer=slmsgviewer.Instance();
    if~isempty(aSLMsgViewer)
        aSLMsgViewer.show();
        slmsgviewer.selectTab(modelName);
    end
end

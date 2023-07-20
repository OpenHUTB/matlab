function copy(dictPathOrCBInfo)






    if isa(dictPathOrCBInfo,'dig.CallbackInfo')
        contextObj=dictPathOrCBInfo.Context.Object;
        studioApp=contextObj.GuiObj;
    else
        assert(ischar(dictPathOrCBInfo));
        studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictPathOrCBInfo);
    end
    selectedNodes=studioApp.getSelectedNodes();


    clipboard=sl.interface.dictionaryApp.clipboard.Clipboard.getInstance();
    clipboard.fill(selectedNodes);


    studioApp.updateTypeChain();
end



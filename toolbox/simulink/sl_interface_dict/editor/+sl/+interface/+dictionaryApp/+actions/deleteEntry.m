function deleteEntry(dictPathOrCBInfo)





    if isa(dictPathOrCBInfo,'dig.CallbackInfo')
        contextObj=dictPathOrCBInfo.Context.Object;
        studioApp=contextObj.GuiObj;
    else
        assert(ischar(dictPathOrCBInfo));
        studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictPathOrCBInfo);
    end
    studioApp.deleteSelectedNodes();
end



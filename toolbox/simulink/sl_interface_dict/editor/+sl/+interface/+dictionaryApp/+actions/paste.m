function paste(dictPathOrCBInfo)






    if isa(dictPathOrCBInfo,'dig.CallbackInfo')
        contextObj=dictPathOrCBInfo.Context.Object;
        studioApp=contextObj.GuiObj;
    else
        assert(ischar(dictPathOrCBInfo));
        studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictPathOrCBInfo);
    end

    clipboard=sl.interface.dictionaryApp.clipboard.Clipboard.getInstance();
    if clipboard.HoldsChildElements

        destination=studioApp.getSelectedNodes();
        sl.interface.dictionaryApp.list.DragNDropHelper.drop(...
        clipboard.contents,destination{1},'after','copy');
    else
        tabAdapter=studioApp.getTabAdapter();
        tabAdapter.copy(clipboard.contents)
    end
end



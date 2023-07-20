function clearClipboard(this)



    clipboard=this.getClipboardReqSet();

    clipboard.attributeRegistry.destroyAllContents();

    clipboard.items.clear;
    clipboard.rootItems.clear;


    items=clipboard.items.toArray;
    arrayfun(@(x)x.destroy,items);
    rootitems=clipboard.rootItems.toArray;
    arrayfun(@(x)x.destroy,rootitems);
end

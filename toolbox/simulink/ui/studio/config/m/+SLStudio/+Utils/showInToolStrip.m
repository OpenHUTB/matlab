function result=showInToolStrip(cbinfo)



    result=~isa(cbinfo,'SLM3I.CallbackInfo')||~cbinfo.isContextMenu;
end
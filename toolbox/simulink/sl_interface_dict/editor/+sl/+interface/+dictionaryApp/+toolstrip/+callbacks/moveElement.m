function moveElement(moveDirection,cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    guiObj.moveSelectedElement(moveDirection);
end

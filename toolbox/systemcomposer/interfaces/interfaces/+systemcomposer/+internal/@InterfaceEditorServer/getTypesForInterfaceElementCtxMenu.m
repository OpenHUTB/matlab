function types=getTypesForInterfaceElementCtxMenu(this,interfaceElemUUID)




    elem=this.mf0Model.findElement(interfaceElemUUID);

    [~,types]=systemcomposer.internal.getTypeAndAvailableTypes(elem,'interface');

end


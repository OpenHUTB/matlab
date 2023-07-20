function removeInteractiveBehaviors(~,printAxes)






    allObjects=findall(printAxes);


    set(allObjects,'UIContextMenu',[]);
    set(allObjects,'ButtonDownFcn','');
    set(allObjects,'DeleteFcn','');
    set(allObjects,'UserData',[]);
end

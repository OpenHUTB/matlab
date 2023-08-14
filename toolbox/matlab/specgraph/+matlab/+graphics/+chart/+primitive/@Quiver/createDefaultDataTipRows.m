function dataTipRows=createDefaultDataTipRows(hObj)






    if isempty(hObj.ZData)
        dataTipRows=[dataTipTextRow('[X,Y]','[XData,YData]');...
        dataTipTextRow('[U,V]','[UData,VData]')];
    else
        dataTipRows=[dataTipTextRow('[X,Y,Z]','[XData,YData,ZData]');...
        dataTipTextRow('[U,V,W]','[UData,VData,WData]')];
    end
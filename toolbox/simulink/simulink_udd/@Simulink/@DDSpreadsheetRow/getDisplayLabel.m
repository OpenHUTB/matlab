function val=getDisplayLabel(thisObj)



    val='';
    if~isempty(thisObj.ddEntry)
        val=getDisplayLabel(thisObj.ddEntry);
    else
        ddConn=Simulink.dd.open(thisObj.DataSource);
        thisEntry=ddConn.getEntryInfo(thisObj.entryID);
    end





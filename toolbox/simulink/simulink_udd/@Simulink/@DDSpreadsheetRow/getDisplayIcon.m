function val=getDisplayIcon(this)

    val='';
    try
        if~isempty(this.ddEntry)
            val=getDisplayIcon(this.ddEntry);
            variantCondition=this.getPropValue('VariantCondition');
            ddConn=Simulink.dd.open(this.ddEntry.m_ddFilespec);
            val=Simulink.dd.GetVariantIcon(ddConn,val,variantCondition);
        else
            ddConn=Simulink.dd.open(this.DataSource);
            thisEntry=ddConn.getEntryInfo(this.entryID);
            val=getDisplayIcon(thisEntry.Value);
        end
    catch
    end



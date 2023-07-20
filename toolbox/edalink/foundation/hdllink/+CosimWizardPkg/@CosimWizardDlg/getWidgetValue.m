function val=getWidgetValue(this,dlg,tag)

    if~isempty(dlg)
        val=getWidgetValue(dlg,tag);
    else
        val=feval(['l_get',tag,'Value'],this);
    end

end

function val=l_getedaRunTimeValue(this)
    val=this.UserData.ResetRunTimeStr;
end

function val=enableMEMenuItem(this,menustring)



    if isequal(menustring,'TOOLS_OPEN')||isequal(menustring,'TOOLS_DEBUG')
        val=true;
    else
        val=false;
    end



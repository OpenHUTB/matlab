function val=getDisplayLabel(this)



    if strcmpi(this.Type,'TflEntry')
        val=this.Name;
    else
        if this.isDirty
            val=[this.Name,'*'];
        else
            val=this.Name;
        end
    end




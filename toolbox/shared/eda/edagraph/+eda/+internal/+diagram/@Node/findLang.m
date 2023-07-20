function lang=findLang(this)





    parent=this.getParent;
    lang='';
    if isempty(parent)
        return;
    end

    if~strcmpi(parent.Partition.Type,'MIXED')
        if isempty(parent.Partition.Lang)
            lang=this.findLang;
            parent.Partition.Lang=lang;
        else
            lang=parent.Partition.Lang;
        end
    end



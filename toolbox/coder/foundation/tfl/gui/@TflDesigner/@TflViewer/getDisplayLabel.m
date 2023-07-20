function val=getDisplayLabel(this)



    switch this.Type
    case 'TargetRegistry'
        val='All code replacement libraries';
    case 'TflControl'
        val='TflControl';
    case 'TflRegistry'
        val=this.Content.Name;
    case 'TflTable'
        val=this.Content.Name;
    case 'TflCustomization'
        val=this.Content.Key;
    case 'TflEntry'
        val=this.Content.Key;
    case 'TflCFunctionEntry'
        val=this.Content.Key;
    otherwise
        val='';
    end





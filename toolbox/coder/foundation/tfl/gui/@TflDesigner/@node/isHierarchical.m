function propValue=isHierarchical(this)




    if strcmpi(this.Type,'TflEntry')
        propValue=false;
    else
        propValue=true;
    end
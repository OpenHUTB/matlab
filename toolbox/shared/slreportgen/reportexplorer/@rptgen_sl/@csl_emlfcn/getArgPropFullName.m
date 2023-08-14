function fullname=getArgPropFullName(this,prop)





    map=this.FullArgPropNamesMap;
    fullname=map{2,strcmp(map(1,:),prop)};






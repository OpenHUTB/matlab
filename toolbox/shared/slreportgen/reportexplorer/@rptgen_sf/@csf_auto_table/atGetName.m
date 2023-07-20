function oName=atGetName(this,ps,d,obj,objType)




    switch this.NameType
    case 'slsfname'
        oName=ps.getSLSFPath(obj,d);
    case 'sfname'
        oName=ps.getSFPath(obj,d);
    otherwise
        oName=ps.getObjectName(obj,objType);
    end

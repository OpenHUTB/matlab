function oName=name_getName(c,ps,obj,objType,d,varargin)





    switch c.NameType
    case 'slsfname'
        oName=ps.getSLSFPath(obj,d);
    case 'sfname'
        oName=ps.getSFPath(obj,d);
    otherwise
        oName=ps.getObjectName(obj,objType);
    end

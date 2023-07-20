function oType=getObjectType(ps,obj)





    if nargin>1&ishandle(obj)
        fullClsName=class(obj);
        clsName=strsplit(fullClsName,'.');
        clsName=clsName{end};
        oType=rptgen.capitalizeFirst(clsName);
        if isa(obj,'Stateflow.State')
            oType=[obj.Type,' ',oType];
        end
    else
        oType='Stateflow';
    end

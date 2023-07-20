function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CR5MbwAAVLjK9joFYFsLCBM7cMMKOQTCXXsFn9mARj/K3vmsEmGmaU0xFM'...
        ,'j+bVM9zEnLdvMphGFVN7gVvIM51Fc3NQeTKIfNU5cuo5rim0jvdwPWtNiz7R'...
        ,'ra1GCIeugLeOdwOfbxK38WtDADDdQbhcHSvnVEmphCFJfmbOX++d/yleDO5u'...
        ,'ssAAKK4vi8uwNzJMW/5UHau0OLKaLA=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end
function obj=setAll(obj,val)
    nargoutchk(1,1);
    param=obj.getAllPropNames;
    for k=1:length(param)
        obj.(param{k})=val;
    end
end

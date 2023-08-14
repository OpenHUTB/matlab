function rtn=getPropIndex(obj)
    ctr=0;
    for i=1:numel(obj.OptimStruct.PropertyNames)

        propval=getProperty(obj,obj.OptimStruct.PropertyNames{i});
        if isscalar(propval)
            ctr=ctr+1;
            propIndex{i}=num2str(ctr);
        else
            ctrstart=ctr+1;
            ctr=ctr+numel(propval);
            propIndex{i}=num2str(ctrstart:ctr);
        end
    end
    rtn=propIndex;
end
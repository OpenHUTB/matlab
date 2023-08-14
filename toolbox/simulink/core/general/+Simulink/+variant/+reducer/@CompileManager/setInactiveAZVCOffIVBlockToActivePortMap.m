function setInactiveAZVCOffIVBlockToActivePortMap(obj,val)






    for iter=1:numel(val)
        name=val(iter).VariantBlock;
        choice=val(iter).ActivePort;

        if obj.InactiveAZVCOffIVBlockToActivePortMap.isKey(name)
            obj.InactiveAZVCOffIVBlockToActivePortMap(name)=unique([choice,obj.InactiveAZVCOffIVBlockToActivePortMap(name)]);
        else
            obj.InactiveAZVCOffIVBlockToActivePortMap(name)=choice;
        end
    end

end

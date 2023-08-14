function nominalValues=serializeSimscapeNominalValues(value,unit)







    if~(iscell(value)&&iscell(unit))||(numel(value)~=numel(unit))
        pm_error('physmod:simscape:simscape:nominal:nominal:InvalidNominalValueUnits');
    end

    nominalValues=jsonencode(struct('value',value,'unit',unit));

end

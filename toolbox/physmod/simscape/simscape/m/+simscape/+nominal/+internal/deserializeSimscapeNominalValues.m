function nominalValues=deserializeSimscapeNominalValues(nominalValueStr)







    try
        nominalValues=jsondecode(nominalValueStr);
    catch ME %#ok<NASGU>
        pm_error('physmod:simscape:simscape:nominal:nominal:InvalidModelNominalValue');
    end

    if isempty(nominalValues)
        nominalValues=struct('value',{},'unit',{});
    else
        if~isstruct(nominalValues)||...
            ~(isfield(nominalValues,'value')&&isfield(nominalValues,'unit'))

            pm_error('physmod:simscape:simscape:nominal:nominal:InvalidModelNominalValue');
        end

        validValues=cellfun(@ischar,{nominalValues.value});
        validUnits=cellfun(@ischar,{nominalValues.unit});

        if~all(validValues(:))||~all(validUnits(:))
            pm_error('physmod:simscape:simscape:nominal:nominal:InvalidModelNominalValue');
        end
    end

end

function default=nesl_getvariabledefaults(theVariable)











    default.specify='off';

    default.unit=theVariable.default.value.unit;
    if pm_isunit(default.unit)
        default.unit=pm_canonicalunit(default.unit);
    end
    nesl_mat2str=nesl_private('nesl_mat2str');
    ic=theVariable.default.value;
    default.value=nesl_mat2str(value(ic,default.unit));
    default.priority=lSimscapePriorityToBlockPriority(theVariable.default.priority);


    default.nominalSpecify='off';
    default.nominalUnit=theVariable.default.nominal.unit;
    if pm_isunit(default.nominalUnit)
        default.nominalUnit=pm_canonicalunit(default.nominalUnit);
    end
    nv=theVariable.default.nominal;
    default.nominalValue=nesl_mat2str(value(nv,default.nominalUnit));

end

function d=lSimscapePriorityToBlockPriority(p)
    high='High';
    low='Low';
    none='None';

    switch(p)
    case{simscape.priority.high}
        d=high;
    case{simscape.priority.low}
        d=low;
    case{simscape.priority.none}
        d=none;
    otherwise
        d=high;
    end
end
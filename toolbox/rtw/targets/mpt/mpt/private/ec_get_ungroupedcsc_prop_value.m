function value=ec_get_ungroupedcsc_prop_value(attri,cscdef,propname)





    assert(~isempty(cscdef));
    value='';

    if cscdef.IsGrouped
        return;
    end

    switch propname
    case 'DataScope'
        IsInstanceSpecific='IsDataScopeInstanceSpecific';
    case 'DataInit'
        IsInstanceSpecific='IsDataInitInstanceSpecific';
    case 'DefinitionFile'
        IsInstanceSpecific='IsDefinitionFileInstanceSpecific';
    case 'HeaderFile'
        IsInstanceSpecific='IsHeaderFileInstanceSpecific';
    otherwise
        assert(false,'Unexpected property name');
    end

    if~cscdef.(IsInstanceSpecific)

        value=cscdef.(propname);
    else

        assert(isstruct(attri),'argument attri must be a struct');
        if isfield(attri,propname)
            value=attri.(propname);
        else
            assert(false,[propname,' property does not exist']);
        end

        value=strtrim(value);
    end




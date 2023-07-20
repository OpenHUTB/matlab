function initialize(this)





    this.Version='1.0';
    this.attachAllSubComponents;
    this.setListeners;

    ccProps=this.getClientProperties(true);

    for idx=1:numel(ccProps)
        prop=ccProps(idx);
        lDefaultValue(this,prop);
    end


end

function lDefaultValue(this,prop)


    if isempty(prop.DefaultValue)
        return;
    end

    dv=prop.DefaultValue;

    if isa(prop.DefaultValue,'function_handle')
        dv=prop.DefaultValue(this,prop);
    end

    this.(prop.Name)=dv;

end

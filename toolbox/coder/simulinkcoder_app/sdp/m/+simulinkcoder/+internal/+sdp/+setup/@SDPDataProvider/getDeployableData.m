function[data,meta]=getDeployableData(obj,id,role)

    data=mdom.Data;
    data.setProp('checked',role~=0);
    data.setProp('label','');

    meta=mdom.MetaData;
    if role<2
        meta.setProp('interactiveRenderer','CheckboxRenderer');
    else
        meta.setProp('renderer','CheckboxRenderer');
    end
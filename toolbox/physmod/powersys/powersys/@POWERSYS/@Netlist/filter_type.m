function idx=filter_type(nl,type)

    mask_types=get_param(nl.elements,'MaskType');
    idx=find(strcmp(mask_types,type));





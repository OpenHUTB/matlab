function[out,dscr]=targetLangStandard_entries(cs,name)




    dscr=[name,'''s enum option is determined by TargetLang'];

    targetLang=cs.getProp('TargetLang');
    owner=cs.getPropOwner(name);
    value=owner.getProp(name);
    allowedValues=owner.getPropAllowedValues(name);

    cppIdx=strncmpi('C++',allowedValues,3);
    currentIdx=strcmpi(value,allowedValues);
    if strncmpi('C++',targetLang,3)


        vals=allowedValues(cppIdx|currentIdx);
    else


        vals=allowedValues(~cppIdx|currentIdx);
    end

    out=struct('str',vals);



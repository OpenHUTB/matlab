function schema

    pk=findpackage('cv');



    c=schema.class(pk,'cvtestgroup');

    visibility='on';
    privateVisibility='off';








    p=schema.prop(c,'name','string');
    p.FactoryValue='';
    p.Visible=visibility;





    p=schema.prop(c,'m_data','mxArray');
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';
    p.Visible=privateVisibility;
    p.GetFunction=@lGetInternalMap;





    function val=lGetInternalMap(~,val)
        if~isa(val,'containers.Map')
            val=containers.Map('KeyType','char','ValueType','any');
        end

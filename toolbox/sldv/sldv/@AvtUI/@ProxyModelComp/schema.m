function schema




    sldvExplorerPackage=findpackage('AvtUI');
    hDeriveFromClass=findclass(sldvExplorerPackage,'MEProxy');

    hThisClass=schema.class(sldvExplorerPackage,'ProxyModelComp',hDeriveFromClass);
    schema.prop(hThisClass,'uiParent','handle');


    schema.prop(hThisClass,'label','ustring');
    schema.prop(hThisClass,'iconPath','ustring');




    add_method('getDialogSchema',{'handle','string'},{'mxArray'});

    add_method('getDisplayIcon',{'handle'},{'ustring'});
    add_method('getDisplayLabel',{'handle'},{'ustring'});
    add_method('getHierarchicalChildren',{'handle'},{'handle vector'});
    add_method('isHierarchical',{'handle'},{'bool'});
    add_method('dialogCallback',{'handle','string'},{});
    add_method('getContextMenu',{'handle','handle vector'},{'handle'});

    function add_method(name,inTypes,outTypes)
        m=schema.method(hThisClass,name);
        s=m.Signature;
        s.varargin='off';
        s.InputTypes=inTypes;
        s.OutputTypes=outTypes;
    end
end

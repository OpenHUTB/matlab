function attachPropertyListeners(thisConfigSet)




    [pname,cname]=strtok(class(thisConfigSet),'.');
    cname=strtok(cname,'.');

    pkg=findpackage(pname);
    cls=findclass(pkg,cname);

    pCls=cls.SuperClass;
    clsProps=cls.properties;
    pClsProps=pCls.properties;




    cNames=arrayfun(@getName,clsProps,'UniformOutput',false);
    pNames=arrayfun(@getName,pClsProps,'UniformOutput',false);
    [~,idx]=setdiff(cNames,[pNames(:);{[cls.Name,'ChangeListeners']}]);
    lprops=clsProps(idx);

    if~isempty(lprops)
        list=handle.listener(thisConfigSet,lprops,'PropertyPostSet',@propertyChanged);
        list.CallbackTarget=thisConfigSet;
        appendListeners(thisConfigSet,list,cls.Name);
    end

end

function appendListeners(clsInst,listnr,clsName)

    if isempty(clsInst.([clsName,'ChangeListeners']))
        clsInst.([clsName,'ChangeListeners'])=listnr;
    else
        clsInst.ChangeListeners(end+1)=listnr;
    end
end

function name=getName(prop)
    name=prop.Name;
end
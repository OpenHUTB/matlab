function newChoice=addChoicesToVariantComponent(varSS,name,condition)





    assert(strcmpi(get_param(varSS,'Variant'),'on'),'Input must be a variant component');

    if nargin>1
        assert(isstring(name)&&isscalar(name),"Name must be a string");
        if nargin>2
            assert(isstring(condition)&&isscalar(condition),...
            "Condition must be a string or string array");
        end
    else
        name="Component";
    end

    try
        txn=systemcomposer.internal.arch.internal.AsyncPluginTransaction(bdroot(varSS));


        varrSSName=strrep(get_param(varSS,'Name'),'/','//');
        varSSPath=[get_param(varSS,'Parent'),'/',varrSSName];
        newChoice=addvsschoiceddg_cb(varSSPath,'SubSystem',char(name));
        pos=get_param(newChoice,'position');
        set_param(newChoice,'position',[pos(1:2),pos(3)+80,pos(4)+50]);

        txn.commit();

    catch ME

        txn.commit();
        rethrow(ME);
    end

end

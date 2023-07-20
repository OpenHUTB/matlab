function v=validateBlock(this,hC)%#ok





    v=hdlvalidatestruct;

    slh=hC.SimulinkHandle;
    tagvis=get_param(slh,'TagVisibility');
    if strcmpi(tagvis,'scoped')&&strcmpi(hdlfeature('ScopedGotoBlockSupport'),'off')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:scopedfrom'));
    end


function v=validateBlock(this,hC)%#ok





    v=hdlvalidatestruct;

    if strcmpi(hdlfeature('ScopedGotoBlockSupport'),'off')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:scopedfrom'));
    end

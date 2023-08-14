function type=getTypeStr(val,sid)




    try
        if slci.internal.isStateflowBasedBlock(sid)
            value=slResolve(val,sid,...
            'expression','startUnderMask');
        else
            value=slResolve(val,sid);
        end
        type=class(value);
    catch Exception %#ok
        type='';
    end
end



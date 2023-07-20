function utdeepcopy(h,hout)















    c=classhandle(h);

    props=c.Properties;

    for k=1:length(props)
        axflags=get(props(k),'AccessFlags');
        if strcmp(axflags.Serialize,'on')
            propval=get(h,props(k).Name);
            newpropval=propval;
            for j=1:length(propval)
                if any(strcmp(props(k).DataType,{'handle','handle vector'}))||...
                    strcmpi(props(k).Name,'Events')
                    newpropval(j)=copy(propval(j));
                end
            end
            set(hout,props(k).Name,newpropval)
        end
    end

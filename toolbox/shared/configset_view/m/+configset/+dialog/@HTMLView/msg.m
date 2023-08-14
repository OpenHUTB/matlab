function msg(obj,request)



    data=request.data;
    adp=obj.Source;
    cs=adp.getCS;
    if isempty(cs)
        return
    end

    n=length(data);
    out=cell(n,1);

    for i=1:n
        d=data(i);
        name=d.name;
        s=d.f;
        list=fieldnames(s);
        for j=1:length(list)
            prop=list{j};
            fstr=s.(prop);
            switch prop
            case 'value'
                value=adp.getParamValue(name);
                [s.value,s.converted]=configset.util.mat2json(value);
            case 'options'
                fn=str2func(fstr);
                av=fn(cs,name);
                m=length(av);
                opts=cell(m,1);
                for k=1:m
                    a=av(k);
                    w.value=a.str;
                    if isfield(a,'disp')
                        w.label=a.disp;
                    elseif isfield(a,'key')&&~isempty(a.key)
                        w.label=configset.internal.getMessage(a.key);
                    else
                        w.label=a.str;
                    end
                    opts{k}=w;
                end
                s.(prop)=opts;
            case 'wv'
                fn=str2func(fstr);
                s.(prop)=fn(cs,name,0);
            case 'st'
                fstr=s.st;
                n=length(fstr);
                vs=zeros(n,1);
                for k=1:n
                    fn=str2func(fstr{k});
                    vs(k)=fn(cs,name);
                end
                s.(prop)=max(vs);
            otherwise
                fn=str2func(s.(prop));
                s.(prop)=fn(cs,name);
            end
        end
        d.f=s;
        out{i}=d;
    end



    msg.id=request.id;
    msg.data=out;
    obj.publish('msg',msg);



function layout(obj,msg)



    cs=obj.Source.getCS;
    n=length(msg);
    ret=cell(n,1);
    for i=1:n
        d=msg(i);
        fn=str2func(d.f);
        ret{i}=fn(cs,'web');
        ret{i}.id=d.id;
    end


    obj.publish('layout',ret);


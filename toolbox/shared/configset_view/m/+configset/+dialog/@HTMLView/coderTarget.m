function coderTarget(obj,data)



    cs=obj.Source.getCS;
    hObj=cs.getComponent('Coder Target');
    ct=hObj.CoderTargetData;
    n=length(data);
    ret=cell(n,1);
    for i=1:length(data)
        d=data(i);
        r=[];
        r.id=d.id;
        f=d.f;
        m=length(f);
        r.f=cell(m,1);
        for j=1:m
            prop=f{j}{1};
            str=f{j}{2};
            try
                val=eval(str);
            catch
                val=str;
            end
            r.f{j}={prop,val};
        end
        ret{i}=r;
    end


    out.ct=ct;
    out.params=ret;
    obj.publish('coderTarget',out);


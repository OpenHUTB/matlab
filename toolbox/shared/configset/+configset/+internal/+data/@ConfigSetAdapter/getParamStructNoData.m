function s=getParamStructNoData(obj,name)







    s.name=name;
    cs=obj.Source;

    value=cs.getProp(name);
    [s.value,s.converted]=configset.internal.util.partialConversionToJSON(value);

    cc=cs.getPropOwner(name);
    s.locked=cc.isReadonlyProperty(name);

    avail=cc.getPropAllowedValues(name);
    if isempty(avail)
        s.type=configset.util.deduceType(value);
    else
        s.type='enum';
        n=length(avail);
        opts=cell(n,1);
        for j=1:n
            x.label=avail{j};
            x.value=avail{j};
            opts{j}=x;
        end
        s.options=opts;
    end

    s.status=0;
    s.hidden=false;
    s.prompt=name;
    s.tooltip=' ';
    s.component=class(cc);


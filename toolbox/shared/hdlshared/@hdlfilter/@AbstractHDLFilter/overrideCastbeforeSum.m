function oldcastbeforesum=overrideCastbeforeSum(this,filterobj,value)






    if nargin==2
        value=logical(hdlgetparameter('cast_before_sum'));
    end

    if isa(filterobj,'dfilt.cascade')
        len=length(filterobj.Stage);
        value=repmat(value,1,len);
        oldcastbeforesum=zeros(1,len);
        for n=1:len
            if any(strcmpi('castbeforesum',fieldnames(get(filterobj.Stage(n)))))
                oldcastbeforesum(n)=get(filterobj.Stage(n),'CastBeforeSum');
                if(get(filterobj.Stage(n),'CastBeforeSum')~=value(n))
                    try
                        set(filterobj.Stage(n),'CastBeforeSum',value(n));
                    catch
                    end
                end
            end
        end
    else
        oldcastbeforesum=false;
        if any(strcmpi('castbeforesum',fieldnames(get(filterobj))))
            oldcastbeforesum=get(filterobj,'CastBeforeSum');
            if(get(filterobj,'CastBeforeSum')~=value)
                try
                    set(filterobj,'CastBeforeSum',value);
                catch
                end
            end
        end
    end
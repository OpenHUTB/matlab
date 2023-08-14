function out=get(this,prop)




    narginchk(2,2);

    if~ischar(prop)&&~isStringScalar(prop)
        this.throwError('slrealtime:target:invalidPropertyName');
    end

    if~contains(prop,'.')
        if isprop(this,prop)
            out=this.(prop);
        else
            this.throwError('slrealtime:target:notTargetProperty',prop);
        end
    else

        props=split(prop,'.');
        numProps=length(props);
        obj=this;
        for i=1:(numProps-1)
            obj=obj.(char(props(i)));
        end

        if isprop(obj,char(props(numProps)))
            out=obj.(char(props(numProps)));
        elseif sum(strcmp(fieldnames(obj),char(props(numProps))))==1
            out=obj.(char(props(numProps)));
        else
            this.throwError('slrealtime:target:notTargetProperty',prop);
        end

    end

end
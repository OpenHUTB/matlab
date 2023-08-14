function set(this,prop,val)




    narginchk(3,3);

    if~ischar(prop)&&~isstring(prop)
        this.throwError('slrealtime:target:invalidPropertyName');
    elseif~isprop(this,prop)
        this.throwError('slrealtime:target:notTargetProperty',prop);
    end

    this.(prop)=val;

end
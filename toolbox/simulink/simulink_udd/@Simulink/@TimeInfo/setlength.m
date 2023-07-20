function this=setlength(this,newlen)


    if~isequal(this.Length,newlen)
        this.Length_=newlen;
        this.Increment=NaN;
    end
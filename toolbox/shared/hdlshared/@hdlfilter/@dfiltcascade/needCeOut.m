function status=needCeOut(this)





    status=true;
    if strcmpi(this.Implementation,'localmultirate')
        status=false;
    end




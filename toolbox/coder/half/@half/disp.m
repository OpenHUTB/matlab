function disp(this)

    currentFormat=get(0,'Format');

    if~strcmp(currentFormat,'hex')
        tmp=single(this);
    else
        tmp=storedInteger(this);
    end

    if(isreal(this))
        disp(tmp);
    else
        disp(complex(tmp));
    end

end

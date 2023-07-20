function level=getNonAsciiMessageLevel(this)


    if(this.CalledFromMakehdl)
        level='Warning';
    else
        level='Message';
    end

end


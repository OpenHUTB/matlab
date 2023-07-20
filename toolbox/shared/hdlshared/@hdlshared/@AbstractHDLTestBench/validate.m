function validate(this)



    if isempty(this.InportSrc)&&isempty(this.OutportSnk)
        error(message('HDLShared:hdlshared:nodataerror'));
    end



    if isempty(this.OutportSnk)&&isempty(this.InportSrc)
        error(message('HDLShared:hdlshared:noinputandoutputerror'));
    end

function next2Last=findNext2LastValue(this,signed,numberOfBits,bp)



















    lastValue=fi(this.CountToValue,signed,numberOfBits,bp,'overflowMode','wrap');
    stepValue=fi(this.Stepvalue,signed,numberOfBits,bp,'overflowMode','wrap');

    if isempty(this.cnt_dir)
        a=fi((lastValue-stepValue),signed,numberOfBits,bp,'overflowMode','wrap');
        next2Last(1)=a.double;
    else
        a=fi((lastValue-abs(stepValue)),signed,numberOfBits,bp,'overflowMode','wrap');
        b=fi((lastValue+abs(stepValue)),signed,numberOfBits,bp,'overflowMode','wrap');
        next2Last(1)=a.double;
        next2Last(2)=b.double;
    end



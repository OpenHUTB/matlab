function outdata=getoutputvectors(this,filterobj,indata)









    outdata=filter(filterobj,indata);
    if strcmpi(filterobj.Arithmetic,'double')&&~all(isfinite(outdata))
        error(message('HDLShared:hdlfilter:nonefinitenumber'));
    end





















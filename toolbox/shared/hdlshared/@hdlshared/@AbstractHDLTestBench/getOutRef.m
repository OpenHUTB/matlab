function[hdlbody,hdlsignals]=getOutRef(this,outref,signame,expected)%#ok







    hdlsignals='';
    hdlbody='';

    isVhdl=hdlgetparameter('isvhdl');

    for i=1:length(outref)
        if isVhdl
            hdlbody=[hdlbody,'  ',hdlsignalname(outref(i)),' <= ',expected{i},';\n'];%#ok<AGROW>
        else
            hdlbody=[hdlbody,'  assign ',hdlsignalname(outref(i)),' = ',expected{i},';\n'];%#ok<AGROW>                
        end
    end
end
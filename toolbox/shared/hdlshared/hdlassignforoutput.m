function[assign_prefix,assign_op]=hdlassignforoutput(out)





    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);
    [outsize,~,~]=hdlwordsize(outsltype);

    seq=hdlsequentialcontext;

    if hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog')
        if outsize==0
            if seq
                assign_prefix='';
            else
                assign_prefix='always @* ';
            end
            assign_op='<=';
        elseif strcmpi(outvtype(1:3),'reg')||seq
            assign_prefix='';
            assign_op='<=';
        else
            assign_prefix=hdlgetparameter('assign_prefix');
            assign_op=hdlgetparameter('assign_op');
        end
    else
        assign_prefix=hdlgetparameter('assign_prefix');
        assign_op=hdlgetparameter('assign_op');
    end





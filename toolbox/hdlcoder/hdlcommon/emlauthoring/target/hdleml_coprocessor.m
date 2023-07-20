%#codegen
function[out_ready,dut_enable,reg_strobe]=hdleml_coprocessor(in_strobe,cnt_limit)




    coder.allowpcode('plain')
    eml_prefer_const(cnt_limit);

    persistent cpstate clkcnt
    if isempty(cpstate)
        cpstate=uint8(0);
        clkcnt=fi(0,numerictype(cnt_limit),fimath(cnt_limit));
    end

    switch uint8(cpstate)

    case 0
        out_ready=true;
        dut_enable=false;
        reg_strobe=false;
        clkcnt(:)=0;

        if in_strobe
            cpstate(:)=1;
        else
            cpstate(:)=0;
        end

    case 1
        out_ready=false;
        dut_enable=true;
        reg_strobe=false;
        clkcnt(:)=clkcnt+1;

        if clkcnt==cnt_limit
            cpstate(:)=2;
        else
            cpstate(:)=1;
        end

    case 2
        out_ready=false;
        dut_enable=false;
        reg_strobe=true;

        clkcnt(:)=0;
        cpstate(:)=0;

    otherwise
        out_ready=false;
        dut_enable=false;
        reg_strobe=false;

        clkcnt(:)=0;
        cpstate(:)=0;

    end

end



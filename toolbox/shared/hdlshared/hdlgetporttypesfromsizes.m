function[vtype,sltype]=hdlgetporttypesfromsizes(insize,inbp,insigned)





    if insize==0
        if hdlgetparameter('isvhdl')
            vtype='real';
        else
            vtype='wire [63:0]';
        end
    elseif insize==1
        vtype=hdlgetparameter('base_data_type');
    elseif hdlgetparameter('isvhdl')
        vtype=['std_logic_vector(',num2str(insize-1),' DOWNTO 0)'];
    elseif hdlgetparameter('isverilog')
        if insigned==1
            vtype=['wire signed [',num2str(insize-1),':0]'];
        else
            vtype=['wire [',num2str(insize-1),':0]'];
        end
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end

    sltype=hdlgetsltypefromsizes(insize,inbp,insigned);




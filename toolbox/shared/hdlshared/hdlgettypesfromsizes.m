function[vtype,sltype]=hdlgettypesfromsizes(insize,inbp,insigned)





    if insize==0
        vtype='real';
    elseif insize==1
        vtype=hdlgetparameter('base_data_type');
    elseif hdlgetparameter('isvhdl')
        if insigned==1
            vtype=['signed(',num2str(insize-1),' DOWNTO 0)'];
        else
            vtype=['unsigned(',num2str(insize-1),' DOWNTO 0)'];
        end
    elseif hdlgetparameter('isverilog')
        if insigned==1
            vtype=['wire signed [',num2str(insize-1),':0]'];
        else
            vtype=['wire [',num2str(insize-1),':0]'];
        end
    elseif hdlgetparameter('issystemverilog')
        if insigned==1
            vtype=['logic signed [',num2str(insize-1),':0]'];
        else
            vtype=['logic [',num2str(insize-1),':0]'];
        end
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end

    sltype=hdlgetsltypefromsizes(insize,inbp,insigned);




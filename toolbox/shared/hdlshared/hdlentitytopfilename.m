function filename=hdlentitytopfilename















    topname=hdlentitytop;

    if isempty(topname)
        filename='';
    else

        tlang=hdlgetparameter('target_language');

        if isempty(tlang)
            suffix=hdlgetparameter('filename_suffix');
        elseif strcmpi(tlang,'vhdl')
            suffix=hdlgetparameter('vhdl_file_ext');
        else
            suffix=hdlgetparameter('verilog_file_ext');
        end

        if hdlgetparameter('isvhdl')&&hdlgetparameter('split_entity_arch')
            filename={[topname,...
            hdlgetparameter('split_entity_file_postfix'),...
            suffix],...
            [topname,...
            hdlgetparameter('split_arch_file_postfix'),...
            suffix]};
        else
            filename=[topname,suffix];
        end
    end




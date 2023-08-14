function filenames=hdlentityfilenames


















    names=hdlentitynames;

    if isempty(names)
        filenames={};
    else

        if hdlisfiltercoder
            tlang=hdlgetparameter('lasttopleveltargetlang');
        else


            tlang=hdlgetparameter('target_language');
        end

        if isempty(tlang)
            suffix=hdlgetparameter('filename_suffix');
        elseif strcmpi(tlang,'vhdl')
            suffix=hdlgetparameter('vhdl_file_ext');
        else
            suffix=hdlgetparameter('verilog_file_ext');
        end

        if hdlgetparameter('isvhdl')&&hdlgetparameter('split_entity_arch')
            if hdlgetparameter('vhdl_package_required')
                package_name=names{1};
                names=names(2:end);
            end

            entity_names=strcat(names,...
            hdlgetparameter('split_entity_file_postfix'),...
            suffix);
            arch_names=strcat(names,...
            hdlgetparameter('split_arch_file_postfix'),...
            suffix);
            if hdlgetparameter('vhdl_package_required')
                filenames={[package_name,suffix]};
            else
                filenames={};
            end
            for n=1:length(names)
                filenames{end+1}=entity_names{n};
                filenames{end+1}=arch_names{n};
            end
        else
            filenames=strcat(names,suffix);
        end
    end




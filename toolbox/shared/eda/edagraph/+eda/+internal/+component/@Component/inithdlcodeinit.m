function hdlcode=inithdlcodeinit(this)








    oldLang=hdlgetparameter('target_language');
    hdlsetparameter('target_language',this.Partition.Lang);

    hdlcode=this.hdlcodeinit;
    hdlcode.entity_comment=hdlCopyRightHeader(this.UniqueName);

    if hdlgetparameter('isvhdl')

        hdlcode.entity_library=('LIBRARY IEEE;\nUSE IEEE.std_logic_1164.all;\nUSE IEEE.numeric_std.ALL;\n\n\n');
        hdlcode.entity_ports='PORT (\n';


        if~isempty(findVendorLib(this,'xilinx'))||isprop(this,'use_xlinx_unisim')
            hdlcode.entity_library=[hdlcode.entity_library,...
            '-- Required Xilinx Library\n',...
            'USE IEEE.STD_LOGIC_ARITH.all;\n',...
            'USE IEEE.STD_LOGIC_UNSIGNED.all;\n\n',...
            'LIBRARY UNISIM;\nUSE UNISIM.VComponents.all;\n\n'];
        end

        hdlcode.arch_decl=['\nARCHITECTURE rtl of ',this.UniqueName,' IS\n\n'];

        hdlcode.arch_begin='\nBEGIN\n\n';

        hdlcode.arch_end='\nEND;\n';

    else
        hdlcode.arch_end='\nendmodule\n';

    end

    hdlsetparameter('target_language',oldLang);
end



function lib=findVendorLib(this,str)

    meta=metaclass(this);
    lib=findrecursive(meta,str);
end

function lib=findrecursive(meta,str)
    lib='';
    if~isempty(meta.ContainingPackage)
        lib=strfind(meta.ContainingPackage.Name,str);
        if isempty(lib)
            if~isempty(meta.SuperClasses)
                for i=1:length(meta.SuperClasses)
                    lib=findrecursive(meta.SuperClasses{i},str);
                end
            end
        end
    else
        if~isempty(meta.SuperClasses)
            for i=1:length(meta.SuperClasses)
                lib=findrecursive(meta.SuperClasses{i},str);
            end
        end
    end

end




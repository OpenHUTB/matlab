
classdef HDLKeywords
    methods(Static,Access=public)


        function flag=check_ReservedWord(id)
            p=pir();
            check_kw=@(kw_list_name)(p.isReservedWordInLang(id,kw_list_name));
            flag=check_kw('VERILOG');%#ok<*CPROP>
            flag=flag||check_kw('VHDL');
            flag=flag||check_kw('VERILOG2001');
            flag=flag||check_kw('SYSTEMVERILOG');
            flag=flag||check_kw('EDIF');
            flag=flag||check_kw('SDF');
            flag=flag||check_kw('CKT');
        end
    end
end




classdef hdlsynthtoolenum
    enumeration
        None,Quartus,Quartuspro,ISE,Vivado
    end
    methods
        function whichtool=isQuartus(obj)
            whichtool=(hdlsynthtoolenum.Quartus==obj);
        end
        function whichtool=isQuartuspro(obj)
            whichtool=(hdlsynthtoolenum.Quartuspro==obj);
        end
        function whichtool=isISE(obj)
            whichtool=(hdlsynthtoolenum.ISE==obj);
        end
        function whichtool=isVivado(obj)
            whichtool=(hdlsynthtoolenum.Vivado==obj);
        end

        function vendor=isAltera(obj)
            vendor=(hdlsynthtoolenum.Quartus==obj);
        end

        function vendor=isXilinx(obj)
            vendor=~(hdlsynthtoolenum.Quartus==obj);
        end

        function toolstrrep=getToolStr(obj)
            switch(obj)
            case hdlsynthtoolenum.Quartus
                toolstrrep='Altera QUARTUS II';
            case hdlsynthtoolenum.Quartuspro
                toolstrrep='Intel Quartus Pro';
            case hdlsynthtoolenum.ISE
                toolstrrep='Xilinx ISE';
            case hdlsynthtoolenum.Vivado
                toolstrrep='Xilinx Vivado';
            otherwise
                toolstrrep='None';
            end
        end
    end
end
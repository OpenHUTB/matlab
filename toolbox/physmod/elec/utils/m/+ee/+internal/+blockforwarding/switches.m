function out=switches(in)










    out=in;


    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.switch.elec')
        out=out.setNewBlockPath('pe_lib/Deprecated/Single-Phase Switch (electrical control port)');
        out=out.setClass('pe.deprecated.fundamental.switch.elec');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.switch.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/SPST Switch');
        out=out.setClass('ee.switches.spst_ps');
        out=out.setValue('Threshold',in.getValue('threshold'));
        out=out.setValue('Threshold_unit',in.getValue('threshold_unit'));
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.two_way_switch.elec')
        out=out.setNewBlockPath('pe_lib/Deprecated/Single-Phase Two-Way Switch (electrical control port)');
        out=out.setClass('pe.deprecated.fundamental.two_way_switch.elec');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.two_way_switch.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/SPDT Switch');
        out=out.setClass('ee.switches.spdt_ps');
        out=out.setValue('Threshold',in.getValue('threshold'));
        out=out.setValue('Threshold_unit',in.getValue('threshold_unit'));
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.circuit_breaker.elec.Xabc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.elec.Xabc');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.circuit_breaker.elec.abc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.elec.abc');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.circuit_breaker.elec')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker');
        out=out.setClass('ee.switches.fundamental.circuit_breaker.elec');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.circuit_breaker_arc.elec')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (with arc)');
        out=out.setClass('ee.switches.fundamental.circuit_breaker_arc.elec');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.circuit_breaker.elec.Xabc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.elec.Xabc');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.circuit_breaker.elec.abc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.elec.abc');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.fundamental.circuit_breaker.elec')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker');
        out=out.setClass('ee.switches.fundamental.circuit_breaker.elec');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.fundamental.circuit_breaker_arc.elec')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (with arc)');
        out=out.setClass('ee.switches.fundamental.circuit_breaker_arc.elec');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.circuit_breaker.ps.Xabc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.ps.Xabc');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.circuit_breaker.ps.abc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
        out=out.setClass('ee.switches.circuit_breaker.ps.abc');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.circuit_breaker.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker');
        out=out.setClass('ee.switches.fundamental.circuit_breaker.ps');
    end
    if strcmp(in.getValue('SourceFile'),'pe.switches.fundamental.circuit_breaker_arc.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (with arc)');
        out=out.setClass('ee.switches.fundamental.circuit_breaker_arc.ps');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.circuit_breaker.ps.Xabc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.circuit_breaker.ps.abc')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (Three-Phase)');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.fundamental.circuit_breaker.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker');
    end
    if strcmp(in.getValue('SourceFile'),'ee.switches.fundamental.circuit_breaker_arc.ps')
        out=out.setNewBlockPath('ee_lib/Switches & Breakers/Circuit Breaker (with arc)');
    end
end

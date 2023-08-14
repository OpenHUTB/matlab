classdef(Abstract)AbstractIBISComponent<handle&matlab.mixin.Heterogeneous



















    properties
        ComponentName(1,1)string="Unknown"
        Manufacturer(1,1)string="Unknown"
        Rpkg(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        Lpkg(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        Cpkg(1,3){mustBeReal,mustBeFinite}=[0.0,0.0,0.0]
        Pins(1,:){serdes.utilities.mustBeA(Pins,'serdes.internal.ibisami.ibis.IBISPin')}...
        =serdes.internal.ibisami.ibis.IBISPin.empty
        DiffPins(1,:){serdes.utilities.mustBeA(DiffPins,'serdes.internal.ibisami.ibis.IBISDiffPin')}...
        =serdes.internal.ibisami.ibis.IBISDiffPin.empty
        isRepeater=false
    end
    methods
        function ibisString=getIBISString(component,prettyPrint)
            if prettyPrint
                indent="    ";
            else
                indent="";
            end
            ibisString="|***************************************************************************"+newline+...
            "| COMPONENT "+component.ComponentName+newline+...
            "|***************************************************************************"+newline;
            ibisString=ibisString+string(sprintf('[Component]       %s\n',component.ComponentName));
            ibisString=ibisString+indent+string(sprintf('[Manufacturer]    %s\n',component.Manufacturer));
            ibisString=ibisString+indent+string(sprintf('[Package]\n'));
            ibisString=ibisString+indent+"|              typ         min         max"+newline;
            ibisString=ibisString+indent+indent+string(sprintf('R_pkg          %1.3fm      %1.3fm      %1.3fm\n',component.Rpkg));
            ibisString=ibisString+indent+indent+string(sprintf('L_pkg          %1.3fnH     %1.3fnH     %1.3fnH\n',component.Lpkg));
            ibisString=ibisString+indent+indent+string(sprintf('C_pkg          %1.3fpF     %1.3fpF     %1.3fpF\n',component.Cpkg));
            ibisString=ibisString+indent+"|"+newline;
            ibisString=ibisString+indent+string(sprintf('[Pin]   signal_name     model_name\n'));
            for pinIndex=1:numel(component.Pins)
                pin=component.Pins(pinIndex);
                ibisString=ibisString+pin.getIBISString(indent);
            end
            if~isempty(component.DiffPins)
                ibisString=ibisString+indent+"|"+newline;
                ibisString=ibisString+indent+string(sprintf('[Diff Pin]   inv_pin  vdiff  tdelay_typ tdelay_min tdelay_max\n'));
                for pinIndex=1:numel(component.DiffPins)
                    pin=component.DiffPins(pinIndex);
                    ibisString=ibisString+pin.getIBISString(indent);
                end
                if component.isRepeater
                    ibisString=ibisString+indent+string(sprintf('[Repeater Pin] tx_non_inv_pin\n'));
                    ibisString=ibisString+indent+sprintf('      3      1\n');
                end
            end
            ibisString=ibisString+"|***************************************************************************"+newline+...
            "|***************************************************************************"+newline;
            ibisString=ibisString+"|"+newline;
        end
    end
end


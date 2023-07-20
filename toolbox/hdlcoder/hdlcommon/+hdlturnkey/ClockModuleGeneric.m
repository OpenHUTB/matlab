


classdef ClockModuleGeneric<hdlturnkey.ClockModule


    properties
        hDI=[];
    end

    methods

        function obj=ClockModuleGeneric(hDI)



            obj=obj@hdlturnkey.ClockModule();


            obj.hDI=hDI;
            obj.ClockOutputMHz=0;

        end

        function generateClockConstrain(obj,fid)



            clkName=obj.hDI.hCodeGen.hCHandle.getParameter('clockname');
            clkFreq=obj.ClockOutputMHz;
            toolName=obj.hDI.get('Tool');

            switch lower(toolName)
            case 'xilinx vivado'
                downstream.tool.runInPlugin(obj.hDI,'Plugin_Tcl_Vivado.getTclCreateClockConstraint',fid,clkName,clkFreq);
            case 'xilinx ise'
                downstream.tool.runInPlugin(obj.hDI,'Plugin_Tcl_ISE.getTclCreateClockConstraint',fid,clkName,clkFreq);
            case{'altera quartus ii','intel quartus pro'}
                downstream.tool.runInPlugin(obj.hDI,'Plugin_Tcl_Quartus.getTclCreateClockConstraint',fid,clkName,clkFreq);
            otherwise
                error(message('hdlcommon:workflow:UnsupportedTool',toolName));
            end
        end

        function setClockModuleOutputFreq(obj,val)

            if~isfinite(val)||~isreal(val)||val<0
                error(message('hdlcommon:interface:ClockInterfaceFreqNonNegative'));
            end

            obj.ClockOutputMHz=val;
        end

        function constrainCell=generateFPGAPinConstrain(~)

            constrainCell={};
        end

        function frequency=getClockConstraintTargetFrequency(~)

            frequency=0;
        end

        function constrainCell=extraPinMappingConstrain(~,constrainCell)

        end

        function elaborateClockModule(~,~,~)

        end

    end
end



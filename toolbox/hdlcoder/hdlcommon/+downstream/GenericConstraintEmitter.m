


classdef GenericConstraintEmitter<downstream.ConstraintEmitterBase

    methods
        function obj=GenericConstraintEmitter(hDI)


            obj=obj@downstream.ConstraintEmitterBase(hDI);

        end

        function generateConstraintFile(obj)
            clkFreq=obj.hDI.getTargetFrequency;
            toolName=obj.hDI.get('Tool');
            hN=obj.hDI.hCodeGen.hCHandle.PirInstance.getTopNetwork;



            if clkFreq~=0&&hN.NumberOfPirInputPorts('clock')~=0

                switch lower(toolName)
                case 'xilinx vivado'
                    constrainFileNamePostfix='clock_constraint.xdc';
                case 'xilinx ise'
                    constrainFileNamePostfix='clock_constraint.ucf';
                case{'altera quartus ii','intel quartus pro'}
                    constrainFileNamePostfix='clock_constraint.sdc';
                case 'microchip libero soc'


                    warning(message('hdlcoder:setTargetFrequency:TimingConstraintsUnsupportedLiberoSoC'));
                    return;
                otherwise
                    return;
                end


                ConstrainFilePath=fullfile(obj.hDI.hCodeGen.hCHandle.hdlMakeCodegendir,constrainFileNamePostfix);
                fid=fopen(ConstrainFilePath,'w');
                if fid==-1
                    error(message('hdlcommon:workflow:UnableCreateConstrainFile',ConstrainFilePath));
                end


                obj.generateClockConstrain(fid);

                fclose(fid);


                obj.hDI.hGeneric.GenericFileList={ConstrainFilePath};
            end

        end
    end

end


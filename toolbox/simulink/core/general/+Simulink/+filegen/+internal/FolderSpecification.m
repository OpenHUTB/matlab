classdef FolderSpecification<handle&matlab.mixin.CustomDisplay







    properties(SetAccess=protected)
        Simulation Simulink.filegen.FolderSet;
        CodeGeneration Simulink.filegen.FolderSet;
        HDLGeneration Simulink.filegen.FolderSet;
        Accelerator Simulink.filegen.FolderSet;
        RapidAccelerator Simulink.filegen.FolderSet;
    end

    methods




        function this=FolderSpecification(sim,codegen,hdl,accel,raccel)
            if(nargin==0)
                return;
            end

            this.Simulation=sim;
            this.CodeGeneration=codegen;
            this.HDLGeneration=hdl;
            this.Accelerator=accel;
            this.RapidAccelerator=raccel;
        end
    end

    methods(Access=protected)


        function displayScalarObject(this)
            fprintf('Simulation:\n\n');
            disp(this.Simulation);




            if~isempty(this.CodeGeneration)
                fprintf('CodeGeneration:\n\n');
                disp(this.CodeGeneration);
            end
        end
    end
end

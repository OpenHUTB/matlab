


classdef ConstraintEmitterBase<handle



    properties
        hDI=[];
    end

    methods
        function obj=ConstraintEmitterBase(hDI)


            obj.hDI=hDI;

        end
        function generateClockConstrain(obj,fid)

            fprintf(fid,'\n# Timing Specification Constraints\n\n');


            hClockModule=obj.hDI.getClockModule;
            hClockModule.generateClockConstrain(fid);
        end
    end

end


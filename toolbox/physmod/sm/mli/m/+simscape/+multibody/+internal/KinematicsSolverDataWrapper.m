classdef KinematicsSolverDataWrapper<handle







%#codegen

    properties
mdlName
ksData
    end

    methods
        function obj=KinematicsSolverDataWrapper(mdlName)
            coder.allowpcode('plain');
            obj.mdlName=mdlName;
            obj.ksData=coder.opaque('KinematicsSolverData *','HeaderFile','sm_ssci_KinematicsSolverData.h');
            obj.ksData=coder.ceval([mdlName,'_kinematicsSolverData_create']);
        end

        function delete(obj)
            coder.cinclude([obj.mdlName,'_kinematics.h']);
            coder.ceval([obj.mdlName,'_kinematicsSolverData_destroy'],obj.ksData);
        end
    end

    methods(Static)






        function props=matlabCodegenNontunableProperties(~)
            props={'mdlName'};
        end
    end

end



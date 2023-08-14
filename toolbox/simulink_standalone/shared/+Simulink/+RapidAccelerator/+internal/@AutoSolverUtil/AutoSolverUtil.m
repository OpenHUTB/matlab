classdef AutoSolverUtil<handle
%#function embedded.fi
%#function numerictype















    properties(Constant)





        SL_CS_STATUS_ILLEGAL=0x00
        SL_CS_STATUS_FLAGS_INIT=0x01
        SL_CS_STATUS_FIXED_STEP=0x02
        SL_CS_STATUS_SOLVER_AUTO=0x04
        SL_CS_STATUS_STEP_SIZE_AUTO=0x08
        SL_CS_STATUS_CSREF=0x10
        SL_CS_STATUS_POWERGUI=0x20
        SL_CS_STATUS_SLVR_FINALIZED=0x40
        SL_CS_STATUS_PRM_CHANGED=0x80
        SL_CS_STATUS_CONST_AUTO=0x100
        SL_CS_STATUS_RUNTIME_AUTO=0x200
        SL_CS_STATUS_AUTO_PRMC=0x400
        SL_CS_STATUS_AUTO_TIME=0x800
        SL_CS_STATUS_ADAPTIVE_AUTO=0x1000
    end


    methods(Access='public',Static)

        function ret=isAutoSolverAtCompile(autoSolverStatusFlags)

            import Simulink.RapidAccelerator.internal.AutoSolverUtil;
            ret=(bitand(autoSolverStatusFlags,double(AutoSolverUtil.SL_CS_STATUS_SOLVER_AUTO))>0);
        end

        function ret=clearAutoSolverAtCompile(autoSolverStatusFlags)

            import Simulink.RapidAccelerator.internal.AutoSolverUtil;
            ret=bitxor(autoSolverStatusFlags,double(AutoSolverUtil.SL_CS_STATUS_SOLVER_AUTO));
        end

    end

end

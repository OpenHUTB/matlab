classdef RtpCgSupport<simscape.engine.sli.dae.DaeCgSupport






    properties(Access=private)
        mSolver;
        mIdx;
    end

    methods(Static)





        function[gatewayFcnName,gatewayFcnHeader,requiredLibraries]=support(solver,idx,hExecBlock,regKey)
            obj=simscape.engine.sli.dae.RtpCgSupport(solver,idx);
            [gatewayFcnName,gatewayFcnHeader,requiredLibraries]=obj.baseSupport(hExecBlock,regKey);
        end
    end

    methods


        function obj=RtpCgSupport(solver,idx)
            obj.mSolver=solver;
            obj.mIdx=idx;
        end


        function initBaseProperties(self,hExecBlock)
            self.hExecBlock=[];
            self.solverBlockPath='';
            self.nameBase=nesl_solverid(self.mSolver);
        end


        function initDerivedProperties(self)
            self.mxParam=[];
            self.index=int2str(self.mIdx);
        end


        function flag=todoCg(self)

            flag=false;
        end

    end

end

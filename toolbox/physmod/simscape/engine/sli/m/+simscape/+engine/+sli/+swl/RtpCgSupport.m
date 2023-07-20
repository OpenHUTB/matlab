classdef RtpCgSupport<simscape.engine.sli.swl.SwlCgSupport






    properties(Access=private)
        mSolver;
        mGraphInd;
    end

    methods(Static)
        function[simulatorFcnName,simulatorFcnHeader,requiredLibraries]=support(solver,hExecBlock,graphInd)
            obj=simscape.engine.sli.swl.RtpCgSupport(solver,graphInd);
            [simulatorFcnName,simulatorFcnHeader,requiredLibraries]=obj.baseSupport(hExecBlock);
        end
    end

    methods


        function obj=RtpCgSupport(solver,graphInd)
            obj.mSolver=solver;
            obj.mGraphInd=graphInd;
        end


        function initBaseProperties(self,hExecBlock)
            self.hExecBlock=[];
            self.solverBlockPath='';
            self.nameBase=nesl_solverid(self.mSolver);
        end


        function initDerivedProperties(self)
            self.mxParam='';
            self.index=self.mGraphInd;
        end


        function flag=todoCg(self)

            flag=false;
        end

    end

end

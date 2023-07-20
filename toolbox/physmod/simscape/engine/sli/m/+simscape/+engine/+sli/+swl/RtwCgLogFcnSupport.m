classdef RtwCgLogFcnSupport<simscape.engine.sli.swl.SwlCgSupport







    properties(Access=private)
        mSolver;
        mGraphInd;
    end

    methods(Static)
        function[simulatorFcnName,simulatorFcnHeader,requiredLibraries]=support(solver,hExecBlock,graphInd)
            obj=simscape.engine.sli.swl.RtwCgLogFcnSupport(solver,graphInd);
            [simulatorFcnName,simulatorFcnHeader,requiredLibraries]=obj.baseSupport(hExecBlock);
        end
    end

    methods


        function obj=RtwCgLogFcnSupport(solver,graphInd)
            obj.mSolver=solver;
            obj.mGraphInd=graphInd;
        end


        function initBaseProperties(self,~)
            self.hExecBlock=[];
            self.solverBlockPath='';
            self.nameBase=nesl_solverid(self.mSolver);
        end


        function initDerivedProperties(self)
            self.mxParam='';
            self.index=self.mGraphInd;
        end


        function flag=todoCg(self)%#ok<MANU>

            flag=false;
        end

    end

end

classdef ComputerValidator<coder.parallel.validation.interfaces.IComputerValidator





    properties(GetAccess=private,SetAccess=immutable)
ComputerInfo
    end

    methods
        function this=ComputerValidator(computerInfo)

            if nargin==0
                this.ComputerInfo=coder.internal.ComputerInfo();
            else
                this.ComputerInfo=computerInfo;
            end
        end

        function validateMemory(this,numWorkers)

            if~ispc
                return;
            end


            warnThreshold=pow2(30)+pow2(29);

            abortThreshold=pow2(29)+pow2(28);



            numSessions=numWorkers+1;


            totalPhysicalMemory=this.ComputerInfo.getTotalPhysicalMemory();
            perSessionMemory=totalPhysicalMemory/numSessions;



            if(perSessionMemory<abortThreshold)
                DAStudio.error('RTW:buildProcess:critLowMem',abortThreshold,...
                numWorkers,totalPhysicalMemory,numWorkers);
            end

            if(perSessionMemory<warnThreshold)
                MSLDiagnostic('RTW:buildProcess:lowMem',totalPhysicalMemory,...
                char(perSessionMemory),numWorkers,warnThreshold).reportAsWarning;
            end
        end
    end
end



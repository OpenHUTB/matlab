classdef PoolValidator<coder.parallel.validation.interfaces.IPoolValidator





    properties(GetAccess=private,SetAccess=immutable)
ComputerInfo
ComputerValidator
    end

    methods



        function this=PoolValidator(computerInfo,computerValidator)

            if nargin==0
                this.ComputerInfo=coder.internal.ComputerInfo();
                this.ComputerValidator=coder.parallel.validation.ComputerValidator(this.ComputerInfo);
            else
                this.ComputerInfo=computerInfo;
                this.ComputerValidator=computerValidator;
            end
        end




        function result=isPCTLicensedAndInstalled(~)
            result=matlab.internal.parallel.isPCTInstalled()&&...
            matlab.internal.parallel.isPCTLicensed();
        end




        function isValid=validate(this,pool,errorOnFailure,requiredLicenses)

            this.validatePoolType(pool);

            this.validateLicenses(pool,requiredLicenses);


            validationData=pool.runOnAllWorkersSync(@this.getValidationData);

            isValid=...
            this.validateArchitecture(validationData,errorOnFailure)&&...
            this.validateWorkersCanWriteToPwd(validationData,errorOnFailure);



            if pool.IsLocalPool
                this.ComputerValidator.validateMemory(pool.NumWorkers);
            end
        end
    end

    methods(Access=private)



        function isValid=validateArchitecture(this,validationData,errorOnFailure)


            workerArchs={validationData.arch};
            clientArch=this.ComputerInfo.getArchitecture();

            allArchs=unique([{clientArch},workerArchs]);
            isValid=length(allArchs)==1;
            if~isValid
                this.reportFailure(errorOnFailure,'Simulink:slbuild:poolArchInconsistent');
            end
        end




        function isValid=validateWorkersCanWriteToPwd(this,validationData,errorOnFailure)

            workersCanWriteToPwd=[validationData.canWriteToPwd];
            isValid=all(workersCanWriteToPwd);
            if~isValid
                this.reportFailure(errorOnFailure,'Simulink:slbuild:parallelFileSystemInaccessible',pwd);
            end
        end
    end

    methods(Static,Access=private)



        function validatePoolType(pool)
            if pool.IsThreadPool
                DAStudio.error('Simulink:slbuild:threadPoolNotSupported');
            end
        end




        function reportFailure(errorOnFailure,msgId,varargin)
            if errorOnFailure
                DAStudio.error(msgId,varargin{:});
            else
                MSLDiagnostic(msgId,varargin{:}).reportAsWarning;
            end
        end




        function result=getValidationData()

            result.arch=computer;

            [~,attribs]=fileattrib;
            result.canWriteToPwd=attribs.UserWrite;
        end

        function validateLicenses(pool,requiredLicenses)
            pool.runOnAllWorkersSync(...
            @coder.parallel.validation.checkoutLicenses,requiredLicenses);
        end
    end
end


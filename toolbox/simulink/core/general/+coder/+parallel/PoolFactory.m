classdef PoolFactory<coder.parallel.interfaces.IPoolFactory




    properties(SetAccess=immutable)
PoolValidator
PCTPoolFactory
    end

    methods



        function this=PoolFactory(poolValidator,pctPoolFactory)

            if nargin==0
                this.PoolValidator=coder.parallel.validation.PoolValidator();
                this.PCTPoolFactory=coder.parallel.PCTPoolFactory();
            else
                this.PoolValidator=poolValidator;
                this.PCTPoolFactory=pctPoolFactory;
            end
        end




        function[success,pool]=createPool(this,errorOnValidationFailure,requiredLicenses)
            success=false;
            pool=[];



            if~this.PoolValidator.isPCTLicensedAndInstalled()
                MSLDiagnostic('Simulink:slbuild:PCTNotAvailable').reportAsWarning;
                return;
            end


            fileGenCfg=Simulink.fileGenControl('getConfig');
            if fileGenCfg.ForceParallelModelReferenceBuildsForTesting


                pool=coder.parallel.TestModePool();
                success=true;
                return;
            end


            [success,lpool]=this.PCTPoolFactory.createPCTPool();
            if success

                success=this.PoolValidator.validate(lpool,errorOnValidationFailure,requiredLicenses);
                if success
                    pool=lpool;
                end
            else

                Simulink.output.info(string(message('Simulink:slbuild:PoolNotAutoStarted')));
            end
        end
    end
end



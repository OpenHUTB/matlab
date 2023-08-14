classdef ParallelBuildContext<handle




    properties(GetAccess=private,SetAccess=immutable)
PoolFactory
ModelBuildValidator
    end

    properties(Access=private)
Pool
WorkerCleanup
    end

    methods



        function this=ParallelBuildContext(poolFactory,modelBuildValidator)

            if nargin==0
                this.PoolFactory=coder.parallel.PoolFactory();
                this.ModelBuildValidator=coder.parallel.validation.ModelBuildValidator();
            else
                this.PoolFactory=poolFactory;
                this.ModelBuildValidator=modelBuildValidator;
            end
        end




        function[doParBuild,pool]=prepareForBuild(this,...
            iMdl,...
            nTotalMdls,...
            nLevels,...
            targetType,...
            requiredLicenses,...
            mdlsHaveUnsavedChanges)

            pool=[];



            doParBuild=this.ModelBuildValidator.validate(iMdl,...
            nTotalMdls,...
            nLevels,...
            targetType,...
            mdlsHaveUnsavedChanges);

            if doParBuild

                [doParBuild,pool]=this.createParallelPool(iMdl,requiredLicenses);

                if doParBuild


                    pool.setupWorkersForModelRefBuilds(iMdl);
                end
            end
        end




        function delete(this)

            if~isempty(this.WorkerCleanup)
                delete(this.WorkerCleanup);
            end
        end
    end

    methods(Access=private)
        function[success,pool]=createParallelPool(this,iMdl,requiredLicenses)
            if isempty(this.Pool)

                errorOnValidationFailure=get_param(iMdl,'ParallelModelReferenceErrorOnInvalidPool');
                [success,pool]=this.PoolFactory.createPool(errorOnValidationFailure,requiredLicenses);

                if success

                    this.WorkerCleanup=pool.initializeWorkers;
                end



                this.Pool=pool;
            else

                pool=this.Pool;
                success=true;
            end
        end
    end
end

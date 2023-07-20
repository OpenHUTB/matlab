classdef(Abstract)ApproximateGeneratorEngine<handle




    properties(Constant)
        AllFloatingPointWLs=[16,32,64];
        AllFloatingPointStrings=["half","single","double"];
    end

    properties(SetAccess=protected)
Problem
Options
DataBase
        ExploreFloatingPoint=false
        ExploreFixedPoint=true;
    end

    methods
        function this=ApproximateGeneratorEngine(problemObject)

            this.DataBase=FunctionApproximation.internal.database.ApproximationSolutionsDataBase();


            observers=FunctionApproximation.internal.database.getObservers(problemObject.Options);
            for idx=1:numel(observers)
                observers(idx).setOptions(problemObject.Options);
                this.DataBase.addObserver(observers(idx));
            end


            this.Problem=problemObject;
            this.Options=problemObject.Options;
            interfaceTypes=problemObject.getInterfaceTypes();
            if ismember('ExploreFloatingPoint',this.Options.DefaultFields)

                exploreFloatingPoint=false;
                for itype=1:numel(interfaceTypes)
                    exploreFloatingPoint=exploreFloatingPoint||fixed.internal.type.isAnyFloat(interfaceTypes(itype));
                    if exploreFloatingPoint
                        break;
                    end
                end
                this.ExploreFloatingPoint=exploreFloatingPoint;
                this.Options.ExploreFloatingPoint=this.ExploreFloatingPoint;
            else
                this.ExploreFloatingPoint=this.Options.ExploreFloatingPoint;
            end

            this.ExploreFixedPoint=this.Options.ExploreFixedPoint;
            if this.ExploreFixedPoint


                exploreFixedPoint=true;
                for itype=1:numel(interfaceTypes)
                    exploreFixedPoint=exploreFixedPoint&&~ishalf(interfaceTypes(itype));
                    if~exploreFixedPoint
                        break;
                    end
                end
                this.ExploreFixedPoint=exploreFixedPoint;
                this.Options.ExploreFixedPoint=this.ExploreFixedPoint;
            end
        end
    end

    methods(Abstract)
        [diagnostic,solution]=run(this);
    end

    methods(Hidden)
        function updateOptionsOnSolvers(~,solverQueue,options)
            nSolvers=numel(solverQueue);
            for iSolver=1:nSolvers
                solverQueue(iSolver).setOptions(options);
            end
        end
    end

    methods(Static)
        function handler=initializeTempDir()

            handler=FunctionApproximation.internal.TempDirectoryHandler();
            createDirectory(handler);
            cd(handler.TempDir);
        end

        function engineCleanup(handler,newDir)
            cd(newDir);
            delete(handler);
        end

        function value=getFloatingPointCutOffWL()

            wls=FunctionApproximation.internal.ApproximateGeneratorEngine.AllFloatingPointWLs;
            if~FunctionApproximation.internal.isHalfFeatureAvailable()
                wls=wls(wls>16);
            end
            value=min(wls);
        end

        function value=getFloatingPointStrings(options)

            value=FunctionApproximation.internal.ApproximateGeneratorEngine.AllFloatingPointStrings;
            wls=FunctionApproximation.internal.ApproximateGeneratorEngine.AllFloatingPointWLs;
            if~FunctionApproximation.internal.isHalfFeatureAvailable()||~options.ExploreHalf
                value=value(wls>16);
            end
        end

        function value=getFloatingPointWLs(options)

            value=FunctionApproximation.internal.ApproximateGeneratorEngine.AllFloatingPointWLs;
            if~FunctionApproximation.internal.isHalfFeatureAvailable()||~options.ExploreHalf
                value=value(value>16);
            end
        end
    end
end

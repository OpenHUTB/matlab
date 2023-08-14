classdef OptimizerPerItem<cgsimfill.internal.optimizer.TableOptimizer




    properties(Dependent,SetAccess=private)
NormGradient
    end

    methods

        function obj=OptimizerPerItem(stepUpdater,items)



            obj.StepUpdaters=stepUpdater.empty;
            for mapNum=1:length(items)

                obj.StepUpdaters(mapNum)=copy(stepUpdater);
                setupConstraints(obj.StepUpdaters(mapNum),items(mapNum));
            end
        end

        function n=get.NormGradient(obj)

            n=max([obj.StepUpdaters.NormGradient]);
        end

        function initialize(obj,LS)


            obj.ExpressionChain=LS.ExpressionChain;
            obj.ReferenceVariable=LS.ReferenceVariable;
            obj.InitialWindow=LS.InitialWindow;
            items=LS.FillItems;
            obj.ItemsToDifferentiate=[items.Pointer];
            if length(obj.ItemsToDifferentiate)~=length(obj.StepUpdaters)


                stepUpdater=obj.StepUpdaters(1);
                clearMemory(stepUpdater);
                obj.StepUpdaters=stepUpdater.empty;
                for mapNum=1:length(items)

                    obj.StepUpdaters(mapNum)=copy(stepUpdater);
                    setupConstraints(obj.StepUpdaters(mapNum),items(mapNum));
                end
            else

                for i=1:length(items)
                    setupConstraints(obj.StepUpdaters(i),items(i))
                end
            end
            initialize(obj.StepUpdaters,LS)
        end


        function leastSquaresGradients(obj,J,e)




            active=false(1,0);
            obj.Residuals=e;
            for mapNum=1:length(obj.StepUpdaters)
                leastSquaresGradients(obj.StepUpdaters(mapNum),J{mapNum},e)
                active=[active,any(J{mapNum}~=0,1)];%#ok<AGROW>
            end
            obj.Active=active;
            obj.Cost=e'*e;

        end

        function accumulate(obj,nextObj,weight)



            for mapNum=1:length(obj.StepUpdaters)
                su=nextObj.StepUpdaters(mapNum);
                accumulate(obj.StepUpdaters(mapNum),su,weight)
            end
            obj.Cost=obj.StepUpdaters(mapNum).Cost;
        end


        function[b,converged]=solve(obj,b,smoothingMatrix,previousOptimizer,previousValues)



            converged=zeros(1,length(obj.StepUpdaters));
            for mapNum=1:length(obj.StepUpdaters)
                [b{mapNum},converged(mapNum)]=solve(obj.StepUpdaters(mapNum),b{mapNum},smoothingMatrix{mapNum},...
                previousOptimizer.StepUpdaters(mapNum),previousValues{mapNum});
            end
            converged=all(converged);
            obj.Cost=obj.StepUpdaters(1).Cost;
        end
    end



end

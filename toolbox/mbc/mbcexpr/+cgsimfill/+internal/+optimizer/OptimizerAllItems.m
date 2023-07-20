classdef OptimizerAllItems<cgsimfill.internal.optimizer.TableOptimizer




    properties(Dependent,SetAccess=private)
NormGradient
    end

    methods

        function obj=OptimizerAllItems(stepUpdater,F)

            obj.StepUpdaters=copy(stepUpdater);
            setupConstraints(obj.StepUpdaters,F)
        end

        function n=get.NormGradient(obj)

            n=max([obj.StepUpdaters.NormGradient]);
        end

        function initialize(obj,LS)


            obj.ExpressionChain=LS.ExpressionChain;
            obj.ReferenceVariable=LS.ReferenceVariable;
            obj.InitialWindow=LS.InitialWindow;
            obj.ItemsToDifferentiate=[LS.FillItems.Pointer];
            setupConstraints(obj.StepUpdaters,LS.SimFill)
            [obj.StepUpdaters.LearningRate]=deal(LS.StepSize);
            initialize(obj.StepUpdaters,LS)

        end

        function leastSquaresGradients(obj,varargin)




            leastSquaresGradients(obj.StepUpdaters,varargin{:})
            obj.Cost=obj.StepUpdaters.Cost;
            obj.Active=obj.StepUpdaters.Gradient~=0;
            obj.Active=obj.Active(:)';
        end

        function accumulate(obj,nextObj,weight)



            accumulate(obj.StepUpdaters,nextObj.StepUpdaters,weight)
            obj.Cost=obj.StepUpdaters.Cost;
            obj.Active=obj.StepUpdaters.Gradient~=0;
            obj.Active=obj.Active(:)';

        end

        function[b,converged]=solve(obj,b,smoothingMatrix,previousOptimizer,previousValues)





            currentValues=cat(1,b{:});
            previousValues=cat(1,previousValues{:});
            smoothingMatrix=blkdiag(smoothingMatrix{:});

            [currentValues,converged]=solve(obj.StepUpdaters,currentValues,smoothingMatrix,...
            previousOptimizer.StepUpdaters,previousValues);

            obj.Cost=obj.StepUpdaters(1).Cost;


            startIndex=1;
            for mapNum=1:length(b)
                n=numel(b{mapNum});
                bm=currentValues(startIndex:startIndex+n-1);
                startIndex=startIndex+n;
                b{mapNum}=reshape(bm,size(b{mapNum}));
            end

        end

    end



end

classdef AdamStepUpdater<cgsimfill.internal.optimizer.StepUpdater






















    properties

        AverageGradient=0

        AverageGradientSquared=0

        Beta1=0.9

        Beta2=0.999

        Epsilon=1e-8

        Iteration=0;
        NumIncreases=0;
        NumDecreases=0;
    end


    methods

        function obj=AdamStepUpdater

            obj.Name='ADAM';
            obj.Description='ADAM';
        end

        function reset(obj)

            obj.Gradient=0;
            obj.Cost=0;
        end

        function ok=hasMemory(obj)



            ok=~isequal(obj.AverageGradient,0);
        end


        function leastSquaresGradients(obj,J,e)




            obj.Gradient=-2*J'*e;
            obj.Cost=e'*e;

        end

        function accumulate(obj,nextObj,weight)



            obj.Gradient=obj.Gradient+weight*nextObj.Gradient;
            obj.Cost=obj.Cost+weight*nextObj.Cost;
        end

        function[b,converged]=solve(obj,b,smoothingMatrix,previousStepper,previousValues)



            converged=false;
            g=obj.Gradient;
            if~isempty(smoothingMatrix)

                sb=smoothingMatrix*b(:);
                g=g+2*smoothingMatrix'*sb;
                obj.Cost=obj.Cost+sb'*sb;
            end

            if previousStepper.Cost<obj.Cost&&obj.Iteration>0

                obj.NumIncreases=obj.NumIncreases+1;
                if obj.NumIncreases>=5

                    obj.LearningRate=obj.LearningRate/2;

                    obj.NumIncreases=0;
                end
                obj.NumDecreases=0;
            elseif~isfinite(obj.Cost)||obj.Cost>1e10||~all(isfinite(g))


                if obj.Iteration==0

                    error('mbc:cgsimfill:AdamStepUpdater:InvalidStart','Initial values must have finite cost and gradient')
                end


                obj.LearningRate=obj.LearningRate/10;
                obj.NumIncreases=previousStepper.NumIncreases;
                obj.NumDecreases=previousStepper.NumDecreases;


                obj.Cost=previousStepper.Cost;
                obj.Gradient=previousStepper.Gradient;
                obj.AverageGradient=previousStepper.AverageGradient;
                obj.AverageGradientSquared=previousStepper.AverageGradientSquared;
                b=previousValues;
                g=obj.Gradient;
                if~isempty(smoothingMatrix)
                    g=g+2*smoothingMatrix'*sb;
                end
                converged=obj.LearningRate<1e-6;
            else

                obj.NumIncreases=0;
                obj.NumDecreases=obj.NumDecreases+1;
                if obj.NumDecreases>=10

                    obj.LearningRate=obj.LearningRate*2;
                    obj.NumDecreases=0;
                    converged=obj.LearningRate<1e-6;
                end
            end

            if all(isfinite(g))

                obj.AverageGradient=obj.Beta1.*obj.AverageGradient+(1-obj.Beta1).*g;
                obj.AverageGradientSquared=obj.Beta2.*obj.AverageGradientSquared+(1-obj.Beta2).*g.^2;
                adamstep=-obj.LearningRate.*(obj.AverageGradient./(sqrt(obj.AverageGradientSquared)+obj.Epsilon));


                obj.Iteration=obj.Iteration+1;

                biasCorrection=sqrt(1-obj.Beta2.^obj.Iteration)./(1-obj.Beta1.^obj.Iteration);
                step=biasCorrection*adamstep;

                if obj.HasConstraints

                    step=projectBox(obj,b(:),step);
                end
                b=b+reshape(step,size(b));
            end
        end

        function clearMemory(obj)


            obj.Iteration=0;
            obj.AverageGradient=0;
            obj.AverageGradientSquared=0;
            obj.Cost=0;

        end

    end

    methods(Static)

        function obj=loadobj(obj)


            obj.Name='ADAM';
            obj.Description='ADAM';
        end
    end

end



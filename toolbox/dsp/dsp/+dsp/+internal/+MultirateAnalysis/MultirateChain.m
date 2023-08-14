classdef MultirateChain<handle





    properties
        Stages={};
    end

    methods
        function obj=MultirateChain(C,varargin)








            if nargin==0

                C={};
            end

            if isa(C,'dsp.internal.MultirateAnalysis.MultirateChain')

                obj=dsp.internal.MultirateAnalysis.MultirateChain(C.Stages,varargin{:});
            elseif iscell(C)
                p=inputParser;
                p.KeepUnmatched=true;

                addParameter(p,'skipTrivial',true,@(x)isnumeric(x)||islogical(x));
                parse(p,varargin{:});

                for k=1:numel(C)
                    obj.addStage(C{k},p.Results.skipTrivial);
                end
            else
                error(message('dsp:MultirateAnalysis:unsupportedType','MultirateChain.MultirateChain',class(C)));
            end
        end

        function addStage(obj,s,skipTrivial)





            if nargin<3

                skipTrivial=false;
            end

            import dsp.internal.MultirateAnalysis.*

            if isa(s,'dsp.internal.MultirateAnalysis.MultirateStage')
                stg=s;
            elseif isnumeric(s)
                stg=UpDownStage(s);
            elseif iscell(s)
                num=s{1};
                den=s{2};
                z=s{3};
                stg=FilterChain(FilterStage(num,den,z,'F'));
            end


            if~skipTrivial||~isTrivial(stg)
                obj.Stages{end+1}=stg;
            end
        end

        function addChain(obj,C)

            import dsp.internal.MultirateAnalysis.*

            if isa(C,'dsp.internal.MultirateAnalysis.MultirateChain')
                for k=1:C.numStages
                    obj.addStage(C.Stages{k});
                end
            else
                error(message('dsp:MultirateAnalysis:unsupportedType','MultirateChain.addChain',class(C)));
            end
        end

        function n=numStages(obj)
            n=numel(obj.Stages);
        end

        function disp(obj)
            s="⟶ ";
            for k=1:numStages(obj)
                s=s+sprintf('%s ⟶ ',str(obj.Stages{k}));
            end
            disp(s)
        end

        function b=islinphase(obj)




            Mr=dsp.internal.MultirateAnalysis.MultirateChain(obj);
            Mr.reduce();

            b=true;
            for k=1:numStages(Mr)
                if isFilter(Mr.Stages{k})
                    b=b&&islinphase(Mr.Stages{k});
                end


                if~b
                    break;
                end
            end
        end

        function reduce(obj)








            k=1;

            maxReductionSteps=1000;

            while obj.reduceStep()
                k=k+1;
                if k>=maxReductionSteps
                    error(message('dsp:MultirateAnalysis:maxReduceIter'));
                end
            end
        end

        function b=reduceStep(obj)
            b=obj.reduceTrivials()||obj.reducePairs();
        end

        function B=reduceTrivials(obj)

            B=false;
            k=1;
            while k<=numStages(obj)

                Sk=obj.Stages{k};


                if isTrivial(Sk)
                    obj.Stages(k)=[];
                    B=true;
                end

                k=k+1;
            end
        end

        function B=reducePairs(obj)



            k=1;
            B=false;
            while k<=numStages(obj)-1

                Sk=obj.Stages{k};
                Skn=obj.Stages{k+1};


                if class(Sk)==class(Skn)
                    if isFilter(Sk)||(isUpDown(Sk)&&(Sk.n*Skn.n>0))


                        obj.Stages{k}=[Sk,Skn];
                        B=true;
                        obj.Stages(k+1)=[];
                    elseif isUp(Sk)&&isDown(Skn)
                        r=gcd(Sk.n,Skn.n);
                        if r>1
                            obj.Stages{k}=Sk/r;
                            obj.Stages{k+1}=Skn/r;
                            B=true;
                        end
                    end

                    if B
                        return;
                    end
                end


                if isDown(Sk)&&isFilter(Skn)
                    n=Sk.n;
                    obj.Stages{k}=Skn.up(n);
                    obj.Stages{k+1}=dsp.internal.MultirateAnalysis.UpDownStage(n);
                    B=true;
                    return;
                end

                if isFilter(obj.Stages{k})&&isUp(obj.Stages{k+1})
                    n=Skn.n;
                    obj.Stages{k+1}=Sk.up(n);
                    obj.Stages{k}=dsp.internal.MultirateAnalysis.UpDownStage(n);
                    B=true;
                    return;
                end

                k=k+1;
            end
        end

    end
end

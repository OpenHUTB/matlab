classdef FilterChain<dsp.internal.MultirateAnalysis.MultirateStage







%#codegen

    properties
        Filters={};


    end

    methods
        function obj=FilterChain(S)
            if nargin>0
                if iscell(S)


                    obj.Filters=S;
                elseif isa(S,'dsp.internal.MultirateAnalysis.FilterStage')


                    obj.Filters={S};
                elseif isa(S,'dsp.internal.MultirateAnalysis.FilterChain')

                    obj.Filters=S.Filters;
                else
                    error(message('dsp:MultirateAnalysis:unsupportedType','FilterChain.FilterChain',class(C)));
                end
            end
        end

        function c=horzcat(obj,a)




            if isa(a,'dsp.internal.MultirateAnalysis.FilterStage')

                c=dsp.internal.MultirateAnalysis.FilterChain([obj.Filters,{a}]);
            elseif isa(a,'dsp.internal.MultirateAnalysis.FilterChain')

                c=dsp.internal.MultirateAnalysis.FilterChain([obj.Filters,a.Filters]);
            else
                error(message('dsp:MultirateAnalysis:unsupportedType','FilterChain.horzcat',class(C)));
            end
        end

        function c=up(obj,n)


            c=dsp.internal.MultirateAnalysis.FilterChain(obj);
            for i=1:numel(c.Filters)
                c.Filters{i}=c.Filters{i}*n;
            end
        end

        function s=str(obj)


            s="";
            for k=1:numel(obj.Filters)
                s=s+str(obj.Filters{k});
            end
        end

        function b=isTrivial(obj)

















            b=false;
            if numel(obj.Filters)==1
                b=obj.Filters{1}.isTrivial();
            end
        end

        function H=freqz(obj,varargin)

            H=1;
            for k=1:numel(obj.Filters)
                H=H.*obj.Filters{k}.freqz(varargin{:});
            end
        end

        function L=lengths(obj)


            L=zeros(1,numel(obj.Filters));

            for k=1:numel(obj.Filters)
                Fk=obj.Filters{k};





                nk=length(Fk.num)+length(Fk.den)-1;
                L(k)=nk*Fk.n;
            end
        end

        function G=grpdelay(obj,varargin)



            G=0;
            L=max(lengths(obj));


            N=max(2^ceil(log2(L)),2^10);
            for k=1:numel(obj.Filters)
                G=G+obj.Filters{k}.grpdelay(N,varargin{:});
            end
        end

        function C=nonLinearPhaseStages(obj)












            C=dsp.internal.MultirateAnalysis.FilterChain(obj.Filters);


            k=1;
            while k<=numel(C.Filters)


                if C.Filters{k}.islinphase
                    C.Filters(k)=[];
                else
                    k=k+1;
                end
            end



            if numel(C.Filters)==0
                C.Filters={dsp.internal.MultirateAnalysis.FilterStage(1,1,1)};
            end
        end

        function b=islinphase(obj)

            G=grpdelay(obj.nonLinearPhaseStages);


            tol=1e-6;
            b=std(G)<tol;
        end
    end
end

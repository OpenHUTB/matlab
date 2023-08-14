classdef FilterStage<dsp.internal.MultirateAnalysis.MultirateStage







    properties
        num=1;
        den=1;
        n=1;
        label='F';
    end

    methods
        function obj=FilterStage(num,den,n,label)
            if nargin<4
                label='';
            end

            if nargin<3
                n=1;
            end

            obj.num=num;
            obj.den=den;
            obj.n=n;
            obj.label=label;
        end

        function uobj=mtimes(obj,m)
            uobj=obj.up(m);
        end

        function uobj=up(obj,m)
            uobj=dsp.internal.MultirateAnalysis.FilterStage(obj.num,obj.den,obj.n*abs(m),obj.label);
        end

        function s=str(obj)

            s=obj.label;
            if obj.n>1
                s=sprintf('%s(z^%d)',s,obj.n);
            else
                s=sprintf('%s(z)',s);
            end
        end

        function b=isTrivial(obj)



            b=isequal(obj.num,obj.den);
        end

        function b=islinphase(obj)



            b=islinphase(obj.num,obj.den);
        end

        function H=freqz(obj,varargin)

            unum=upsample(obj.num,obj.z);
            uden=upsample(obj.den,obj.z);
            H=freqz(unum,uden,varargin{:});
        end

        function G=grpdelay(obj,varargin)





            unum=upsample(obj.num,obj.n);
            uden=upsample(obj.den,obj.n);




            gainTol=1e-6;

            G=grpdelay(unum,uden,varargin{:});
            H=abs(freqz(unum,uden,varargin{:}));



            idxBelowMin=(H/H(1))<gainTol;



            G(idxBelowMin)=mean(G(~idxBelowMin));
        end

    end
end


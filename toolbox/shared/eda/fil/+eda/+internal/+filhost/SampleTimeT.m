



classdef SampleTimeT
    properties
        period=double(-1.0);
        offset=double(0.0);
    end
    methods
        function this=SampleTimeT(varargin)
            if(nargin==1&&strcmp(class(varargin{1}),'eda.internal.filhost.SampleTimeT'))
                this=eda.internal.mcosutils.ObjUtilsT.CopyCtor(this,varargin{1});
            elseif(nargin==1&&ischar(varargin{1}))

                try
                    stimeVal=eval(varargin{1});
                catch ME
                    error(message('EDALink:SampleTimeT:BadSampleTimeExpression',ME.message()));
                end
                this.period=stimeVal(1);
                if(length(stimeVal)==2)
                    this.offset=stimeVal(2);
                end

            else
                this=eda.internal.mcosutils.ObjUtilsT.PvPairCtor(this,varargin{:});
            end
        end
        function this=set.period(this,val)
            this.period=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[-2,realmax],'period');
        end
        function this=set.offset(this,val)
            this.offset=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[-2,realmax],'offset');
        end

        function stStr=getStr(this)
            if(this.offset~=0)
                stStr=sprintf('[%g %g]',this.period,this.offset);
            else
                stStr=sprintf('%g',this.period);
            end
        end
    end
end

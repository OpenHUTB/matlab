classdef(CaseInsensitiveProperties,TruncatedProperties)...
    nonlinear<rfbbequiv.linear



















    properties(Hidden)

        Method=0;
    end
    methods
        function set.Method(obj,value)
            if~isequal(obj.Method,value)
                checkrealscalardouble(obj,'Method',value)
                obj.Method=value;
            end
        end
    end

    properties(Hidden)

        InputEffect=1.0;
    end
    methods
        function set.InputEffect(obj,value)
            if~isequal(obj.InputEffect,value)
                checkrealscalardouble(obj,'InputEffect',value)
                obj.InputEffect=value;
            end
        end
    end

    properties(Hidden)

        OutputGain=1.0;
    end
    methods
        function set.OutputGain(obj,value)
            if~isequal(obj.OutputGain,value)

                obj.OutputGain=setcomplex(obj,value,'OutputGain',false);
            end
        end
    end

    properties(Hidden)

        XData=[];
    end
    methods
        function set.XData(obj,value)
            if~isequal(obj.XData,value)

                obj.XData=setrealvector(obj,value,'XData',...
                true,true,true);
            end
        end
    end

    properties(Hidden)

        AMAMData=[];
    end
    methods
        function set.AMAMData(obj,value)
            if~isequal(obj.AMAMData,value)

                obj.AMAMData=setrealvector(obj,value,'AMAMData',...
                true,true,true);
            end
        end
    end

    properties(Hidden)

        AMPMData=[];
    end
    methods
        function set.AMPMData(obj,value)
            if~isequal(obj.AMPMData,value)

                obj.AMPMData=setrealvector(obj,value,'AMPMData',...
                true,true,true);
            end
        end
    end

    properties(Hidden)

        PhaseNoiseResp=0;
    end

    properties(Hidden)

        Poly7C1=1;
    end

    properties(Hidden)

        Poly7C3=0;
    end

    properties(Hidden)

        Poly7C5=0;
    end

    properties(Hidden)

        Poly7C7=0;
    end

    properties(Hidden)

        ASatIn=1;
    end

    properties(Hidden)

        ASatOut=1;
    end

    properties(Hidden)

        P2DTF=[];
    end

    properties(Hidden)

        P2DAM=[];
    end

    properties(Hidden)

        P2DIFFTLength=16;
    end

    properties(Hidden)

        InvertSignalSpectral=false;
    end


    methods
        function h=nonlinear(varargin)








            h=h@rfbbequiv.linear('PhantomConstruction');





            set(h,'Name','rfbbequiv.nonlinear object',varargin{:});
        end

    end

    methods
        h=analyze(h,freq)
        out=convertfreq(h,in,varargin)
        intptype=getintptype(h)
    end

end




classdef Calculator<handle

    properties(Access=protected)
SourceObject
Frequencies
FirstIndex
SecondIndex
Aperture
AreIJUsingDefaults
    end
    properties(Abstract,Dependent,Access=protected)
NumPorts
    end


    properties(Abstract,Constant,Access=protected)
MinNumArguments
SourceClass
    end


    methods
        function obj=Calculator(srcobj)
            obj.SourceObject=srcobj;
        end
    end


    methods
        function set.SourceObject(obj,newsrcobj)
            validateattributes(newsrcobj,{obj.SourceClass},{'scalar'})
            obj.SourceObject=newsrcobj;
        end
    end


    methods
        function gd=calculateGroupDelay(obj,varargin)
            narginchk(obj.MinNumArguments,8)

            preParseCheck(obj)

            parseInputs(obj,varargin{:})

            postParseCheck(obj)

            gd=calculate(obj);
        end
    end


    methods(Access=protected)
        function postParseCheck(obj)
            aper=obj.Aperture;
            if~isscalar(aper)&&(numel(obj.Frequencies)~=numel(aper))

                error(message('rf:shared:GroupDelayBadApertureLength'))
            end

            ijdef=obj.AreIJUsingDefaults;
            if ijdef(1)~=ijdef(2)

                error(message('rf:shared:GroupDelayMissingJ'))
            end

            if(obj.NumPorts~=2)&&ijdef(1)

                warning(message('rf:shared:GroupDelayS11ByDefault'))
            end
        end

        function gd=standardGroupDelayCalculation(obj)

            [L,R]=getLeftAndRightFrequencies(obj);



            [sortedfreq,idx]=sort([L;R]);
            [allfreq,~,ic]=unique(sortedfreq);

            angIJ=getSijAngle(obj,allfreq);
            leftidx=idx<=numel(obj.Frequencies);
            gd=(angIJ(ic(leftidx))-angIJ(ic(~leftidx)))./(2*pi*(R-L));
        end
    end
    methods(Static,Access=protected)
        function aper=defaultAperture(freq)
            aper=max(freq,1)*sqrt(eps);
        end
    end


    methods(Abstract,Access=protected)
        preParseCheck(obj)
        parseInputs(obj,varargin)
        gd=calculate(obj)
        [L,R]=getLeftAndRightFrequencies(obj)
        ang21=getSijAngle(obj,freq)
    end
end
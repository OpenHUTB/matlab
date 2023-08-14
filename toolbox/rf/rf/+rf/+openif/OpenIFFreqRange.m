classdef OpenIFFreqRange<matlab.mixin.Heterogeneous



    properties(SetAccess=private)
FreqRange
dBLevel
    end

    properties(Abstract)
SourceMixer
    end

    properties(Abstract,SetAccess=private)
LORange
    end

    methods
        function thisObj=OpenIFFreqRange(FreqOne,FreqTwo,newdB)
            thisObj.FreqRange=[min(FreqOne,FreqTwo),max(FreqOne,FreqTwo)];
            thisObj.dBLevel=newdB;
        end
    end

    methods
        function theObj=set.FreqRange(theObj,newFreqRange)
            if~theObj.validateFreqRange(newFreqRange)

                error(message('rf:openif:openiffreqrange:setfreqrange:InvalidFreqRange'))
            end
            theObj.FreqRange=newFreqRange;
        end

        function theObj=set.dBLevel(theObj,newdB)
            if~(isnumeric(newdB)&&isscalar(newdB)&&isreal(newdB))

                error(message('rf:openif:openiffreqrange:setdblevel:InvaliddBLevel'))
            end

            theObj.dBLevel=newdB;
        end
    end

    methods(Static,Access=protected)

        function TF=validateFreqRange(newFreqRange)
            TF=isnumeric(newFreqRange)&&...
            isequal(size(newFreqRange),[1,2])&&...
            all(newFreqRange>=0);
        end
    end

end
classdef OpenIFSpurFreeZone<rf.openif.OpenIFFreqRange


    properties
        SourceMixer=[]
    end

    properties(SetAccess=private)
        LORange=[0,0]
    end

    methods
        function thisObj=OpenIFSpurFreeZone(FreqOne,FreqTwo,dBFloor)
            thisObj=thisObj@rf.openif.OpenIFFreqRange(FreqOne,FreqTwo,dBFloor);
        end

        function theObj=AddLO(theObj,whichMixer)





            if~isa(whichMixer,'rf.openif.OpenIFMixer')

                error(message('rf:openif:openifspurfreezone:addlo:NotAMixer'))
            end


            theObj.SourceMixer=vertcat(theObj.SourceMixer,whichMixer);
        end
    end


    methods(Static,Access=protected)
        function TF=validateFreqRange(newFreqRange)
            TF=rf.openif.OpenIFFreqRange.validateFreqRange(newFreqRange);
            TF=TF&&(newFreqRange(1)~=newFreqRange(2));
        end
    end
end
classdef PowerData<handle


    properties(SetAccess=protected)
Frequency
Data
    end

    methods
        function obj=PowerData(newFrequency,newData,newFormatLine)
            narginchk(3,3);

            validateattributes(newFormatLine,{'char'},{'row'});
            validateattributes(newFrequency,{'numeric'},{'scalar'})
            validateattributes(newData,{'numeric'},{'size',[NaN,10]});


            obj.Data=rf.file.shared.sandp2d.reorderdata(rf.file.p2d.PowerData.getformatlinekeys,newData,newFormatLine);
            obj.Frequency=newFrequency;
        end
    end

    methods
        function set.Frequency(obj,newFreq)
            obj.Frequency=newFreq;
        end

        function set.Data(obj,newData)
            obj.Data=newData;
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'P1','P2','N11X','N11Y','N21X','N21Y','N12X','N12Y','N22X','N22Y'};
        end
    end
end
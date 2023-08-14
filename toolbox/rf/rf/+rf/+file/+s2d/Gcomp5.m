classdef Gcomp5<rf.file.s2d.GcompMethods&rf.file.s2d.Gcomp1DBC&...
    rf.file.s2d.GcompPSGCS




    methods
        function obj=Gcomp5(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'1DBC','PS','GCS'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'ncols',3})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.OneDBC=Data(:,1);
            obj.PS=Data(:,2);
            obj.GCS=Data(:,3);
        end
    end
end
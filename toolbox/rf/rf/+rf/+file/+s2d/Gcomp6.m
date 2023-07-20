classdef Gcomp6<rf.file.s2d.GcompMethods&rf.file.s2d.GcompIP3&...
    rf.file.s2d.Gcomp1DBC&rf.file.s2d.GcompPSGCS




    methods
        function obj=Gcomp6(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'IP3','1DBC','PS','GCS'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'ncols',4})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.IP3=Data(:,1);
            obj.OneDBC=Data(:,2);
            obj.PS=Data(:,3);
            obj.GCS=Data(:,4);
        end
    end
end
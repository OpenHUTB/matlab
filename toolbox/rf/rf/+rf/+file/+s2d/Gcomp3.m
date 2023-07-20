classdef Gcomp3<rf.file.s2d.GcompMethods&rf.file.s2d.Gcomp1DBC&...
    rf.file.s2d.GcompIP3




    methods
        function obj=Gcomp3(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'1DBC','IP3'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'ncols',2})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.OneDBC=Data(:,1);
            obj.IP3=Data(:,2);
        end
    end
end
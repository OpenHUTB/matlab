classdef Gcomp2<rf.file.s2d.GcompMethods&rf.file.s2d.Gcomp1DBC




    methods
        function obj=Gcomp2(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'1DBC'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'scalar'})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.OneDBC=Data;
        end
    end
end
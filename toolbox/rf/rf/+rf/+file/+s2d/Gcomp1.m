classdef Gcomp1<rf.file.s2d.GcompMethods&rf.file.s2d.GcompIP3



    methods
        function obj=Gcomp1(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'IP3'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'scalar'})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.IP3=Data;
        end
    end
end
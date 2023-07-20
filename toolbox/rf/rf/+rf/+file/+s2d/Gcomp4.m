classdef Gcomp4<rf.file.s2d.GcompMethods&rf.file.s2d.GcompIP3&...
    rf.file.s2d.GcompPSGCS




    methods
        function obj=Gcomp4(newData,newFormatLine)
            obj=obj@rf.file.s2d.GcompMethods(newData,newFormatLine);
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'IP3','PS','GCS'};
        end

        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'ncols',3})
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,Data)
            obj.IP3=Data(:,1);
            obj.PS=Data(:,2);
            obj.GCS=Data(:,3);
        end
    end
end
classdef GcompMethods<handle



    methods
        function obj=GcompMethods(newData,newFormatLine)
            narginchk(2,2)
            obj.validatedatainput(newData)
            validateattributes(newFormatLine,{'char'},{'row'},'','GCOMPx FormatLine')




            reorderedData=rf.file.shared.sandp2d.reorderdata(obj.getformatlinekeys,newData,newFormatLine);



            assigndata(obj,reorderedData)
        end
    end

    methods(Access=protected,Hidden)
        function out=getgcomptype(obj)
            out=textscan(class(obj),'%s','Delimiter','.');
            out=upper(out{1}(end));
            out=out{1};
        end
    end

    methods(Abstract,Access=protected,Static,Hidden)
        out=getformatlinekeys;
        validatedatainput(newData)
    end

    methods(Abstract,Access=protected,Hidden)
        out=assigndata(obj,data);
    end
end
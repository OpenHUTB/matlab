classdef DeviceTreePrinter<matlabshared.devicetree.util.TextPrinter

    methods
        function obj=DeviceTreePrinter
            obj.DefaultFileExtension="dts";
        end
    end


    methods(Access=public)
        function addComment(obj,commentStr)




            if contains(commentStr,newline)
                obj.addBlockComment(commentStr);
            else
                comment="// "+commentStr;
                obj.addLine(comment);
            end
        end

        function addBlockComment(obj,commentStr)








            commentStr=convertCharsToStrings(commentStr);

            commentLines=split(commentStr,newline);
            obj.addLine("/*");
            for comment=commentLines'
                obj.addLine(" * "+comment);
            end
            obj.addLine(" */");
        end
    end
end
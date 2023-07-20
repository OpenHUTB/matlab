classdef FormatContentsWithComments<coder.internal.asap2.FormatContents




    methods(Access=public)
        function this=FormatContentsWithComments(fullFilePath)
            this=this@coder.internal.asap2.FormatContents(fullFilePath);
        end

        function write(this,comment,value)

            this.wLine([comment,value]);
        end



        function writeAppend(this,value,comment)

            this.wLine([value,comment]);
        end
    end
end


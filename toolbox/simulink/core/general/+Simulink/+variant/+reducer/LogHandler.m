classdef(Hidden,Sealed)LogHandler<handle





    properties(Transient,Access=private)
        FilePointer(1,1)double=-1;
    end

    methods(Access=private)
        function isInvalid=isInvalidPointer(obj)
            isInvalid=(obj.FilePointer==-1);
        end
    end

    methods


        function delete(obj)

            if obj.isInvalidPointer(),return;end

            fclose(obj.FilePointer);

        end


        function createLog(obj,outDir)


            [~,attribs]=fileattrib(outDir);
            absOutDirPath=attribs.Name;


            logFile=[absOutDirPath,filesep,'variant_reducer.log'];
            try
                obj.FilePointer=fopen(logFile,'w+');
            catch
            end

        end


        function write(obj,msg)

            if obj.isInvalidPointer(),return;end

            fprintf(obj.FilePointer,'%s',msg);

        end


        function appendLines(obj,varargin)

            if obj.isInvalidPointer(),return;end

            narginchk(1,2);
            if nargin==1
                n=1;
            else
                n=varargin{1};
            end
            str=repmat(newline,1,n);
            fprintf(obj.FilePointer,'%s',str);

        end

    end

end

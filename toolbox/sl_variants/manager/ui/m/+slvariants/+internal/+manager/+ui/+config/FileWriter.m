classdef(Hidden,Sealed)FileWriter<handle






    properties(Transient,Access=private)
        FilePointer(1,1)double=-1;
        FileName;
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


        function createFileWriter(obj,fileName)

            obj.FileName=fileName;


            [obj.FilePointer,errMessage]=fopen(fileName,'w');

            if obj.FilePointer==-1
                expection=MException(errMessage);
                throw(expection);
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

        function deleteFile(obj)
            fclose(obj.FilePointer);
            obj.FilePointer=-1;
            delete(obj.FileName);
        end
    end

end

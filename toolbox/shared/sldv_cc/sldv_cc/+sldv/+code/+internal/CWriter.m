classdef CWriter<handle
    properties(Access=public)

LineNumber
    end


    properties(Access=private)
FileID
IndentLevel
IndentCount
Str
        AppendStr=false
    end


    methods

        function obj=CWriter(fileName,openMode)
            obj.LineNumber=sldv.code.internal.CWriter.countLines(fileName);
            obj.FileID=fopen(fileName,openMode,'n','utf-8');
            obj.IndentLevel=0;
            obj.IndentCount=4;
        end


        function delete(obj)
            if obj.FileID>=3
                fclose(obj.FileID);
            end
        end


        function lineNumber=beginStr(obj)
            obj.AppendStr=true;
            obj.Str='';
            lineNumber=obj.LineNumber;
        end


        function str=endStr(obj)
            obj.AppendStr=false;
            str=obj.Str;
        end


        function print(obj,format,varargin)
            str=sprintf(format,varargin{:});

            numCr=sum(str==newline());
            obj.LineNumber=obj.LineNumber+numCr;
            if numCr>0&&obj.IndentLevel>0
                indentStr=repmat(' ',1,obj.IndentLevel*obj.IndentCount);
                str=strrep(str,newline(),...
                [newline(),indentStr]);
            end

            if obj.AppendStr
                obj.Str=[obj.Str,str];
            end

            fprintf(obj.FileID,'%s',str);
        end


        function beginBlock(obj,format,varargin)
            obj.print(format,varargin{:});
            obj.IndentLevel=obj.IndentLevel+1;

            if format(end)==newline()
                obj.print(repmat(' ',1,obj.IndentCount));
            end
        end


        function endBlock(obj,format,varargin)
            obj.IndentLevel=obj.IndentLevel-1;
            assert(obj.IndentLevel>=0,'endBlock called with zero or negative indent');
            obj.print(format,varargin{:});
        end


        function defineExternC(obj,defineName)
            obj.print('#ifdef %s\n',defineName);
            obj.print('#undef %s\n',defineName);
            obj.print('#endif\n\n');
            obj.print('#ifdef __cplusplus\n');
            obj.print('#define %s extern "C"\n',defineName);
            obj.print('#else\n');
            obj.print('#define %s extern\n',defineName);
            obj.print('#endif\n\n');
        end
    end


    methods(Access=private,Static=true)

        function lineNum=countLines(fileName)
            lineNum=1;
            fid=fopen(fileName,'rb');
            if fid>0
                content=fread(fid);
                fclose(fid);
                lineNum=lineNum+sum(content==newline());
            end
        end
    end
end



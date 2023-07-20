


classdef CodeTrace<handle
    properties(Access=private)
        fCodeTrace;
    end


    methods

        function this=CodeTrace()
            this.fCodeTrace=containers.Map('KeyType','char','ValueType','any');
        end


        function addTrace(this,aFileName,aLineNumber)
            assert(ischar(aLineNumber),'CodeTrace char type assert');
            aLineNumber=str2double(aLineNumber);
            if(this.fCodeTrace.isKey(aFileName))
                lineNumbers=this.fCodeTrace(aFileName);
                this.fCodeTrace(aFileName)=[lineNumbers,aLineNumber];
            else
                this.fCodeTrace(aFileName)=aLineNumber;
            end
        end


        function fileNames=getFileNames(this)
            fileNames=this.fCodeTrace.keys;
        end


        function lineNos=getLineNumbers(this,aFile)
            lineNos={};
            if(this.fCodeTrace.isKey(aFile))
                lineNos=sort(this.fCodeTrace(aFile));
            end
        end


        function str=toString(this)
            str=[];
            keys=this.getFileNames();
            for i=1:numel(keys)
                str=[str,keys{i}];%#ok
                values=this.getLineNumbers(keys{i});
                for j=1:numel(values)
                    assert(isnumeric(values(j)),'CodeTrace numeric type assert');
                    if j==1
                        str=[str,':',num2str(values(j))];%#ok
                    else
                        str=[str,', ',num2str(values(j))];%#ok
                    end
                end
                if i~=numel(keys)
                    str=[str,'; '];%#ok
                end
            end
        end
    end
end
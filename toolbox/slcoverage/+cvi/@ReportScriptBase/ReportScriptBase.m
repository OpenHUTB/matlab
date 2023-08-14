



classdef ReportScriptBase<handle
    properties
        generateString=false
        domMode=false
        outFile=[]
        htmlStr=[]
        baseReportDir=''
    end
    methods

        function obj=ReportScriptBase()
        end

        function openFile(obj,baseFileName)
            if~obj.generateString
                obj.outFile=fopen(baseFileName,'w','n','utf-8');
                if(obj.outFile==-1)
                    error(message('Slvnv:simcoverage:cvhtml:CouldNotCreateFile'));
                end
            end
            obj.baseReportDir=fileparts(baseFileName);


        end

        function run(~)
        end


        function closeFile(obj)
            if~obj.generateString
                fclose(obj.outFile);
                obj.outFile=[];
            end
        end

        function printIt(obj,formatStr,varargin)
            if obj.generateString
                obj.htmlStr=[obj.htmlStr,sprintf(formatStr,varargin{:})];
            else
                fprintf(obj.outFile,formatStr,varargin{:});
            end
        end
    end
end

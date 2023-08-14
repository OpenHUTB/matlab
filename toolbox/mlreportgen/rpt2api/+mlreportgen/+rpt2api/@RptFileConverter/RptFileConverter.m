classdef RptFileConverter<handle






















    properties


        RptFilePath(1,1)string


        ScriptPath(1,1)string


        FID(1,1){mustBeInteger}









        VariableNameStack(1,1)mlreportgen.utils.Stack


        CurrentSectionLevel(1,1){mustBeInteger}



        CurrentLayoutObject=[];











        ConverterFactory(1,1)mlreportgen.rpt2api.ComponentConverterFactory




        ClearWorkspace(1,1)logical=true


        OpenScript(1,1)logical=true

    end

    properties(Access=public,Hidden)



        IncludeTOC(1,1)logical=true;






        TOCAdded(1,1)logical=false;



        Debug(1,1)logical=false;







        OutputType=[];
    end

    properties(Access=protected)



        HelperFunctions=[];
    end

    properties(Access=private)







        Context containers.Map

        Cleanup string
    end


    methods
        function obj=RptFileConverter(varargin)

            p=inputParser();
            p.addRequired('FilePath',@(x)ischar(x)||isstring(x));
            p.addOptional('ScriptPath',[],@(x)ischar(x)||isstring(x));
            p.parse(varargin{:});
            args=p.Results;

            obj.RptFilePath=args.FilePath;

            if(nargin==2)
                obj.ScriptPath=args.ScriptPath;
            end

            obj.VariableNameStack=mlreportgen.utils.Stack;
            obj.CurrentSectionLevel=0;
            setConverterFactory(obj);
            obj.Context=containers.Map.empty;
            obj.Cleanup="";
        end

        function convert(obj)



            import mlreportgen.rpt2api.*

            if obj.ScriptPath==""
                [~,name,~]=fileparts(obj.RptFilePath);
                name=strrep(name,"-","_");
                obj.ScriptPath=name;
            end

            obj.FID=fopen(obj.ScriptPath,'w','n','UTF-8');

            rpt=load(obj.RptFilePath,'-mat');
            cmpn=rpt.rptgen_component_v2;

            if obj.Debug
                cmpn.isDebug=true;
            end
            c=getConverter(obj.ConverterFactory,cmpn,obj);
            convert(c);

            writeHelperFunctions(obj);

            fclose(obj.FID);


            if obj.OpenScript
                script=matlab.desktop.editor.openDocument(obj.ScriptPath);
                script.smartIndentContents
                script.save
            end


            clearConverterClasses();
        end

        function setFID(obj,fid)
            obj.FID=fid;
        end

        function set.RptFilePath(obj,value)
            filePath=mlreportgen.utils.findFile(value,"FileExtensions",".rpt");

            if isempty(filePath)

                error(message("mlreportgen:rpt2api:error:RptFileNotFound",...
                value));
            end
            obj.RptFilePath=filePath;
        end

        function set.ScriptPath(obj,value)

            [dir,name,ext]=fileparts(value);

            if name==""
                error(message("mlreportgen:rpt2api:error:noFileNameSpecified"));
            end

            if dir==""
                dir=pwd;
            end

            if ext==""
                ext=".m";
            end

            obj.ScriptPath=fullfile(dir,name+ext);
        end

        function value=getContext(obj,key)








            value=[];
            if obj.Context.isKey(key)
                value=obj.Context(key);
            end
        end

        function setContext(obj,key,value)







            obj.Context(key)=value;
        end

        function removeContext(obj,key)



            if isKey(obj.Context,key)
                remove(obj.Context,key);
            end
        end

        function addCleanupCode(obj,code)
            obj.Cleanup=obj.Cleanup+code;
        end

        function code=getCleanupCode(obj)
            code=obj.Cleanup;
        end

        function registerHelperFunction(this,functionName)





            helperFile=strcat("t",functionName,".txt");
            if isempty(this.HelperFunctions)||~any(endsWith(this.HelperFunctions,filesep+helperFile))
                classFolder=fileparts(mfilename('fullpath'));
                templateFolder=fullfile(classFolder,...
                'templates');
                templatePath=fullfile(templateFolder,helperFile);
                this.HelperFunctions=[this.HelperFunctions,templatePath];
            end
        end

        function writeHelperFunctions(this)






            helperFcns=this.HelperFunctions;
            nHelpers=numel(helperFcns);
            if nHelpers>0

                fprintf(this.FID,"%s\n\n","%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
                fprintf(this.FID,"%% Helper functions\n\n");



                for idx=1:nHelpers
                    templatePath=helperFcns(idx);
                    template=fileread(templatePath);
                    fwrite(this.FID,template);
                end
            end
        end
    end

    methods(Access=protected)

        function setConverterFactory(obj)
            import mlreportgen.rpt2api.*
            obj.ConverterFactory=ComponentConverterFactory;
        end
    end

end

function clearConverterClasses()







    classesToClear=...
    mlreportgen.rpt2api.ComponentConverter.classesToClearAfterConversion("ComponentConverter");
    nClasses=length(classesToClear);
    for iClass=1:nClasses
        clear(classesToClear(iClass));
    end
end

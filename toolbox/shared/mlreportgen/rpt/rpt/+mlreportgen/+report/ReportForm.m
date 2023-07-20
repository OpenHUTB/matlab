classdef(Hidden)ReportForm<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties(Access=private)
        PropertiesMap=[];
        MethodsMap=[];
    end

    properties(Access=private,Constant)

        TemplateTypeToExtnMap=containers.Map(...
        {'pdf','docx','html','html-file'},...
        {'.pdftx','.dotx','.htmtx','.htmt'});
    end

    methods(Static,Sealed,Access=protected)
        function default_object=getDefaultScalarElement
            default_object=mlreportgen.report.ReportForm;
        end
    end

    methods(Access=protected,Hidden)
        function computePropsMethods(reportForm)

            if isnumeric(reportForm.PropertiesMap)&&isempty(reportForm.PropertiesMap)
                [reportForm.PropertiesMap,reportForm.MethodsMap]=...
                mlreportgen.report.ReportForm.getPropMethods(reportForm);
            end
        end

        function fillHole(reportForm,form,rpt)
            holeId=form.CurrentHoleId;
            getID=sprintf('get%s',holeId);
            content=[];
            if isKey(reportForm.MethodsMap,getID)
                content=reportForm.(getID)(rpt);
            else
                if isKey(reportForm.PropertiesMap,holeId)
                    content=get(reportForm,holeId);
                else

                    if reportForm~=rpt
                        if isKey(rpt.MethodsMap,getID)
                            content=rpt.(getID)(rpt);
                        else
                            if isKey(rpt.PropertiesMap,holeId)
                                content=get(rpt,holeId);
                            end
                        end
                    end
                end
            end
            if~isempty(content)


                mlreportgen.report.internal.LockedForm.add(...
                form,rpt,content);
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.Layout})
        function fillForm(reportForm,form,rpt)
            computePropsMethods(reportForm);
            if reportForm~=rpt
                computePropsMethods(rpt);
            end

            while~strcmp(form.CurrentHoleId,'#end#')
                processHole(reportForm,form,rpt);
                moveToNextHole(form);
            end
        end

        function fillHeadersFooters(reportForm,form,rpt)
            if~isempty(form.CurrentPageLayout)
                for header=form.CurrentPageLayout.PageHeaders
                    open(header);
                    if strcmp(header.OpenStatus,"open")
                        fillForm(reportForm,header,rpt);
                    end
                end
                for footer=form.CurrentPageLayout.PageFooters
                    open(footer);
                    if strcmp(footer.OpenStatus,"open")
                        fillForm(reportForm,footer,rpt);
                    end
                end
            end
        end
    end

    methods(Access=protected,Hidden)
        function processHole(reportForm,form,rpt)%#ok<INUSD>
        end

        function setInformalArg(reportForm,varargin)
            len=length(varargin);

            if mod(len,2)>0
                error(message("mlreportgen:report:error:invalidArgPairing"));
            end
            for i=1:2:len
                name=char(varargin{i});
                value=varargin{i+1};
                set(reportForm,name,value);
            end
        end
    end

    methods(Static,Hidden)

        function propsMap=getProps(m)
            propsMap=containers.Map;

            list=m.PropertyList;
            for i=1:numel(list)
                prop=list(i);

                if strcmp(prop.GetAccess,'public')
                    propsMap(prop.Name)=prop;
                end
            end
        end

        function[propsMap,methodsMap]=getPropMethods(obj)

            methodsMap=containers.Map;

            m=metaclass(obj);

            list=m.MethodList;
            for i=1:numel(list)
                me=list(i);
                name=me.Name;

                if length(name)>3&&strcmp(name(1:3),'get')
                    if numel(me.InputNames)==2&&numel(me.OutputNames)==1
                        methodsMap(name)=me;
                    end
                end
            end

            propsMap=mlreportgen.report.ReportForm.getProps(m);
        end

        function templatePath=fixTemplateExt(templateFullPath,type)
            templatePath=templateFullPath;
            templateType=lower(type);

            [~,~,ext]=fileparts(templatePath);
            if isempty(ext)||ext==""


                if mlreportgen.report.ReportForm.TemplateTypeToExtnMap.isKey(templateType)
                    ext=mlreportgen.report.ReportForm.TemplateTypeToExtnMap(templateType);
                    templatePath=string(templatePath)+string(ext);
                end
            else


                if~strcmpi(ext,mlreportgen.report.ReportForm.TemplateTypeToExtnMap(templateType))
                    error(message("mlreportgen:report:error:invalidTemplateExtn",...
                    ext,type));
                end
            end
        end

        function templatePath=getFormTemplatePath(folder,type,varargin)
            if isempty(varargin)
                filename='default';
            else
                filename=varargin{1};
            end
            typeFolder=lower(type);
            if "html-file"==typeFolder
                typeFolder="html";
            end

            folder=char(folder);
            typeFolder=char(typeFolder);
            filename=char(filename);

            templatePath=fullfile(folder,...
            'resources','templates',typeFolder,filename);

            templatePath=...
            mlreportgen.report.ReportForm.fixTemplateExt(templatePath,type);
        end

        function templatePath=fixFormTemplateExt(folder,type,varargin)
            if isempty(varargin)
                filename='default';
            else
                filename=varargin{1};
            end
            typeFolder=lower(type);
            if "html-file"==typeFolder
                typeFolder="html";
            end

            folder=char(folder);
            typeFolder=char(typeFolder);
            filename=char(filename);

            templatePath=fullfile(folder,...
            'resources','templates',typeFolder,filename);

            templatePath=...
            mlreportgen.report.ReportForm.fixTemplateExt(...
            templatePath,type);
        end

        function destination=createFormTemplate(templatePath,type,classFolder)
            destination=[];
            source=mlreportgen.report.ReportForm.getFormTemplatePath(classFolder,type);


            if~isempty(mlreportgen.utils.findFile(source))
                destination=mlreportgen.report.ReportForm.fixTemplateExt(templatePath,type);
                destination=mlreportgen.utils.findFile(destination,"FileMustExist",false);


                PATHSTR=fileparts(string(destination));
                if PATHSTR~=""&&~isfolder(PATHSTR)
                    mkdir(PATHSTR);
                end

                copyfile(source,destination,"f");
                fileattrib(destination,"+w");
            end
        end

        function name=getSuperClass(superclassList)
            name=[];
            len=length(superclassList);
            for idx=1:len
                mc=superclassList(idx);
                if strcmp(mc.Name,'mlreportgen.report.ReporterBase')||...
                    strcmp(mc.Name,'mlreportgen.report.ReportBase')
                    name=mc.Name;
                    break;
                else
                    name=mlreportgen.report.ReportForm.getSuperClass(mc.SuperclassList);
                    if~isempty(name)
                        break;
                    end
                end
            end
        end

        function classfile=customizeClass(toClasspath,baseClass,varargin)
            [PATHSTR,NAME,EXT]=fileparts(toClasspath);
            folder=string(PATHSTR);
            name=string(NAME);
            extension=string(EXT);
            baseClass=string(baseClass);


            if folder==""
                folder=string(pwd);
            end




            isClassFolder=startsWith(name,"@");


            if extension==""
                extension=".m";
            else
                if isClassFolder
                    error(message("mlreportgen:report:error:extensionFileNotAllowed"));
                end
                if extension~=".m"
                    error(message("mlreportgen:report:error:unsupportedFileFormat"));
                end
            end





            if isempty(varargin)
                ownerTemplateClass=baseClass;
            else
                ownerTemplateClass=varargin{1};
            end


            mc=meta.class.fromName(ownerTemplateClass);
            methods=mc.MethodList;
            hasGetClassFolder=ismember('getClassFolder',{methods.Name});
            if~hasGetClassFolder
                error(message("mlreportgen:report:error:getClassFolderNotFound"));
            end
            ownerTemplateClassFolder=feval(ownerTemplateClass+".getClassFolder");


            fullpath=mlreportgen.utils.findFile(folder,"FileMustExist",false);
            package=getPackageName(fullpath);


            classname=name;
            if isClassFolder
                classname=extractAfter(name,1);


                folder=string(fullfile(char(folder),char(name)));
            end
            if package~=""
                fullclassname=package+"."+classname;
            else
                fullclassname=classname;
            end
            filename=classname+extension;


            if folder~=""
                if exist(folder,'dir')~=7


                    mkdir(char(folder));
                end
            end

            superClass=mlreportgen.report.ReportForm.getSuperClass(mc.SuperclassList);
            isReporter="mlreportgen.report.ReporterBase"==superClass;



            classfile=fullfile(char(folder),char(filename));
            hfile=fopen(classfile,"w");
            classfile=string(classfile);

            fwrite(hfile,sprintf("classdef %s < %s \n",classname,baseClass));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    properties \n"));
            fwrite(hfile,sprintf("    end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    methods \n"));
            fwrite(hfile,sprintf("        function obj = %s(varargin) \n",classname));
            fwrite(hfile,sprintf("            obj = obj@%s(varargin{:}); \n",baseClass));
            fwrite(hfile,sprintf("        end \n"));
            fwrite(hfile,sprintf("    end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    methods (Hidden) \n"));
            if isReporter
                fwrite(hfile,sprintf("        function templatePath = getDefaultTemplatePath(~, rpt) \n"));
            else
                fwrite(hfile,sprintf("        function templatePath = getDefaultTemplatePath(rpt) \n"));
            end
            fwrite(hfile,sprintf("            path = %s.getClassFolder(); \n",fullclassname));
            fwrite(hfile,sprintf("            templatePath = ... \n"));
            fwrite(hfile,sprintf("                mlreportgen.report.ReportForm.getFormTemplatePath(... \n"));
            fwrite(hfile,sprintf("                path, rpt.Type); \n"));
            fwrite(hfile,sprintf("        end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    methods (Static) \n"));
            fwrite(hfile,sprintf("        function path = getClassFolder() \n"));
            fwrite(hfile,sprintf("            [path] = fileparts(mfilename('fullpath')); \n"));
            fwrite(hfile,sprintf("        end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("        function createTemplate(templatePath, type) \n"));
            fwrite(hfile,sprintf("            path = %s.getClassFolder(); \n",fullclassname));
            fwrite(hfile,sprintf("            mlreportgen.report.ReportForm.createFormTemplate(... \n"));
            fwrite(hfile,sprintf("                templatePath, type, path); \n"));
            fwrite(hfile,sprintf("        end \n"));
            fwrite(hfile,newline);
            if baseClass=="mlreportgen.report.Report"||baseClass=="slreportgen.report.Report"
                fwrite(hfile,sprintf("        function customizeReport(toClasspath) \n"));
            else
                fwrite(hfile,sprintf("        function customizeReporter(toClasspath) \n"));
            end
            fwrite(hfile,sprintf("            mlreportgen.report.ReportForm.customizeClass(... \n"));
            fwrite(hfile,sprintf("                toClasspath, ""%s""); \n",fullclassname));
            fwrite(hfile,sprintf("        end \n"));
            fwrite(hfile,newline);
            fwrite(hfile,sprintf("    end  \n"));
            fwrite(hfile,sprintf("end"));
            fclose(hfile);

            for type=["DOCX","PDF","HTML","HTML-FILE"]
                templatePath=mlreportgen.report.ReportForm.getFormTemplatePath(...
                folder,type);
                mlreportgen.report.ReportForm.createFormTemplate(...
                templatePath,type,ownerTemplateClassFolder);
            end



        end
    end

end

function package=getPackageName(fullpath)
    package="";
    [PATHSTR,NAME,EXT]=fileparts(string(fullpath));
    while EXT==""&&NAME~=""&&startsWith(NAME,"+")
        if package==""
            package=extractAfter(NAME,1);
        else
            package=extractAfter(NAME,1)+"."+package;
        end
        [PATHSTR,NAME,EXT]=fileparts(PATHSTR);
    end

end
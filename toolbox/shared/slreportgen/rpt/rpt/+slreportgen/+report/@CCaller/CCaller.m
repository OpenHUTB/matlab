classdef CCaller<slreportgen.report.Reporter






















































































    properties




        Object=[];














        IncludeObjectProperties(1,1)logical=true;








        IncludeAvailableFunctions(1,1)logical=false;







        IncludeCode(1,1)logical=true;















        ObjectPropertiesReporter;











        PortSpecificationReporter;









        FunctionNameTitleFormatter;








        FunctionNameFormatter;










        AvailableFunctionsTitleFormatter;











        AvailableFunctionsListFormatter;










        CodeTitleFormatter;










        CodeFormatter;
    end

    properties(Access=private)

        ObjectHandle;
    end

    methods
        function this=CCaller(varargin)
            if(nargin==1)
                varargin=[{"Object"},varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,'TemplateName',"CCaller");
            addParameter(p,'Object',[]);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="CCallerFunctionNameTitle";
            addParameter(p,'FunctionNameTitleFormatter',para);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="CCallerFunctionName";
            addParameter(p,'FunctionNameFormatter',para);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="CCallerAvailableFunctionsTitle";
            addParameter(p,'AvailableFunctionsTitleFormatter',para);

            ul=mlreportgen.dom.UnorderedList();
            ul.StyleName="CCallerAvailableFunctionsList";
            addParameter(p,"AvailableFunctionsListFormatter",ul);

            portSpecificationTbl=mlreportgen.report.BaseTable();
            portSpecificationTbl.TableStyleName="CCallerPortSpecification";
            portSpecificationTbl.TableWidth="100%";
            addParameter(p,'PortSpecificationReporter',portSpecificationTbl);

            objProps=slreportgen.report.SimulinkObjectProperties;
            objProps.PropertyTable.TableStyleName="CCallerPortSpecification";
            addParameter(p,'ObjectPropertiesReporter',objProps);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="CCallerCodeTitle";
            addParameter(p,'CodeTitleFormatter',para);

            para=mlreportgen.dom.Preformatted;
            para.StyleName="CCallerCode";
            addParameter(p,'CodeFormatter',para);


            parse(p,varargin{:});



            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.FunctionNameTitleFormatter=results.FunctionNameTitleFormatter;
            this.FunctionNameFormatter=results.FunctionNameFormatter;
            this.AvailableFunctionsTitleFormatter=results.AvailableFunctionsTitleFormatter;
            this.AvailableFunctionsListFormatter=results.AvailableFunctionsListFormatter;
            this.PortSpecificationReporter=results.PortSpecificationReporter;
            this.ObjectPropertiesReporter=results.ObjectPropertiesReporter;
            this.CodeTitleFormatter=results.CodeTitleFormatter;
            this.CodeFormatter=results.CodeFormatter;
        end

        function set.ObjectPropertiesReporter(this,value)


            mustBeA(value,"slreportgen.report.SimulinkObjectProperties");


            mustBeScalarOrEmpty(value);

            this.ObjectPropertiesReporter=value;
        end

        function set.FunctionNameTitleFormatter(this,value)


            mustBeA(value,"mlreportgen.dom.Paragraph");


            mustBeScalarOrEmpty(value);

            this.FunctionNameTitleFormatter=value;
        end

        function set.AvailableFunctionsTitleFormatter(this,value)


            mustBeA(value,"mlreportgen.dom.Paragraph");


            mustBeScalarOrEmpty(value);

            this.AvailableFunctionsTitleFormatter=value;
        end

        function set.FunctionNameFormatter(this,value)


            mustBeA(value,"mlreportgen.dom.Paragraph");


            mustBeScalarOrEmpty(value);

            this.FunctionNameFormatter=value;
        end

        function set.AvailableFunctionsListFormatter(this,value)

            mustBeNonempty(value);

            mustBeA(value,["mlreportgen.dom.UnorderedList","mlreportgen.dom.OrderedList"]);


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            this.AvailableFunctionsListFormatter=value;
        end

        function set.PortSpecificationReporter(this,value)


            mustBeA(value,"mlreportgen.report.BaseTable");


            mustBeScalarOrEmpty(value);

            this.PortSpecificationReporter=value;
        end

        function set.CodeTitleFormatter(this,value)


            mustBeA(value,"mlreportgen.dom.Paragraph");


            mustBeScalarOrEmpty(value);

            this.CodeTitleFormatter=value;
        end

        function set.CodeFormatter(this,value)


            mustBeA(value,"mlreportgen.dom.Preformatted");


            mustBeScalarOrEmpty(value);

            this.CodeFormatter=value;
        end

        function impl=getImpl(this,rpt)

            if isempty(this.Object)
                error(message("slreportgen:report:error:noSourceObjectSpecified",class(this)));
            else

                objHandle=slreportgen.utils.getSlSfHandle(this.Object);
                if~strcmpi(get_param(objHandle,"Type"),"block")||...
                    ~strcmpi(get_param(objHandle,"blocktype"),"CCaller")
                    error(message("slreportgen:report:error:invalidCCallerBlock"));
                end
                this.ObjectHandle=objHandle;

                if isempty(this.LinkTarget)

                    this.LinkTarget=slreportgen.utils.getObjectID(this.Object);
                end


                impl=getImpl@slreportgen.report.Reporter(this,rpt);
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.CCaller})
        function content=getObjectProperties(this,~)


            content=[];

            if this.IncludeObjectProperties


                content=copy(this.ObjectPropertiesReporter);
                content.Object=this.ObjectHandle;



                if isempty(content.Properties)

                    dialogParam=slreportgen.utils.getSimulinkObjectParameters(this.ObjectHandle,'Block');

                    toRemove={'FunctionName','AvailableFunctions','FunctionPortSpecification','PortSpecificationString'};
                    dialogParam=setdiff(dialogParam,toRemove);

                    dialogParam=[dialogParam;{'Description'}];
                    content.Properties=dialogParam;
                end
            end
        end

        function content=getFunctionNameTitle(this,rpt)%#ok<INUSD>


            content=[];

            if~isempty(get_param(this.ObjectHandle,"FunctionName"))

                titleText=mlreportgen.utils.normalizeString(getfullname(this.ObjectHandle))...
                +" "+getString(message("slreportgen:report:CCaller:functionName"));
                titleObj=mlreportgen.dom.Text(titleText);
                content=clone(this.FunctionNameTitleFormatter);
                append(content,titleObj);
            end
        end

        function content=getFunctionName(this,~)


            content=[];

            if~isempty(get_param(this.ObjectHandle,"FunctionName"))

                functionNametext=deblank(get_param(this.ObjectHandle,"FunctionName"));
                functionNameObj=mlreportgen.dom.Text(functionNametext);
                content=clone(this.FunctionNameFormatter);
                append(content,functionNameObj);
            end
        end

        function content=getAvailableFunctionsTitle(this,~)


            content=[];

            if this.IncludeAvailableFunctions&&~isempty(get_param(this.ObjectHandle,"Name"))

                titleText=mlreportgen.utils.normalizeString(getfullname(this.ObjectHandle))...
                +" "+getString(message("slreportgen:report:CCaller:availableFunctions"));
                titleObj=mlreportgen.dom.Text(titleText);
                content=clone(this.AvailableFunctionsTitleFormatter);
                append(content,titleObj);
            end
        end

        function content=getAvailableFunctions(this,~)


            content=[];

            if this.IncludeAvailableFunctions
                availableFunctions=deblank(get_param(this.ObjectHandle,"AvailableFunctions"));
                currentFunctionName=deblank(get_param(this.ObjectHandle,"FunctionName"));
                availableFunctions(ismember(availableFunctions,currentFunctionName))=[];

                if~isempty(availableFunctions)
                    content=clone(this.AvailableFunctionsListFormatter);
                    append(content,availableFunctions);
                end
            end
        end

        function content=getPortSpecification(this,rpt)


            content=[];

            portSpecification=get_param(this.ObjectHandle,'FunctionPortSpecification');
            portSpecification=[portSpecification.ReturnArgument,portSpecification.InputArguments,portSpecification.GlobalArguments];
            nSpec=numel(portSpecification);

            if nSpec>0

                props={getString(message("Simulink:CustomCode:PortSpec_ArgName")),...
                getString(message("Simulink:CustomCode:PortSpec_Scope")),...
                getString(message("Simulink:CustomCode:PortSpec_Label")),...
                getString(message("Simulink:CustomCode:PortSpec_Type")),...
                getString(message("Simulink:CustomCode:PortSpec_Size")),...
                getString(message("Simulink:CustomCode:PortSpec_Index"))};


                nProps=numel(props);
                specData=cell(nSpec,nProps);

                for specIdx=1:nSpec

                    specData{specIdx,1}=portSpecification(specIdx).Name;
                    specData{specIdx,2}=portSpecification(specIdx).Scope;
                    specData{specIdx,4}=portSpecification(specIdx).Type;
                    specData{specIdx,5}=portSpecification(specIdx).Size;




                    switch portSpecification(specIdx).Scope
                    case "Constant"
                        specData{specIdx,3}=portSpecification(specIdx).Label;
                        specData{specIdx,6}="-";
                    otherwise
                        specData{specIdx,3}=portSpecification(specIdx).Label;
                        specData{specIdx,6}=portSpecification(specIdx).PortNumber;
                    end
                end


                content=copy(this.PortSpecificationReporter);
                ft=mlreportgen.dom.FormalTable(props,specData);
                content.Content=ft;


                blkName=mlreportgen.utils.normalizeString(getfullname(this.ObjectHandle));

                content.appendTitle(blkName+" "...
                +getString(message("slreportgen:report:CCaller:portSpecification")));

                if mlreportgen.report.Reporter.isInlineContent(content.Title)
                    titleReporter=getTitleReporter(content);
                    titleReporter.TemplateSrc=this;

                    if isChapterNumberHierarchical(this,rpt)
                        titleReporter.TemplateName='CCallerHierNumberedTitle';
                    else
                        titleReporter.TemplateName='CCallerNumberedTitle';
                    end
                    content.Title=titleReporter;
                end

            end
        end

        function content=getCCodeTitle(this,~)


            content=[];

            if this.IncludeCode

                blkName=mlreportgen.utils.normalizeString(getfullname(this.ObjectHandle));
                titleText=blkName...
                +" "+getString(message("slreportgen:report:CCaller:cCode"));
                titleObj=mlreportgen.dom.Text(titleText);

                content=clone(this.CodeTitleFormatter);
                append(content,titleObj);
            end
        end

        function content=getCCode(this,~)


            content=[];
            script="";
            if this.IncludeCode
                script=this.getCCallerCode(this.ObjectHandle);
            end
            if~isempty(script)

                content=clone(this.CodeFormatter);
                append(content,script);
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.CCaller.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.CCaller");
        end
    end

    methods(Static,Hidden)
        function script=getCCallerCode(object)
            script="";
            functionName=deblank(get_param(object,"FunctionName"));
            systemHandle=slreportgen.utils.getModelHandle(object);
            [location,status]=slcc('getCustomCodeFunctionLocation',systemHandle,functionName,true);
            if(status>0&&~isempty(location))
                cFile=fullfile(location.path);
                fid=fopen(cFile);


                for line=1:location.line-1
                    fgets(fid);
                end

                openingBracketFound=false;
                numOpenBrackets=0;





                while(~openingBracketFound||numOpenBrackets>0)&&~feof(fid)
                    line=fgets(fid);
                    for c=char(line)
                        if c=='{'
                            openingBracketFound=true;
                            numOpenBrackets=numOpenBrackets+1;
                        elseif c=='}'
                            numOpenBrackets=numOpenBrackets-1;
                        end
                        script=script+c;
                    end
                end
                fclose(fid);
            else
                warning(message("slreportgen:report:warning:cCodeDefinitionNotFound"));


                [location,status]=slcc('getCustomCodeFunctionLocation',systemHandle,functionName,false);
                if(status>0&&~isempty(location))
                    cFile=fullfile(location.path);
                    fid=fopen(cFile);


                    for line=1:location.line-1
                        fgets(fid);
                    end
                    script=fgetl(fid);
                    fclose(fid);
                end
            end
        end
    end
end

classdef ModelConfiguration<slreportgen.report.Reporter&mlreportgen.report.internal.VariableBase












































































    properties(Dependent)



        Model;
    end

    properties(Hidden)


        HierNumberedTitleTemplateName="ModelConfigHierNumberedTitle";
        NumberedTitleTemplateName="ModelConfigNumberedTitle";
        FormalTableTemplateName="ModelConfigurationFormalTable";

        ConfigValue=[];
    end

    properties(Access=private)







        SourceType=[];









        SourceName=[];


        ModelValue;


        ModelHandle;


        ModelName;
    end

    methods
        function this=ModelConfiguration(varargin)
            if(nargin==1)
                varargin=[{"Model"},varargin];
            end

            this=this@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","ModelConfiguration");
            addParameter(p,"TextFormatter",mlreportgen.dom.Text);

            baseTable=mlreportgen.report.BaseTable;
            baseTable.TableStyleName="ModelConfigurationTable";
            addParameter(p,"TableReporter",baseTable);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="ModelConfigurationParagraph";
            para.WhiteSpace="preserve";
            addParameter(p,"ParagraphFormatter",para);


            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.TableReporter=results.TableReporter;
            this.ParagraphFormatter=results.ParagraphFormatter;
            this.TextFormatter=results.TextFormatter;
        end

        function value=get.Model(this)
            value=this.ModelValue;
        end

        function set.Model(this,value)
            this.ModelValue=[];
            this.ModelHandle=[];
            this.ModelName=[];

            if ischar(value)
                value=string(value);
            end

            if slreportgen.utils.isModel(value)

                this.ModelValue=value;
                this.ModelHandle=slreportgen.utils.getSlSfHandle(value);
                this.ModelName=get_param(this.ModelHandle,"Name");
            else
                error(message("slreportgen:report:ModelConfiguration:invalidModel"));
            end
        end

        function impl=getImpl(this,rpt)
            impl=[];
            if isempty(this.ModelHandle)&&isempty(this.ConfigValue)

                error(message("slreportgen:report:ModelConfiguration:noModelSpecified"));
            else


                [~,configSetObj]=reportVariable(this,rpt);

                if strcmp(this.FormatPolicy,"Inline Text")




                    if~isempty(this.Content)
                        impl=this.Content;


                        DOMText=impl{1};
                        if~isempty(this.SourceName)
                            DOMText.Content=strcat(DOMText.Content," ",...
                            getString(message("slreportgen:report:ModelConfiguration:in")),...
                            " ",this.SourceName,...
                            " (",this.SourceType,")");
                        end
                    end
                else


                    impl=getImpl@slreportgen.report.Reporter(this,rpt);








                    if strcmp(this.FormatPolicy,"Auto")||...
                        strcmp(this.FormatPolicy,"Table")
                        titleStr=...
                        mlreportgen.utils.internal.getDOMContentString(this.Title);
                        componentSearchPattern=...
                        titleStr+".Components("+digitsPattern()+")";
                        textNodes=...
                        mlreportgen.utils.internal.findDOMTextNodes(...
                        impl,componentSearchPattern);

                        nComponents=numel(configSetObj.Components);
                        for iComp=1:nComponents
                            currentComponentObj=configSetObj.Components(iComp);
                            patternToReplace=titleStr+...
                            ".Components("+num2str(iComp)+")";

                            indexesResolved=[];
                            for iText=1:numel(textNodes)
                                currentTextObj=textNodes{iText};
                                if contains(currentTextObj.Content,patternToReplace)&&...
                                    isprop(currentComponentObj,"Name")
                                    currentTextObj.Content=...
                                    replace(currentTextObj.Content,...
                                    patternToReplace,currentComponentObj.Name);

                                    indexesResolved(end+1)=iText;%#ok<AGROW>
                                end
                            end



                            textNodes(indexesResolved)=[];
                        end
                    end
                end
            end
        end

        function value=getConfigSet(this)






            value=getVarValue(this);
        end

    end

    methods(Access=protected,Hidden)

        function value=getVarValue(this)




            if~isempty(this.ConfigValue)
                value=this.ConfigValue;
            else

                if isempty(this.ModelHandle)
                    error(message("slreportgen:report:ModelConfiguration:noModelSpecified"));
                end



                value=getActiveConfigSet(this.ModelHandle);

                if~isempty(value)
                    configSetRef=[];

                    if isa(value,"Simulink.ConfigSet")


                        allConfigSets=getConfigSets(this.ModelHandle);
                        nConfigSets=length(allConfigSets);
                        for i=1:nConfigSets
                            currentConfigSet=...
                            getConfigSet(this.ModelHandle,allConfigSets{i});
                            if isa(currentConfigSet,"Simulink.ConfigSetRef")&&...
                                strcmp(value.Name,currentConfigSet.getRefConfigSet().Name)
                                configSetRef=currentConfigSet;
                                break;
                            end
                        end
                    elseif isa(value,"Simulink.ConfigSetRef")
                        configSetRef=value;
                    end

                    if isempty(configSetRef)


                        this.SourceType=...
                        getString(message("slreportgen:report:ModelConfiguration:model"));
                        this.SourceName=this.ModelName;
                    else


                        value=getReferencedConfigSet(this,configSetRef);
                    end
                end
            end
        end

        function name=getVarName(this)



            name=[];


            if isempty(this.Title)
                this.Title=strcat(this.ModelName," ",...
                getString(message("slreportgen:report:ModelConfiguration:configurationSet")));
                name=this.Title;
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.ModelConfiguration})
        function content=getSource(this,rpt)%#ok<INUSD>
            content=[];
            if~isempty(this.SourceName)


                sourceInfo={...
                strcat(getString(message("slreportgen:report:ModelConfiguration:sourceType")),":"),...
                this.SourceType;...
                strcat(getString(message("slreportgen:report:ModelConfiguration:sourceName")),":"),...
                this.SourceName...
                };

                t=mlreportgen.dom.Table(sourceInfo);
                t.StyleName="ModelConfigurationSourceTable";

                content=t;
            end
        end
    end

    methods(Hidden)
        function setConfigSet(this,configSet)
            this.ConfigValue=configSet;
        end
    end

    methods(Access=private)

        function configSet=getReferencedConfigSet(this,configSetRef)



            configSet=configSetRef.getRefConfigSet();

            if strcmpi(configSetRef.SourceResolvedInBaseWorkspace,"on")

                this.SourceName=configSetRef.SourceName;
                this.SourceType=...
                getString(message("slreportgen:report:ModelConfiguration:baseWorkspace"));
            else

                ddName=configSetRef.getDDName();
                [~,dictName,~]=fileparts(ddName);




                ddReporterTargetID=...
                slreportgen.report.DataDictionary.getLinkTargetID(which(ddName));
                this.SourceName=...
                mlreportgen.dom.InternalLink(ddReporterTargetID,dictName);

                this.SourceType=...
                getString(message("slreportgen:report:ModelConfiguration:dataDictionary"));
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








            path=slreportgen.report.ModelConfiguration.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)










            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.ModelConfiguration");
        end

    end

end
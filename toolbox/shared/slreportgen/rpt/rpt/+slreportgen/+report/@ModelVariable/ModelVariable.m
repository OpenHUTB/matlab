classdef ModelVariable<slreportgen.report.Reporter&mlreportgen.report.internal.VariableBase











































































    properties(SetAccess=?mlreportgen.report.ReportForm)





        Variable(1,1)Simulink.VariableUsage;
    end

    properties(SetAccess=?slreportgen.finder.ModelVariableResult)





        ModelBlockPath=[];
    end

    properties





        ShowUsedBy(1,1)logical=true;







        ShowWorkspaceInfo(1,1)logical=true;








        ListFormatter(1,1)
    end

    properties(Access=public,Hidden)

        UsedByContent=[];
        WorkspaceInfoContent=[];
    end

    properties(Hidden)


        HierNumberedTitleTemplateName="ModelVariableHierNumberedTitle";
        NumberedTitleTemplateName="ModelVariableNumberedTitle";
        FormalTableTemplateName="ModelVariableFormalTable";
    end

    properties(Constant,Hidden)
        UsedByWorkspaceInfoStyle="ModelVariableParagraph";
    end

    methods(Access={?slreportgen.finder.ModelVariableResult})
        function this=ModelVariable(varargin)

            if nargin==1
                varObj=varargin{1};
                varargin={"Variable",varObj};
            end

            this=this@slreportgen.report.Reporter(varargin{:});


            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","ModelVariable");

            baseTable=mlreportgen.report.BaseTable;
            baseTable.TableStyleName="ModelVariableTable";
            addParameter(p,"TableReporter",baseTable);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="ModelVariableParagraph";
            para.WhiteSpace="preserve";
            addParameter(p,"ParagraphFormatter",para);

            txt=mlreportgen.dom.Text;
            txt.WhiteSpace="preserve";
            addParameter(p,"TextFormatter",txt);

            ul=mlreportgen.dom.UnorderedList;
            ul.StyleName="ModelVariableList";
            addParameter(p,"ListFormatter",ul);

            addParameter(p,"NumericFormat","%.2f");


            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.TableReporter=results.TableReporter;
            this.ParagraphFormatter=results.ParagraphFormatter;
            this.TextFormatter=results.TextFormatter;
            this.ListFormatter=results.ListFormatter;
            this.NumericFormat=results.NumericFormat;
        end

    end

    methods

        function set.UsedByContent(this,value)
            if ischar(value)
                this.UsedByContent=string(value);
            else
                this.UsedByContent=value;
            end

        end

        function set.WorkspaceInfoContent(this,value)
            if ischar(value)
                this.WorkspaceInfoContent=string(value);
            else
                this.WorkspaceInfoContent=value;
            end
        end

        function set.ListFormatter(this,value)


            mustBeA(value,["mlreportgen.dom.UnorderedList","mlreportgen.dom.OrderedList"]);


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end



            this.ListFormatter=value;
        end

        function impl=getImpl(this,rpt)
            impl=[];
            if isempty(this.Variable)

                error(message("slreportgen:report:error:noVariableSpecified"));
            else

                if~isempty(this.ListFormatter.Children)
                    error(message("slreportgen:report:error:nonemptyListFormatter"));
                end


                this.UsedByContent=this.Variable.Users;
                if isempty(this.ModelBlockPath)
                    this.WorkspaceInfoContent=this.Variable.SourceType;
                else
                    this.WorkspaceInfoContent=this.ModelBlockPath;
                end


                reportVariable(this,rpt);

                if strcmp(this.FormatPolicy,"Inline Text")



                    if~isempty(this.Content)
                        impl=this.Content;
                    end


                    if this.ShowUsedBy
                        warning(message("slreportgen:report:warning:usedByInline"))
                    end
                    if this.ShowWorkspaceInfo
                        warning(message("slreportgen:report:warning:workspaceInfoInline"))
                    end
                else


                    impl=getImpl@slreportgen.report.Reporter(this,rpt);
                end
            end
        end


        function value=getVariableValue(this)






            value=getVarValue(this);
        end

        function name=getVariableName(this)


            name=getVarName(this);
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=slreportgen.report.ModelVariable.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.ModelVariable})

        function usedBy=getUsedByContent(this,~)


            if this.ShowUsedBy&&~isempty(this.UsedByContent)
                usedByLabel=mlreportgen.dom.Paragraph(...
                strcat(getString(message("slreportgen:report:ModelVariable:usedBy")),":"),...
                this.UsedByWorkspaceInfoStyle);
                usedByLabel.Bold=true;


                usedByList=getUsedByDOM(this,this.UsedByContent);
                usedBy={usedByLabel,usedByList};
            else
                usedBy=[];
            end
        end

        function workspaceInfo=getWorkspaceInfoContent(this,~)


            if this.ShowWorkspaceInfo
                workspaceStr=this.WorkspaceInfoContent;
                if isempty(this.ModelBlockPath)
                    workspaceInfoLabel=mlreportgen.dom.Text(strcat(getString(message("slreportgen:report:ModelVariable:resolvedIn")),": "));
                    if~strcmp(workspaceStr,"base workspace")
                        workspaceStr=strcat(workspaceStr," (",this.Variable.Source,")");
                    end
                else



                    workspaceInfoLabel=mlreportgen.dom.Text(strcat(getString(message("slreportgen:report:ModelVariable:referencedBy")),": "));
                end
                workspaceInfoLabel.Bold=true;
                workspaceInfoContent=mlreportgen.dom.Text(workspaceStr);

                workspaceInfo=mlreportgen.dom.Paragraph;
                workspaceInfo.StyleName=this.UsedByWorkspaceInfoStyle;
                workspaceInfo.WhiteSpace="preserve";
                append(workspaceInfo,workspaceInfoLabel);
                append(workspaceInfo,workspaceInfoContent);
            else
                workspaceInfo=[];
            end
        end
    end


    methods(Access={?slreportgen.report.ModelVariable,?slreportgen.finder.ModelVariableResult})
        function usedByDOM=getUsedByDOM(this,users)




            blocks=strrep(users,newline," ");
            if length(blocks)==1
                usedByLink=makeUsedByLink(blocks{1});
                usedByDOM=mlreportgen.dom.Paragraph();
                usedByDOM.StyleName=this.UsedByWorkspaceInfoStyle;
                append(usedByDOM,usedByLink);
            else
                usedByDOM=clone(this.ListFormatter);
                n=numel(blocks);
                for i=1:n
                    usedByLink=makeUsedByLink(blocks{i});
                    listItem=mlreportgen.dom.ListItem();
                    append(listItem,usedByLink);
                    append(usedByDOM,listItem);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.ModelVariable})

        function value=resolveModelWorkspaceVar(this,obj)

            if~slreportgen.utils.isValidSlSystem(obj.Source)
                error(message("slreportgen:report:error:invalidVariableSource",obj.Source));
            end

            if isempty(this.ModelBlockPath)
                try
                    mdlWks=get_param(obj.Workspace,"ModelWorkspace");
                    value=getVariable(mdlWks,obj.Name);
                catch
                    error(message("mlreportgen:report:error:variableNotInModelWorkspace",...
                    obj.Name,obj.Source));
                end
            else




                if~isValidSlObject(slroot,this.ModelBlockPath)
                    error(message("slreportgen:report:error:invalidModelBlockPath",this.ModelBlockPath));
                end

                try
                    params=get_param(this.ModelBlockPath,"InstanceParametersInfo");
                    idx=strcmp(obj.Name,{params.Name});
                    value=params(idx).Value;
                catch
                    error(message("slreportgen:report:error:variableNotInInstanceParams",...
                    obj.Name,this.ModelBlockPath));
                end
            end
        end

        function value=resolveMaskWorkspaceVar(this,obj)

            maskObj=[];
            source=obj.Source;
            name=obj.Name;

            if isValidSlObject(slroot,source)


                maskObj=Simulink.Mask.get(source);
            end
            if isempty(maskObj)
                error(message("slreportgen:report:error:invalidVariableSource",source));
            end

            try
                if isempty(this.ModelBlockPath)
                    vars=getWorkspaceVariables(maskObj);
                    idx=strcmp({vars.Name},name);
                    value=vars(idx).Value;
                else


                    params=get_param(this.ModelBlockPath,"InstanceParametersInfo");
                    idx=strcmp(obj.Name,{params.Name});
                    value=params(idx).Value;
                end
            catch
                error(message("slreportgen:report:error:variableNotInMaskWorkspace",...
                name,source));
            end
        end

        function value=resolveDictionaryVar(~,obj)
            name=obj.Name;
            source=obj.Source;

            if exist(source,'file')~=2
                error(message("slreportgen:report:error:invalidVariableSource",source));
            end
            dictObj=Simulink.data.dictionary.open(source);


            ddSections=["Design Data","Configurations","Other Data"];
            for sName=ddSections
                sect=getSection(dictObj,sName);
                entry=find(sect,"Name",name);
                if~isempty(entry)

                    value=getValue(entry);
                    break;
                end
            end

            if isempty(entry)
                error(message("slreportgen:report:error:variableNotInDataDictionary",...
                name,source));
            end
        end
    end

    methods(Access=protected,Hidden)

        function value=getVarValue(this)




            if isempty(this.Variable)
                error(message("slreportgen:report:error:noObjectSpecified"));
            end

            obj=this.Variable;

            if~isempty(obj.Value)
                value=obj.Value;
            else
                name=obj.Name;
                switch lower(obj.SourceType)
                case "base workspace"
                    try
                        value=evalin("base",name);
                    catch
                        error(message("mlreportgen:report:error:variableNotInBaseWorkspace",...
                        name));
                    end
                case "model workspace"
                    value=resolveModelWorkspaceVar(this,obj);
                case "mask workspace"
                    value=resolveMaskWorkspaceVar(this,obj);
                case "data dictionary"
                    value=resolveDictionaryVar(this,obj);
                otherwise
                    error(message("slreportgen:report:error:invalidVariableSource",obj.Source));
                end
            end
        end

        function varName=getVarName(this)


            varName=this.Variable.Name;
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








            path=slreportgen.report.ModelVariable.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classFile=customizeReporter(toClasspath)









            classFile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.ModelVariable");
        end
    end
end


function usedByLink=makeUsedByLink(objPath)
    label=mlreportgen.utils.normalizeString(objPath);
    try
        usedByLink=mlreportgen.dom.InternalLink(...
        slreportgen.utils.getObjectID(objPath),label);
    catch ME
        warning(ME.message);
        usedByLink=label;
    end
end

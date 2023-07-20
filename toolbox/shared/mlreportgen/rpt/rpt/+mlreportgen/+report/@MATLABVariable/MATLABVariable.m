classdef MATLABVariable<mlreportgen.report.Reporter&mlreportgen.report.internal.VariableBase































































































    properties



















        Variable string=string.empty();

























        Location(1,1)string="MATLAB";







        FileName string{mustBeScalarOrEmpty}=string.empty();
    end

    properties(Hidden)


        HierNumberedTitleTemplateName="MATLABVariableHierNumberedTitle";
        NumberedTitleTemplateName="MATLABVariableNumberedTitle";
        FormalTableTemplateName="MATLABVariableFormalTable";
    end

    properties(Access=private,Hidden)

        LocalVarValue=[];


        UserVarValue=[];
    end

    methods
        function this=MATLABVariable(varargin)
            if(nargin==1)

                localVarName=inputname(1);
                varargin=[{"Variable"},varargin];
                replaceIdx=2;
            else
                localVarName=[];
                for i=1:2:nargin


                    if strcmp(varargin{i},"Variable")


                        localVarName=inputname(i+1);
                        replaceIdx=i+1;
                        break;
                    end
                end
            end

            localVarValue=[];
            if~isempty(localVarName)





                localVarValue=varargin{replaceIdx};



                varargin{replaceIdx}=localVarName;
            end

            this=this@mlreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","MATLABVariable");
            addParameter(p,"TextFormatter",mlreportgen.dom.Text);

            baseTable=mlreportgen.report.BaseTable;
            baseTable.TableStyleName="MATLABVariableTable";
            addParameter(p,"TableReporter",baseTable);

            para=mlreportgen.dom.Paragraph;
            para.StyleName="MATLABVariableParagraph";
            para.WhiteSpace="preserve";
            addParameter(p,"ParagraphFormatter",para);


            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.TableReporter=results.TableReporter;
            this.ParagraphFormatter=results.ParagraphFormatter;
            this.TextFormatter=results.TextFormatter;

            if~isempty(localVarValue)


                this.LocalVarValue=localVarValue;
                this.Location="Local";
            else
                try
                    this.LocalVarValue=evalin("caller",this.Variable);
                catch

                end
            end

        end

        function set.Variable(this,value)
            mustBeScalarOrEmpty(value);
            try
                this.LocalVarValue=evalin("caller",value);%#ok<MCSUP>
            catch

            end
            this.Variable=value;
        end

        function set.Location(this,value)
            mustBeMember(lower(value),...
            ["matlab","mat-file","global","local","model","user-defined"]);

            this.Location=value;
        end

        function impl=getImpl(this,rpt)
            impl=[];
            if isempty(this.Variable)

                error(message("mlreportgen:report:error:noVariableSpecified"));
            else

                reportVariable(this,rpt);

                if strcmp(this.FormatPolicy,"Inline Text")



                    if~isempty(this.Content)
                        impl=this.Content;
                    end
                else


                    impl=getImpl@mlreportgen.report.Reporter(this,rpt);
                end
            end
        end

        function setVariableValue(this,newValue)















            this.UserVarValue=newValue;
            this.Location="User-Defined";
        end

        function value=getVariableValue(this)






            value=getVarValue(this);
        end

        function name=getVariableName(this)


            name=getVarName(this);
        end
    end

    methods(Access=protected,Hidden)

        function value=getVarValue(this)




            if isempty(this.Variable)
                error(message("mlreportgen:report:error:noVariableSpecified"));
            end


            switch lower(this.Location)
            case "matlab"
                try
                    value=evalin("base",this.Variable);
                catch
                    error(message("mlreportgen:report:error:variableNotInBaseWorkspace",...
                    this.Variable));
                end
            case "mat-file"
                if isempty(this.FileName)
                    error(message("mlreportgen:report:error:noFileNameSpecified"));
                end

                fileName=mlreportgen.utils.findFile(this.FileName);
                if~isempty(fileName)
                    fileData=load(fileName,"-mat");
                    if isfield(fileData,this.Variable)
                        value=fileData.(this.Variable);
                    else
                        error(message("mlreportgen:report:error:variableNotInMATFile",...
                        this.Variable,this.FileName));
                    end
                else
                    error(message("mlreportgen:report:error:MATFileNotFound",...
                    this.FileName));
                end
            case "global"
                if~isempty(whos("global",this.Variable))
                    eval(strcat("global ",this.Variable));
                    value=eval(this.Variable);
                else
                    error(message("mlreportgen:report:error:globalVariableNotFound",...
                    this.Variable));
                end
            case "local"
                if~isempty(this.LocalVarValue)
                    value=this.LocalVarValue;
                else
                    error(message("mlreportgen:report:error:localVariableNotFound",...
                    this.Variable));
                end
            case "user-defined"
                value=this.UserVarValue;
            case "model"
                if~mlreportgen.utils.internal.isSimulinkReportGeneratorInstalled
                    error(message("mlreportgen:report:error:SLRptGenNotInstalled"));
                end

                if isempty(this.FileName)
                    error(message("mlreportgen:report:error:noFileNameSpecified"));
                end

                try
                    value=slResolve(char(this.Variable),char(this.FileName),'expression');
                catch
                    error(message("mlreportgen:report:error:variableNotInModelWorkspace",...
                    this.Variable,this.FileName));
                end
            end
        end

        function varName=getVarName(this)


            varName=this.Variable;
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








            path=mlreportgen.report.MATLABVariable.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.MATLABVariable");
        end
    end

end


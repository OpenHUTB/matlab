classdef SDD<slreportgen.report.Report























































































    properties(Dependent)










Model
















RootSystem
    end

    properties


















        Title{mlreportgen.report.validators.mustBeBlock(Title,"Title")}=[]



















        Subtitle{mlreportgen.report.validators.mustBeBlock(Subtitle,"Subtitle")}=[]



















        Author{mlreportgen.report.validators.mustBeBlock(Author,"Author")}=[]


































        TitlePageImage{mlreportgen.report.validators.mustBeImageOrSnapshotMaker(TitlePageImage,"Image")}=[]








































        TimeFormat="dd-mmm-yyyy";












        IncludeListOfFigures(1,1)logical=false;












        IncludeListOfTables(1,1)logical=false;














        IncludeSystemHierarchy(1,1)logical=true;










        IncludeDetails(1,1)logical=true;















        IncludeLookupTables(1,1)logical=true;












        IncludeReferencedModels(1,1)logical=true;











        IncludeMaskedSubsystems(1,1)logical=true;











        IncludeCommentedSystems(1,1)logical=false;
















        IncludeVariants="Active";















        IncludeSimulinkLibraries(1,1)logical=true;















        IncludeCustomLibraries(1,1)logical=true;



















        IncludeGlossary(1,1)logical=true;











        IncludeReportDescription(1,1)logical=true;














        DisplayReport(1,1)logical=true;
    end

    properties(Access=private)

        ModelSrc=[];


        RootSystemSrc=[];
    end

    methods
        function sdd=SDD(varargin)

            if(nargin==1)
                varargin=[...
                {"Model"},varargin{1}];
            elseif(nargin==2)
                varargin=[...
                {"Model"},varargin{1}...
                ,{"OutputPath"},varargin{2}];
            elseif(nargin==3)
                varargin=[...
                {"Model"},varargin{1}...
                ,{"OutputPath"},varargin{2}...
                ,{"Type"},varargin{3}];
            end


            sdd=sdd@slreportgen.report.Report(varargin{:});
        end

        function value=get.Model(this)


            value=this.ModelSrc;
        end

        function set.Model(this,value)



            if isempty(value)||(value=="")


                this.ModelSrc=[];
                this.RootSystemSrc=[];
            else
                if slreportgen.utils.isModel(value)


                    this.ModelSrc=value;
                    this.RootSystemSrc=value;
                else

                    error(message("slreportgen:StdRpt:SDD:invalidModelSource"));
                end
            end
        end

        function value=get.RootSystem(this)


            value=this.RootSystemSrc;
        end

        function set.RootSystem(this,value)



            if isempty(value)||(value=="")


                this.ModelSrc=[];
                this.RootSystemSrc=[];
            else
                if slreportgen.utils.isValidSlSystem(value)



                    this.RootSystemSrc=value;

                    modelH=slreportgen.utils.getModelHandle(value);
                    this.ModelSrc=string(get_param(modelH,"Name"));
                else

                    error(message("slreportgen:StdRpt:SDD:invalidRootSystemSource"));
                end
            end
        end

        function set.TimeFormat(this,value)



            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeString(value);


            mustBeMember(value,[...
            "dd-mmm-yyyy HH:MM:SS","dd-mmm-yyyy","mm/dd/yy",...
            "mmm","m","mm","mm/dd","dd","ddd","d","yyyy",...
            "yy","mmmyy","HH:MM:SS","HH:MM:SS PM","HH:MM",...
            "HH:MM PM","QQ-YY","QQ"]);


            this.TimeFormat=value;
        end

        function set.IncludeVariants(this,value)



            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeString(value);


            mustBeMember(lower(value),["active","activepluscode","all"]);


            this.IncludeVariants=value;
        end

        function run(this)














            if isempty(this.RootSystemSrc)||isempty(this.ModelSrc)
                error(message("slreportgen:StdRpt:SDD:noSystemSpecified"));
            end


            open(this);



            makeTitlePage(this);



            makeTableOfContents(this);



            if this.IncludeListOfFigures
                makeListOfFigures(this);
            end



            if this.IncludeListOfTables
                makeListOfTables(this);
            end



            makeModelVersionChapter(this);





            if this.IncludeSystemHierarchy
                makeSystemHierarchyChapter(this);
            end




















            makeDesignDataChapter(this);




            if this.IncludeDetails
                makeModelConfigurationChapter(this);
            end




            if this.IncludeGlossary
                makeGlossaryChapter(this);
            end




            if this.IncludeReportDescription
                makeReportDescriptionChapter(this);
            end


            close(this);


            if this.DisplayReport
                rptview(this);
            end
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(this)



            path=slreportgen.StdRpt.SDD.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,this.Type);
        end
    end

    methods(Static)
        function path=getClassFolder()



            [path]=string(fileparts(mfilename("fullpath")));
        end

        function createTemplate(templatePath,type)







            path=slreportgen.StdRpt.SDD.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReport(toClasspath)




















            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.StdRpt.SDD");
        end

    end
end

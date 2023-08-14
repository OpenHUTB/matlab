classdef BaseTable<mlreportgen.report.Reporter




























































    properties


























        Title{mustBeBlock(Title,"Title")}=[]













        Content{mustBeTabular(Content,"Content")}=[];







        TableStyleName{mlreportgen.report.validators.mustBeString(TableStyleName)}=[];
















        TableWidth{mlreportgen.report.validators.mustBeString(TableWidth)}=[];















        MaxCols{mustBePositiveNumber(MaxCols),mustBeNonempty(MaxCols)}=Inf;











        RepeatCols{mlreportgen.utils.validators.mustBeZeroOrPositiveNumber(RepeatCols),mustBeNonempty(RepeatCols)}=0;









        TableSliceTitleStyleName{mlreportgen.report.validators.mustBeString(TableSliceTitleStyleName)}=[];





















        TableEntryUpdateFcn{mlreportgen.report.validators.mustBeInstanceOf('function_handle',TableEntryUpdateFcn)}
    end

    properties(Access=private,Hidden=true)

        ShouldNumberTableHierarchically=[]
    end

    methods
        function baseTable=BaseTable(varargin)
            if(nargin==1)
                varargin=[{'Content'},varargin];
            end
            baseTable=...
            baseTable@mlreportgen.report.Reporter(varargin{:});
            if isempty(baseTable.TemplateName)
                baseTable.TemplateName='BaseTable';
            end
            if isempty(baseTable.MaxCols)
                baseTable.MaxCols=Inf;
            end
        end

        function impl=getImpl(this,rpt)
            impl=getImpl@mlreportgen.report.Reporter(this,rpt);

            updateFcn=this.TableEntryUpdateFcn;
            if(~isempty(updateFcn))
                try
                    for objs=impl.Children
                        if isa(objs,"mlreportgen.dom.Table")||isa(objs,"mlreportgen.dom.FormalTable")||...
                            isa(objs,"mlreportgen.dom.MATLABTable")
                            tableChildren=objs.Children;
                            if isa(tableChildren,"mlreportgen.dom.TableSection")
                                for tableSectionObject=tableChildren
                                    traverseTableEntriesUpdateFunction(tableSectionObject.Children,updateFcn);
                                end
                            else
                                traverseTableEntriesUpdateFunction(tableChildren,updateFcn);
                            end
                        end
                    end
                catch me
                    warning(message("mlreportgen:report:warning:updateFcnError","TableEntryUpdateFcn",me.message));
                end
            end
        end

        function title=getTitleReporter(baseTable)










            title=[];
            if isa(baseTable.Title,'mlreportgen.report.Reporter')
                title=baseTable.Title;
            end

            if isempty(title)
                title=mlreportgen.report.Title("Title");
                title.Translations.Owner='BaseTable';
                title.Translations.NumberPrefixSuffix=baseTable.getTranslations();
                title.Content=baseTable.Title;
                title.TemplateSrc=baseTable;

                if baseTable.ShouldNumberTableHierarchically
                    title.TemplateName='BaseTableHierNumberedTitle';
                else
                    title.TemplateName='BaseTableNumberedTitle';
                end

            end
        end

        function reporter=getContentReporter(baseTable)




























            reporter=[];
            content=[];

            if isa(baseTable.Content,'mlreportgen.report.ReporterBase')
                reporter=baseTable.Content;
            end

            if isempty(reporter)
                if isa(baseTable.Content,'mlreportgen.dom.Table')||isa(baseTable.Content,'mlreportgen.dom.FormalTable')||...
                    isa(baseTable.Content,'mlreportgen.dom.MATLABTable')
                    content=baseTable.Content;
                elseif isa(baseTable.Content,'table')
                    content=mlreportgen.dom.MATLABTable(baseTable.Content);
                else
                    if~isempty(baseTable.Content)
                        content=mlreportgen.dom.Table(baseTable.Content);
                    end
                end

                if~isempty(content)
                    if isempty(content.StyleName)
                        if isempty(baseTable.TableStyleName)
                            content.StyleName='BaseTableContent';
                        else
                            content.StyleName=baseTable.TableStyleName;
                        end
                    end
                    if isempty(content.Width)
                        if~isempty(baseTable.TableWidth)
                            content.Width=baseTable.TableWidth;
                        end
                    end
                end


                reporter=mlreportgen.report.BlockContent("Content");
                reporter.TemplateName='BaseTableContent';
                reporter.TemplateSrc=baseTable;
                reporter.Content=sliceContent(baseTable,content);
            end
        end

        function appendTitle(baseTable,newTitle)










            oldTitleContent=baseTable.Title;
            if ischar(newTitle)
                newTitle=string(newTitle);
            end






            if isempty(oldTitleContent)
                baseTable.Title=newTitle;
            elseif isa(oldTitleContent,'mlreportgen.dom.Paragraph')
                if~iscell(newTitle)
                    newTitle=num2cell(newTitle);
                end
                newTitleLen=numel(newTitle);
                for idx=1:newTitleLen
                    append(oldTitleContent,newTitle{idx});
                end
            elseif isa(oldTitleContent,'mlreportgen.report.HoleReporter')

                rptrContent=oldTitleContent.Content;
                oldTitleContent.Content=combineContent(rptrContent,newTitle);
            else
                baseTable.Title=combineContent(oldTitleContent,newTitle);
            end

        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.BaseTable})
        function content=getTitle(baseTable,rpt)

            baseTable.ShouldNumberTableHierarchically=isChapterNumberHierarchical(baseTable,rpt);

            if mlreportgen.report.Reporter.isInlineContent(baseTable.Title)
                content=getTitleReporter(baseTable);
            else
                content=baseTable.Title;
            end

        end


        function content=getContent(baseTable,rpt)%#ok<INUSD>
            content=getContentReporter(baseTable);
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access=private)

        function slicedContents=sliceContent(baseTable,content)
            if(isa(content,'mlreportgen.dom.Table')||isa(content,'mlreportgen.dom.FormalTable'))...
                &&(baseTable.MaxCols~=Inf)

                slicer=mlreportgen.utils.TableSlicer(...
                "Table",content,...
                "MaxCols",baseTable.MaxCols,...
                "RepeatCols",baseTable.RepeatCols);

                slices=slice(slicer);
                slicedContents=cell(1,length(slices)*2);
                ind=1;
                for tableSlice=slices
                    if(baseTable.RepeatCols>0)
                        str=getString(message("mlreportgen:report:BaseTable:slicedContentRepeatColsTitle",...
                        1,baseTable.RepeatCols,tableSlice.StartCol,tableSlice.EndCol));
                    else
                        str=getString(message("mlreportgen:report:BaseTable:slicedContentTitle",...
                        tableSlice.StartCol,tableSlice.EndCol));
                    end
                    para=mlreportgen.dom.Paragraph(str);
                    if isempty(baseTable.TableSliceTitleStyleName)
                        para.StyleName="BaseTableSlicedTableContentTitle";
                    else
                        para.StyleName=baseTable.TableSliceTitleStyleName;
                    end
                    slicedContents{ind}=para;
                    slicedContents{ind+1}=tableSlice.Table;
                    ind=ind+2;
                end
            else
                slicedContents=content;
            end

        end

        function inlineContent=getTitleInlineContent(baseTable,content,inlineContent)




            if isa(content,'mlreportgen.report.HoleReporter')
                inlineContent=getTitleInlineContent(baseTable,content.Content,inlineContent);
            elseif iscell(content)
                for i=1:numel(content)
                    inlineContent=getTitleInlineContent(baseTable,content{i},inlineContent);
                end
            else
                num=numel(content);
                if num>1
                    for i=1:num
                        inlineContent=getTitleInlineContent(baseTable,content(i),inlineContent);
                    end
                else
                    if ischar(content)||isstring(content)
                        inlineContent=inlineContent+string(content);
                    elseif isa(content,'mlreportgen.dom.Text')
                        inlineContent=inlineContent+content.Content;
                    end
                end
            end
        end
    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.BaseTable.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)











            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.BaseTable");
        end

        function translations=getTranslations()


            persistent INSTANCE;
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.ReporterBase.parseTranslation(...
                mlreportgen.report.BaseTable.getClassFolder(),...
                "BaseTableTitleNumberPrefixSuffix.xml");
            end
            translations=INSTANCE;
        end
    end
end

function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end

function mustBeTabular(varargin)
    mlreportgen.report.validators.mustBeTabular(varargin{:});
end

function mustBePositiveNumber(varargin)
    mlreportgen.utils.validators.mustBePositiveNumber(varargin{:});
end

function combined=combineContent(a,b)




    if ischar(a)
        a=string(a);
    end
    if ischar(b)
        b=string(b);
    end

    if isstring(a)&&isstring(b)

        combined=strcat(strjoin(a,""),strjoin(b,""));
    else
        if~strcmp(class(a),class(b))

            if~iscell(a)
                a=num2cell(a);
            end
            if~iscell(b)
                b=num2cell(b);
            end
        end


        if~isrow(a)
            a=a';
        end
        if~isrow(b)
            b=b';
        end
        combined=[a,b];
    end
end

function traverseTableEntriesUpdateFunction(rows,updateFcn)
    for tableRowObject=rows
        for tableEntryObject=tableRowObject.Children
            updateFcn(tableEntryObject);
        end
    end
end
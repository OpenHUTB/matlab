classdef HTMLModuleTabs<mlreportgen.report.Reporter




















































































































    properties













        TabsData=[];
    end

    methods
        function this=HTMLModuleTabs(varargin)
            this=this@mlreportgen.report.Reporter(varargin{:});


            if isempty(this.TemplateName)
                this.TemplateName="HTMLModuleTabs";
            end


            if isempty(this.TabsData)



                tabDataStruct=struct("Label",[],"Content",[]);
                this.TabsData=tabDataStruct([]);
            end
        end

        function set.TabsData(this,value)

            if isstruct(value)&&(numel(fieldnames(value))==2)&&...
                isfield(value,"Label")&&isfield(value,"Content")
                this.TabsData=value;
            else
                error(message("mlreportgen:report:HTMLModuleTabs:invalidTabsData",class(this)));
            end
        end

        function impl=getImpl(this,rpt)
            if~(strcmpi(rpt.Type,"HTML")||strcmpi(rpt.Type,"HTML-FILE"))

                error(message("mlreportgen:report:HTMLModuleTabs:invalidReportType",class(this),rpt.Type));
            end

            if isempty(this.TabsData)

                error(message("mlreportgen:report:HTMLModuleTabs:noTabsDataSpecified",class(this)));
            end


            impl=getImpl@mlreportgen.report.Reporter(this,rpt);
        end

    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.HTMLModuleTabs})
        function tabsLabel=getTabsLabelArea(this,rpt)


            nTabs=length(this.TabsData);
            tabsLabel=cell(1,nTabs);

            for i=1:nTabs
                currentTabLabel=this.TabsData(i).Label;


                if isempty(currentTabLabel)||...
                    (isstring(currentTabLabel)&&(currentTabLabel==""))||...
                    (isa(currentTabLabel,"mlreportgen.dom.Text")&&isempty(currentTabLabel.Content))
                    error(message("mlreportgen:report:HTMLModuleTabs:emptyTabLabel"));
                elseif ischar(currentTabLabel)||isstring(currentTabLabel)||...
                    isa(currentTabLabel,"mlreportgen.dom.Text")
                    labelToAppend=currentTabLabel;
                else
                    error(message("mlreportgen:report:HTMLModuleTabs:invalidTabLabel"));
                end

                tabLabelDocPart=mlreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,"HTMLModuleTabsLabel");
                openImpl(this,tabLabelDocPart);
                moveToNextHole(tabLabelDocPart);
                append(tabLabelDocPart,labelToAppend);
                close(tabLabelDocPart);

                tabsLabel(i)={tabLabelDocPart};
            end
        end

        function tabsContent=getTabsContentArea(this,rpt)


            nTabs=length(this.TabsData);
            tabsContent=cell(1,nTabs);

            for i=1:nTabs
                currentTabContent=this.TabsData(i).Content;


                if ischar(currentTabContent)||isstring(currentTabContent)||...
                    isa(currentTabContent,"mlreportgen.dom.Node")
                    contentToAppend=currentTabContent;
                elseif isa(currentTabContent,"mlreportgen.report.ReporterBase")
                    contentToAppend=currentTabContent.getImpl(rpt);
                else
                    error(message("mlreportgen:report:HTMLModuleTabs:invalidTabContent"));
                end

                tabContentDocPart=mlreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,"HTMLModuleTabsContent");
                openImpl(this,tabContentDocPart);
                moveToNextHole(tabContentDocPart);
                append(tabContentDocPart,contentToAppend);
                close(tabContentDocPart);

                tabsContent(i)={tabContentDocPart};
            end
        end

    end

    methods(Static)
        function path=getClassFolder()



            [path]=fileparts(mfilename("fullpath"));
        end

        function template=createTemplate(templatePath,type)









            if~(strcmpi(type,"HTML")||strcmpi(type,"HTML-FILE"))

                error(message("mlreportgen:report:HTMLModuleTabs:invalidTemplateType",type));
            end

            path=mlreportgen.report.HTMLModuleTabs.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)










            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.HTMLModuleTabs");
        end

    end
end
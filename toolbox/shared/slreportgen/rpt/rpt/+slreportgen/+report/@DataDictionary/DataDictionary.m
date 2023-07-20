classdef DataDictionary<slreportgen.report.Reporter










































































    properties





Dictionary

























        SummaryProperties{mlreportgen.report.validators.mustBeVectorOf(["string","char"],SummaryProperties)}=["Name","Value","Class","LastModified","LastModifiedBy","Status","DataSource"];








        ShowDesignData{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;








        ShowConfigurations{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;








        ShowOtherData{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;










        IncludeReferencedDictionaries{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;





























        ReferencedDictionaryPolicy="SameTable";




























        EntryFilterFcn;












SummaryTableReporter












        DetailsReporter;














        ConfigurationReporter;









ListFormatter
    end

    properties(Access=public,Hidden)


Name


Path
    end

    properties(Constant,Hidden)

        LabelParaStyle="DataDictionaryParagraph";
    end

    properties(Access=private)









ReportedEntriesMap
    end

    methods
        function this=DataDictionary(varargin)
            if nargin==1

                varargin=["Dictionary",varargin];
            end

            this=this@slreportgen.report.Reporter(varargin{:});


            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","DataDictionary");

            baseTable=mlreportgen.report.BaseTable;
            baseTable.TableStyleName="DataDictionaryTable";
            addParameter(p,"SummaryTableReporter",baseTable);

            list=mlreportgen.dom.UnorderedList;
            list.StyleName="DataDictionaryList";
            addParameter(p,"ListFormatter",list);

            varRptr=mlreportgen.report.MATLABVariable;
            addParameter(p,"DetailsReporter",varRptr);

            configRptr=slreportgen.report.ModelConfiguration;
            addParameter(p,"ConfigurationReporter",configRptr);


            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.SummaryTableReporter=results.SummaryTableReporter;
            this.ListFormatter=results.ListFormatter;
            this.DetailsReporter=results.DetailsReporter;
            this.ConfigurationReporter=results.ConfigurationReporter;
        end

    end

    methods
        function set.Dictionary(this,value)


            mustBeNonempty(value);

            mlreportgen.report.validators.mustBeString(value);

            this.Dictionary=value;
        end

        function set.ReferencedDictionaryPolicy(this,value)


            mustBeNonempty(value);

            mlreportgen.report.validators.mustBeString(value);

            mustBeMember(lower(value),["sametable","separatetables","list"]);

            this.ReferencedDictionaryPolicy=value;
        end

        function set.ListFormatter(this,value)


            mustBeNonempty(value);

            mlreportgen.report.validators.mustBeInstanceOfMultiClass(...
            {'mlreportgen.dom.UnorderedList','mlreportgen.dom.OrderedList'},value)


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            this.ListFormatter=value;
        end

        function set.SummaryTableReporter(this,value)

            mustBeNonempty(value);

            mlreportgen.report.validators.mustBeInstanceOf("mlreportgen.report.BaseTable",value);

            this.SummaryTableReporter=value;
        end

        function set.DetailsReporter(this,value)

            mustBeNonempty(value);

            mlreportgen.report.validators.mustBeInstanceOf("mlreportgen.report.MATLABVariable",value);

            this.DetailsReporter=value;
        end

        function set.ConfigurationReporter(this,value)

            mustBeNonempty(value);

            mustBeA(value,["slreportgen.report.ModelConfiguration","mlreportgen.report.MATLABVariable"])

            this.ConfigurationReporter=value;
        end

        function impl=getImpl(this,rpt)
            dd=this.Dictionary;
            if isempty(dd)

                error(message("slreportgen:report:error:noDataDictionarySpecified"));
            end


            if~isempty(this.ListFormatter.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            prepareReportedVariables(this);


            cleanupVar=onCleanup(@()set(this,"ReportedEntriesMap",[]));


            if isempty(this.LinkTarget)
                this.LinkTarget=slreportgen.report.DataDictionary.getLinkTargetID(this.Path);
            end



            impl=getImpl@slreportgen.report.Reporter(this,rpt);
        end



    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=slreportgen.report.DataDictionary.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.DataDictionary})

        function content=getDesignDataSummaryContent(this,rpt)
            content={};
            if this.ShowDesignData

                content=getSummaryContent(this,"Design Data",rpt);




                if this.IncludeReferencedDictionaries&&strcmpi(this.ReferencedDictionaryPolicy,"list")
                    listLabel=mlreportgen.dom.Paragraph(...
                    getString(message("slreportgen:report:DataDictionary:referencedDictionaries")),...
                    this.LabelParaStyle);
                    list=clone(this.ListFormatter);


                    ddStruct=this.ReportedEntriesMap("Design Data");
                    refDDs={ddStruct.Source};



                    nRefs=numel(refDDs);
                    for k=2:nRefs
                        ref=refDDs{k};


                        refPath=which(ref);
                        link=mlreportgen.dom.InternalLink(...
                        slreportgen.report.DataDictionary.getLinkTargetID(refPath),...
                        ref);
                        append(list,link);
                    end


                    if~isempty(list.Children)
                        content=[content,{listLabel,list}];
                    end
                end
            end
        end

        function content=getDesignDataDetailsContent(this,~)
            content={};
            if this.ShowDesignData


                content=getDetailsContent(this,"Design Data",this.DetailsReporter);
            end
        end

        function content=getConfigurationsSummaryContent(this,rpt)
            content={};
            if this.ShowConfigurations

                content=getSummaryContent(this,"Configurations",rpt);
            end
        end

        function content=getConfigurationsDetailsContent(this,~)
            content={};
            if this.ShowConfigurations


                content=getDetailsContent(this,"Configurations",this.ConfigurationReporter);
            end
        end

        function content=getOtherDataSummaryContent(this,rpt)
            content={};
            if this.ShowOtherData

                content=getSummaryContent(this,"Other Data",rpt);
            end
        end

        function content=getOtherDataDetailsContent(this,~)
            content={};
            if this.ShowOtherData


                content=getDetailsContent(this,"Other Data",this.DetailsReporter);
            end
        end

    end

    methods(Access=private)
        function content=getSummaryContent(this,ddSection,rpt)
            content={};





            ddStructs=this.ReportedEntriesMap(ddSection);


            props=string(this.SummaryProperties);
            nProps=numel(props);


            nSources=numel(ddStructs);
            for srcIdx=1:nSources

                ddEntries=ddStructs(srcIdx).Entries;


                nVars=numel(ddEntries);
                tableData=cell(nVars,nProps);
                for k=1:nVars
                    varEntry=ddEntries(k);
                    value=getValue(varEntry);

                    for propIdx=1:nProps
                        prop=props(propIdx);

                        switch prop
                        case "Name"


                            tableData{k,propIdx}=mlreportgen.dom.InternalLink(...
                            createEntryLinkTarget(this,ddSection,varEntry),...
                            varEntry.Name);
                        case "Value"
                            tableData{k,propIdx}=getReportedValue(this,value);
                        case "Class"
                            tableData{k,propIdx}=class(value);
                        case "LastModified"







                            tableData{k,propIdx}=string(datetime(varEntry.(prop),"Locale","en_US"),'yyyy-MM-dd HH:mm');
                        otherwise
                            try
                                tableData{k,propIdx}=varEntry.(prop);
                            catch

                                warning(message("slreportgen:report:warning:invalidEntryProperty",prop))
                            end
                        end
                    end


                end


                if~isempty(tableData)

                    tblRptr=copy(this.SummaryTableReporter);
                    tblRptr.Content=mlreportgen.dom.FormalTable(props,tableData);
                    titleStr=ddStructs(srcIdx).Source+" "+ddSection;
                    appendTitle(tblRptr,titleStr);



                    tblRptr.LinkTarget=createSummaryLinkTarget(this,ddSection);



                    titleReporter=getTitleReporter(tblRptr);
                    titleReporter.TemplateSrc=this;
                    if isChapterNumberHierarchical(this,rpt)
                        titleReporter.TemplateName="DataDictionaryHierNumberedTitle";
                    else
                        titleReporter.TemplateName="DataDictionaryNumberedTitle";
                    end
                    tblRptr.Title=titleReporter;

                    content{end+1}=tblRptr;%#ok<AGROW>
                end

            end



            if~isempty(content)
                labelPara=mlreportgen.dom.Paragraph(...
                ddSection+" "+getString(message("slreportgen:report:DataDictionary:summary")),...
                this.LabelParaStyle);
                content=[{labelPara},content];
            end
        end

        function val=getReportedValue(~,value)


            val=value;
            if isa(value,'Simulink.Parameter')


                val=val.Value;
            end

            if(isnumeric(val)||islogical(val)||isstring(val))&&...
                isscalar(val)


                val=num2str(val);
            elseif~ischar(val)||(min(size(val))>1)


                val=getString(message("slreportgen:report:DataDictionary:seeDetails"));
            end
        end

        function content=getDetailsContent(this,ddSection,detailsRptr)
            content={};



            ddStructs=this.ReportedEntriesMap(ddSection);


            isConfig=isa(detailsRptr,"slreportgen.report.ModelConfiguration");


            ddEntries=vertcat(ddStructs.Entries);
            nVars=numel(ddEntries);
            summaryLinkTarget=createSummaryLinkTarget(this,ddSection);
            for k=1:nVars
                entryObj=ddEntries(k);
                entryName=entryObj.Name;
                entryRptr=copy(detailsRptr);
                if isConfig
                    entryRptr.Title=entryName;
                    entryRptr.setConfigSet(entryObj.getValue);
                else
                    entryRptr.Variable=entryName;
                    entryRptr.setVariableValue(entryObj.getValue);
                end




                entryRptr.LinkTarget=createEntryLinkTarget(this,ddSection,entryObj);


                entryRptr.Title=mlreportgen.dom.InternalLink(...
                summaryLinkTarget,entryName);

                content=[content,{mlreportgen.dom.Paragraph,entryRptr}];%#ok<AGROW>
            end



            if~isempty(content)
                labelPara=mlreportgen.dom.Paragraph(...
                ddSection+" "+getString(message("slreportgen:report:DataDictionary:details")),...
                this.LabelParaStyle);
                content=[{labelPara},content];
            end
        end

        function prepareReportedVariables(this)
            dd=this.Dictionary;


            [folder,name,ext]=fileparts(dd);
            if~strcmpi(ext,"")&&~strcmpi(ext,".sldd")
                error(message("slreportgen:report:error:invalidDataDictionary",dd));
            end
            dictName=strcat(name,".sldd");
            this.Name=dictName;



            dictPath=fullfile(folder,dictName);
            dictObj=Simulink.data.dictionary.open(dictPath);
            this.Path=dictObj.filepath;


            sectionNames=["Design Data","Configurations","Other Data"];
            sectionNames=sectionNames([this.ShowDesignData,...
            this.ShowConfigurations,...
            this.ShowOtherData]);
            nSections=numel(sectionNames);




            entriesMap=containers.Map();

            for idx=1:nSections
                sectName=sectionNames(idx);
                dataSect=getSection(dictObj,sectName);



                sources={this.Name};
                if this.IncludeReferencedDictionaries
                    allEntries=filterEntries(this,find(dataSect));


                    policy=this.ReferencedDictionaryPolicy;
                    if strcmpi(policy,"sametable")

                        entries=allEntries;
                    else




                        allEntryDataSrc={allEntries.DataSource};









                        sources=union(this.Name,[dictObj.DataSources',allEntryDataSrc],'stable');
                        nSources=numel(sources);


                        entries=cell(1,nSources);
                        entries{1}=allEntries(strcmp(allEntryDataSrc,sources{1}));




                        if strcmpi(policy,"separatetables")
                            for k=2:nSources
                                entries{k}=allEntries(strcmp(allEntryDataSrc,sources{k}));
                            end
                        end
                    end

                else


                    entries=filterEntries(this,find(dataSect,"DataSource",this.Name));
                end





                ddStruct=struct("Source",cellstr(sources),"Entries",entries);
                entriesMap(sectName)=ddStruct;
            end

            this.ReportedEntriesMap=entriesMap;
        end

        function filteredEntries=filterEntries(this,entries)


            filterFcn=this.EntryFilterFcn;
            if~isempty(filterFcn)
                nEntries=numel(entries);
                toKeep=true(1,nEntries);
                for k=1:nEntries
                    entryObj=entries(k);
                    toKeep(k)=~isFilteredEntry(filterFcn,entryObj,entryObj.getValue);
                end
                filteredEntries=entries(toKeep);
            else
                filteredEntries=entries;
            end
        end

        function targetStr=createEntryLinkTarget(this,ddSection,varEntry)

            targetStr=mlreportgen.utils.normalizeLinkID(...
            "DataDictionary-"+this.Path+"-"+ddSection+"-"+varEntry.Name);
        end

        function targetStr=createSummaryLinkTarget(this,ddSection)

            targetStr=mlreportgen.utils.normalizeLinkID(...
            "DataDictionary-"+this.Path+"-"+ddSection);
        end

    end

    methods(Static,Hidden)
        function id=getLinkTargetID(ddPath)



            id=mlreportgen.utils.normalizeLinkID(...
            "DataDictionary-"+ddPath);
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








            path=slreportgen.report.DataDictionary.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classFile=customizeReporter(toClasspath)









            classFile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.DataDictionary");
        end
    end
end

function isFiltered=isFilteredEntry(entryFilterFcn,entryObject,entryValue)









    isFiltered=false;
    try
        if isa(entryFilterFcn,'function_handle')
            isFiltered=entryFilterFcn(entryObject,entryValue);
        else



            eval(entryFilterFcn);
        end

    catch me
        warning(message("mlreportgen:report:warning:filterFcnError","EntryFilterFcn",me.message));
    end

end

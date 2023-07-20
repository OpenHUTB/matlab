
classdef DetailSection<handle

    properties
        DetailData;
        SummaryData;

        SummaryCaption;
        DetailCaption;
        DetailTableHeader;
        SummaryTableHeader;

        SectionDetail;
        SectionSummary;

        ReportUtil;
        Config;
    end

    properties(Dependent)
        Section;
    end

    properties(SetAccess=protected)
        Status;
    end

    methods

        function obj=...
            DetailSection(DetailData,SummaryData,ReportUtil,Config)
            if nargin>0
                obj.DetailData=DetailData;
                obj.SummaryData=SummaryData;
                obj.ReportUtil=ReportUtil;
                obj.Config=Config;
            else
                obj.ReportUtil=slci.internal.ReportUtil;
                obj.Config=slci.internal.ReportConfig;
            end
            obj.initDefaults();
        end


        function set.SummaryCaption(obj,caption)
            obj.SummaryCaption=caption;
        end

        function set.DetailCaption(obj,caption)
            obj.DetailCaption=caption;
        end


        function set.DetailTableHeader(obj,tableheader)
            obj.DetailTableHeader=tableheader;
        end

        function set.SummaryTableHeader(obj,tableheader)
            obj.SummaryTableHeader=tableheader;
        end

        function section=get.Section(obj)
            section=[obj.SectionDetail,obj.SectionSummary];
        end

        function status=get.Status(obj)
            status=obj.Status;
        end
    end

    methods

        function makeDetailSection(obj)

            if isempty(obj.DetailData)

                return;
            end

            if isfield(obj.DetailData,'SECTIONLIST')
                detailList=obj.DetailData.SECTIONLIST;
                sectionTable=cell(numel(detailList),1);
                if numel(detailList)==1
                    expandedDetail=0;
                else
                    expandedDetail=1;
                end

                for m=1:numel(detailList)
                    currentCaption=detailList(m).SECTION.CONTENT;
                    tableData=detailList(m).TABLEDATA;
                    if~isempty(detailList(m).TABLEDATA)
                        sectionTable{m,1}=obj.genDetailSectionTable(...
                        tableData,currentCaption,expandedDetail);
                    else
                        sectionTable{m,1}=obj.genEmptySection(detailList(m).REASON,...
                        currentCaption,...
                        expandedDetail);
                    end
                end
                obj.SectionDetail=obj.ReportUtil.genTable({},sectionTable,0);
                obj.SectionDetail=obj.ReportUtil.genExpandableHtmlTable(...
                obj.ReportUtil.getUniqueKey(),obj.DetailCaption,'',...
                obj.ReportUtil.genExpandableHtmlTableItem({obj.SectionDetail}));
            end
        end


        function makeSummarySection(obj,isExpandable)

            if isempty(obj.SummaryData)

                return;
            end

            if isfield(obj.SummaryData,'STATUS')&&...
                ~isempty(obj.SummaryData.STATUS)
                obj.Status=obj.SummaryData.STATUS.ATTRIBUTES;
                statusMessage=obj.Config.getStatusMessage(obj.Status);
                obj.SummaryCaption=[obj.SummaryCaption,...
                obj.ReportUtil.appendColorAndTip(...
                statusMessage,obj.Status)];
            end

            obj.SummaryCaption=obj.ReportUtil.makeHeader4(obj.SummaryCaption);
            isTableIndented=true;
            obj.SectionSummary=obj.genSectionOfTables(obj.SummaryData.TABLEDATA,...
            obj.SummaryTableHeader,...
            obj.SummaryCaption,...
            isTableIndented,...
            isExpandable);
            obj.SectionSummary=obj.ReportUtil.addLineBreak(obj.SectionSummary);
        end

    end

    methods(Access=protected)

        function initDefaults(obj)
            obj.SectionDetail=obj.Config.defaultSection;
            obj.SectionSummary=obj.Config.defaultSection;
            obj.SummaryTableHeader={};
            obj.DetailTableHeader={};
        end

        function tableSection=genEmptySection(obj,tableData,caption,expanded)
            if expanded
                tableSection=...
                obj.ReportUtil.genExpandableHtmlTableItem({tableData});
                tableSection=obj.ReportUtil.genExpandableHtmlTable(...
                obj.ReportUtil.getUniqueKey(),...
                caption,...
                '',...
                tableSection);
            else
                if~isempty(caption)
                    tableData={obj.ReportUtil.makeBold(caption);...
                    tableData};
                    tableSection=obj.ReportUtil.genTable({},tableData,0);
                else
                    tableSection=tableData;
                end
            end
        end

        function section=genSectionOfTables(obj,sectionData,tableHeader,...
            caption,isTableIndented,...
            isExpandable)

            if isfield(sectionData,'SECTIONLIST')

                sections=sectionData.SECTIONLIST;
                numSections=numel(sections);
                tableSection=[];
                for k=1:numSections
                    sectionCaption=sectionData.SECTIONLIST(k).SECTION.CONTENT;
                    sectionCaption=obj.ReportUtil.makeHeader4(sectionCaption);
                    tableHeader=sectionData.SECTIONLIST(k).TABLEHEADER;
                    tableData=sectionData.SECTIONLIST(k).TABLEDATA;
                    tableSection=[tableSection...
                    ,obj.genSectionOfTables(tableData,...
                    tableHeader,...
                    sectionCaption,...
                    false,...
                    isExpandable)];%#ok<AGROW>
                end
            else

                tData=obj.fieldsToCell(sectionData);
                tableSection=obj.ReportUtil.genTable(tableHeader,tData,1);
            end

            if isTableIndented
                tableSection=obj.ReportUtil.indentSection(tableSection);
            end
            if isExpandable
                section=obj.ReportUtil.genExpandableHtmlTable(...
                obj.ReportUtil.getUniqueKey(),caption,'',...
                obj.ReportUtil.genExpandableHtmlTableItem({tableSection}));
            else
                section=[caption,tableSection];
            end
        end


        function tableSection=genDetailSectionTable(obj,tableData,caption,expanded)
            fnames=fields(tableData);
            tData=cell(numel(tableData),numel(fnames));
            for p=1:numel(tableData)
                for k=1:numel(fnames)
                    dataInfo=...
                    obj.processField(tableData(p).(fnames{k}),fnames{k});
                    tData{p,k}=dataInfo.CONTENT;
                end
            end
            tableSection=...
            obj.ReportUtil.genTable(obj.DetailTableHeader,tData,1);
            if(expanded)
                tableSection=obj.ReportUtil.genExpandableHtmlTable(...
                obj.ReportUtil.getUniqueKey(),caption,'',...
                obj.ReportUtil.genExpandableHtmlTableItem({tableSection}));
            else
                tableSection={obj.ReportUtil.makeBold(caption);...
                tableSection};
                tableSection=obj.ReportUtil.genTable({},tableSection,0);
            end
        end



        function OpData=processField(obj,data,field)
            if isempty(data)
                OpData.CONTENT='';
            else
                switch(field)
                case 'STATUS'

                    OpData.CONTENT=obj.ReportUtil.appendColorAndTip(...
                    data.CONTENT,data.ATTRIBUTES);
                case 'SUBSTATUS'
                    OpData.CONTENT=data.CONTENT;
                case{'SLICELIST','OBJECTLIST','COUNTLIST',...
                    'SOURCELIST','ATTRIBUTELIST'}

                    dataCell=obj.fieldsToCell(data);
                    OpData.CONTENT=...
                    obj.ReportUtil.genTable({},dataCell,0);
                case 'CODE'
                    OpData.CONTENT=obj.ReportUtil.formatCode(data.CONTENT);
                case 'REASON'
                    if obj.Config.isScheme(data.ATTRIBUTES)
                        OpData.CONTENT=...
                        obj.ReportUtil.appendColorAndTip(...
                        data.CONTENT,data.ATTRIBUTES);
                    else
                        OpData.CONTENT=...
                        obj.ReportUtil.appendColorAndTip(...
                        data.CONTENT,'UNKNOWN');
                    end
                case 'FUNCTION'
                    OpData.CONTENT=data.CONTENT;
                case 'COUNT'
                    if isfield(data,'ATTRIBUTES')
                        OpData.CONTENT=obj.ReportUtil.appendColorAndTip(...
                        data.CONTENT,data.ATTRIBUTES);
                    else
                        OpData.CONTENT=data.CONTENT;
                    end
                otherwise
                    OpData.CONTENT=data.CONTENT;
                end

            end
        end



        function dataCell=fieldsToCell(obj,tableData)
            if~isempty(tableData)
                fnames=fields(tableData);
                numCols=numel(fnames);
                numRows=numel(tableData);
                dataCell=cell(numRows,numCols);
                for p=1:numCols
                    for k=1:numRows
                        fname=fnames{p};
                        dataInfo=...
                        obj.processField(tableData(k).(fname),fname);
                        dataCell{k,p}=dataInfo.CONTENT;
                    end
                end
            else
                dataCell={''};
            end
        end

    end




end

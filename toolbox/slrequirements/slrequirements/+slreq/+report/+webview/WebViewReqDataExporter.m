classdef WebViewReqDataExporter<handle
    properties(Constant)
        EXPORT_FILE_NAME='slreq_data.json';
        REQ_PROPERTY_LIST={'Properties','Type','Index','CustomID',...
        'Summary','Description','Rationale','Keywords',...
        'RevisionInfo','SID','Revision','CreatedBy',...
        'CreatedOn','ModifiedBy','ModifiedOn','Links',...
        'CustomAttributes','Unset',...
        'Comments','NoCommentHistory',...
        'IndexDelimiter',...
        'IndexPrefix',...
        'RefreshedOn'};
        REQSET_PROPERTY_LIST={'Properties','Filepath','Revision','CreatedOn','CreatedBy',...
        'ModifiedBy','ModifiedOn','Description','Keywords',...
        'CustomAttributeRegistries','AttributeEntries'};
        LINK_PROPERTY_LIST={'Properties','Source','Type','Destination',...
        'Description','Rationale','Keywords',...
        'RevisionInfo','SID','Revision','CreatedBy','CreatedOn',...
        'ModifiedBy','ModifiedOn',...
        'CustomAttributes',...
        'Comments','NoCommentHistory',...
        'ChangeInformation','ChangeInfoPanelActualColon','ChangeInfoPanelStoredColon'};

        LINKSET_PROPERTY_LIST={'Properties','Filepath','Artifact',...
        'Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn',...
        'Description','ChangeInformation',...
        'NumTotalLinks','NumLinksHavingChangedSource',...
        'NumLinksHavingChangedDestination',...
        'ChangeStatusUnsupportedArtifact','Source','Destination',...
        'CustomAttributeRegistries','AttributeEntries'};

        CUSTOM_ATTRIBUTE_PROPERTY_LIST={'Type','Name','DefaultValue','List','Description'};

        REQ_LAYOUT_COLUMN_LIST={'Index','ReqID','Summary','Type','Keywords','SID',...
        'CreatedOn','CreatedBy','ModifiedOn','RefreshedOn',...
        'ModifiedBy','Revision'};
        LINK_LAYOUT_COLUMN_LIST={'Label','Source','Type','Destination',...
        'Keywords','SID','CreatedOn','CreatedBy','ModifiedOn',...
        'ModifiedBy','Revision'};
        GENERAL_INFO_MESSAGE={'NoLinks','Requirements','Links','LinkWithSelectedSimulink'}








        CACHE_FOLDER=rmi.Informer.cache('webviewcacheddir');
    end

    properties
        ExportDir;
        ModelName;
        ModelHandle;
        AllModels;
        DataReqSets;
        DataLinkSets;
        IncludeReferencedModels=false;
        IncludeLibraryLinks=false;



ReferencedDocs



DocsToBeExported



        WebViewSupportFileFolder='./support/slwebview_files';
    end
    properties

        LinkTypeInfo=containers.Map('KeyType','char','ValueType','any');


        ReqTypeInfo=containers.Map('KeyType','char','ValueType','any');


        LinkSetDataInfo;

        ReqSetDataInfo;



        BlocksDataInfo;



        SourceDataInfo;
        DestDataInfo;


        ReqAsDstDataInfo;


        LinkDataInfo;


        ReqCommentsData;

        LinkCommentsData;


        ReqCustomAttrRegData;


        LinkCustomAttrRegData;



        ChangeIssueData;


        ReqChangeIssueData;


        Layout;


DestinationDocs


        ReqSetPropertyNameString=containers.Map('KeyType','char','ValueType','any');
        ReqPropertyNameString=containers.Map('KeyType','char','ValueType','any');
        LinkSetPropertyNameString=containers.Map('KeyType','char','ValueType','any');
        LinkPropertyNameString=containers.Map('KeyType','char','ValueType','any');
        CustomAttributesPropertyNameString=containers.Map('KeyType','char','ValueType','any');
        ReqLayoutColumnNameString=containers.Map('KeyType','char','ValueType','any');
        LinkLayoutColumnNameString=containers.Map('KeyType','char','ValueType','any');
        GeneralNameString=containers.Map('KeyType','char','ValueType','any');
    end

    methods

        function this=WebViewReqDataExporter(modelNameOrHandle,opts)
            modelNameOrHandle=bdroot(modelNameOrHandle);
            this.ModelHandle=get_param(modelNameOrHandle,'Handle');
            this.ModelName=get_param(modelNameOrHandle,'Name');
            refModels={this.ModelName};
            if isfield(opts,'includeReferencedModels')&&~isempty(opts.includeReferencedModels)&&opts.includeReferencedModels


                refModels=find_mdlrefs(this.ModelHandle,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                this.IncludeReferencedModels=opts.includeReferencedModels;
            else
                this.IncludeReferencedModels=false;
            end
            libModels={};
            if isfield(opts,'includeLibraryLinks')&&~isempty(opts.includeLibraryLinks)&&opts.includeLibraryLinks
                libModels=getNonBuiltInLibs(this.ModelHandle);
                this.IncludeLibraryLinks=opts.includeLibraryLinks;
            else
                this.IncludeLibraryLinks=false;
            end



            if isfield(opts,'destinationDocs')
                this.createMapFromDestinationDocToCopiedDoc(opts.destinationDocs);
            else
                this.DestinationDocs=containers.Map;

            end

            if isfield(opts,'destDir')
                this.WebViewSupportFileFolder=opts.destDir;
            end

            this.AllModels=unique([refModels;libModels']);

            if isfield(opts,'exportDir')
                this.ExportDir=opts.exportDir;
            end


            this.DataReqSets=slreq.data.RequirementSet.empty;
            this.DataLinkSets=slreq.data.LinkSet.empty;

            this.LinkSetDataInfo={};
            this.ReferencedDocs=containers.Map('KeyType','char','ValueType','char');
            this.DocsToBeExported=containers.Map('KeyType','char','ValueType','logical');
            this.BlocksDataInfo=containers.Map('KeyType','char','ValueType','any');

            this.ReqSetDataInfo={};
            this.SourceDataInfo=containers.Map('KeyType','char','ValueType','any');
            this.ReqAsDstDataInfo=containers.Map('KeyType','char','ValueType','any');
            this.LinkDataInfo=containers.Map('KeyType','char','ValueType','any');
            this.ReqCommentsData=containers.Map('KeyType','char','ValueType','any');
            this.LinkCommentsData=containers.Map('KeyType','char','ValueType','any');
            this.ReqCustomAttrRegData=containers.Map('KeyType','char','ValueType','any');
            this.LinkCustomAttrRegData=containers.Map('KeyType','char','ValueType','any');
            this.ChangeIssueData=containers.Map('KeyType','char','ValueType','any');
            this.ReqChangeIssueData=containers.Map('KeyType','char','ValueType','any');
            this.Layout=containers.Map('KeyType','char','ValueType','any');

            this.updateLinkSetsInfo();
            this.updateReqSetsInfo();
        end

        function export(this)
            this.convertReqSetReferencedDocs();
            this.convertLinkSetReferencedDocs();
            this.traverseAllData();
            this.exportToFile();
        end

        function updateLinkSetsInfo(this)
            allModels=this.AllModels;
            reqData=slreq.data.ReqData.getInstance;
            for mindex=1:length(allModels)
                cModel=allModels{mindex};
                if dig.isProductInstalled('Simulink')&&~bdIsLoaded(cModel)
                    load_system(cModel);
                end

                cDataLinkSet=reqData.getLinkSet(get_param(cModel,'FileName'));
                if~isempty(cDataLinkSet)
                    this.DataLinkSets(end+1)=cDataLinkSet;
                end
            end
        end


        function updateReqSetsInfo(this)
            allReqSetFiles=containers.Map('KeyType','char','ValueType','logical');
            allDataLinkSets=this.DataLinkSets;
            reqData=slreq.data.ReqData.getInstance;

            for cDataLinkSet=allDataLinkSets
                reqSetFiles=cDataLinkSet.getRegisteredRequirementSets();
                for index=1:length(reqSetFiles)
                    allReqSetFiles(reqSetFiles{index})=true;
                end
            end

            reqSetFileList=allReqSetFiles.keys;
            for index=1:length(reqSetFileList)
                cReqSetFile=reqSetFileList{index};
                dataReqSet=reqData.getReqSet(cReqSetFile);



                if~isempty(dataReqSet)
                    this.DataReqSets(end+1)=reqData.getReqSet(cReqSetFile);
                end
            end
        end


        function jsonString=exportToJSONString(this)
            result.LayOut=this.Layout;
            result.ReqSetInfo=this.ReqSetDataInfo;
            result.LinkSetInfo=this.LinkSetDataInfo;
            result.SourceDataInfo=this.SourceDataInfo;
            result.LinkDataInfo=this.LinkDataInfo;
            result.LinkTypeInfo=this.LinkTypeInfo;
            result.ReqTypeInfo=this.ReqTypeInfo;
            result.DestDataInfo=this.ReqAsDstDataInfo;
            result.ReqCommentsData=this.ReqCommentsData;
            result.LinkCommentsData=this.LinkCommentsData;
            result.ReqCustomAttrRegData=this.ReqCustomAttrRegData;
            result.LinkCustomAttrRegData=this.LinkCustomAttrRegData;
            result.ChangeIssueData=this.ChangeIssueData;
            result.ReqChangeIssueData=this.ReqChangeIssueData;
            result.ReqSetPropertyNameString=this.ReqSetPropertyNameString;
            result.LinkSetPropertyNameString=this.LinkSetPropertyNameString;
            result.ReqPropertyNameString=this.ReqPropertyNameString;
            result.LinkPropertyNameString=this.LinkPropertyNameString;
            result.CustomAttributesPropertyNameString=this.CustomAttributesPropertyNameString;
            result.ReqLayoutColumnNameString=this.ReqLayoutColumnNameString;
            result.LinkLayoutColumnNameString=this.LinkLayoutColumnNameString;
            result.GeneralNameString=this.GeneralNameString;
            jsonString=jsonencode(result);
        end


        function exportToFile(this)
            jsonString=this.exportToJSONString();
            filePath=fullfile(this.ExportDir,this.EXPORT_FILE_NAME);
            jsonUnicodeStr=native2unicode(jsonString);
            fid=fopen(filePath,'w','n','UTF-8');
            fprintf(fid,'%s',jsonUnicodeStr);
            fclose(fid);
        end


        function traverseAllData(this)
            this.updateLinkTypeInfo();
            this.updateReqTypeInfo();
            this.traverseLinkSetsData();
            this.traverseReqSetsData();
            this.traverseLayout();
            this.updateMessageMapping();
        end
    end


    methods(Access=private)

        function traverseLayout(this)
            [reqColumns,linkColumns,dispChangeInfo]=queryViewSetting(this.ModelHandle);
            this.Layout('Req')=reqColumns;
            this.Layout('Link')=linkColumns;
            this.Layout('DisplayChangeInformation')=dispChangeInfo;
        end

        function traverseLinkSetsData(this)
            allLinkSets=this.DataLinkSets;
            for index=1:length(allLinkSets)
                cDataLinkSet=allLinkSets(index);
                this.traverseLinkSetData(cDataLinkSet,num2str(index-1));
                this.updateLinksAsSrc(cDataLinkSet);
            end
        end

        function traverseLinkSetData(this,dataLinkSet,hiearchyIndex)
            linkListInfo=containers.Map('keytype','char','valuetype','any');
            if slreq.utils.isEmbeddedLinkSet(dataLinkSet.filepath)
                filepath=dataLinkSet.artifact;
            else
                filepath=dataLinkSet.filepath;
            end
            label=slreq.uri.getShortNameExt(filepath);
            changeIssue=containers.Map('KeyType','char','ValueType','any');
            linkListInfo('Name')=dataLinkSet.name;
            linkListInfo('FullID')=dataLinkSet.name;
            linkListInfo('IconType')='linkset-icon';
            linkListInfo('Filepath')=filepath;
            linkListInfo('Description')=dataLinkSet.description;
            linkListInfo('Label')=label;
            linkListInfo('Index')=0;
            linkListInfo('HIndex')=hiearchyIndex;
            changeIssue('NumberOfChangedDestination')=dataLinkSet.numberOfChangedDestination;
            changeIssue('NumberOfLinks')=numel(dataLinkSet.getAllLinks);
            this.ChangeIssueData(dataLinkSet.name)=changeIssue;
            linkListInfo('Artifact')=dataLinkSet.artifact;
            numberLinks=length(dataLinkSet.getAllLinks);
            linkListInfo('Source')=getString(message('Slvnv:slreq:ChangeInfoChangedSourceInLinkSet',...
            dataLinkSet.numberOfChangedSource,numberLinks));

            linkListInfo('Destination')=getString(message('Slvnv:slreq:ChangeInfoChangedDestinationInLinkSet',...
            dataLinkSet.numberOfChangedDestination,numberLinks));

            linkListInfo('Domain')=dataLinkSet.domain;
            linkListInfo('CreatedOn')=slreq.utils.getDateStr(dataLinkSet.createdOn);
            linkListInfo('CreatedBy')=dataLinkSet.createdBy;
            linkListInfo('ModifiedOn')=slreq.utils.getDateStr(dataLinkSet.modifiedOn);
            linkListInfo('ModifiedBy')=dataLinkSet.modifiedBy;
            linkListInfo('Revision')=dataLinkSet.revision;
            linkListInfo('Children')=this.traverseLinksData(dataLinkSet,linkListInfo('HIndex'));
            linkListInfo('__##type##__')='sllinkset';

            linkListInfo('__##CustomAttNameList##__')=dataLinkSet.CustomAttributeNames;
            this.updateCustomAttributesForLinkSet(dataLinkSet,dataLinkSet.CustomAttributeNames);

            this.LinkSetDataInfo{end+1}=linkListInfo;
        end


        function out=traverseLinksData(this,dataLinkSet,parentIndex)
            out={};
            artifactName=dataLinkSet.name;
            allLinks=dataLinkSet.getAllLinks;
            for index=1:length(allLinks)
                cLink=allLinks(index);
                cLinkInfo=containers.Map;
                cLinkInfo('FullID')=cLink.getFullID;
                cLinkInfo('Index')=index;
                cLinkInfo('HIndex')=[parentIndex,'/',num2str(index-1)];
                cLinkInfo('IconType')='link-icon';

                linkSource=cLink.source;
                if~linkSource.isValid
                    cLinkInfo('IconType')='link-icon-invalid';
                end
                cLinkInfo('SourceFullID')=linkSource.getSID;
                cLinkInfo('SourceDomain')=linkSource.domain;

                cLinkInfo('SourceIconType')=[getLinkTargetClass(cLink.source),'-icon'];
                cLinkInfo('SourceTargetType')=getLinkTargetClass(cLink.source);


                [srcIconPath,srcStr,srcTooltip]=cLink.getSrcIconSummaryTooltip();

                cLinkInfo('SourceSummary')=srcStr;
                cLinkInfo('SourceIcon')=srcIconPath;
                cLinkInfo('SourceTooltip')=srcTooltip;
                cLinkInfo('Source')=srcStr;


                [dstIconPath,dstStr,dstTooltip]=cLink.getDestIconSummaryTooltip();

                linkDst=cLink.dest;
                [destAdapter,destUri,destID]=cLink.getDestAdapter();
                if~isempty(linkDst)&&destAdapter.isResolved(destUri,destID)
                    linkTargetClass=getLinkTargetClass(linkDst);
                else
                    linkTargetClass='unresolved-item';
                    cLinkInfo('IconType')='link-icon-invalid';
                end

                cLinkInfo('DestinationDomain')=cLink.destDomain;
                cLinkInfo('DestinationIconType')=[linkTargetClass,'-icon'];
                cLinkInfo('DestinationTargetType')=[linkTargetClass];

                cLinkInfo('DestinationIcon')=dstIconPath;
                cLinkInfo('DestinationTooltip')=dstTooltip;
                cLinkInfo('DestinationSummary')=dstStr;
                cLinkInfo('Destination')=dstStr;


                if strcmpi(cLink.destDomain,'linktype_rmi_slreq')&&slreq.utils.hasValidDest(cLink)
                    cLinkInfo('DestinationFullID')=cLink.dest.getFullID;
                    cLinkInfo('IsExternal')=false;
                elseif strcmpi(cLink.destDomain,'linktype_rmi_simulink')
                    [~,artifactUri,dstArtifactID]=cLink.getDestAdapter;
                    [~,dstArtifactName]=fileparts(artifactUri);
                    if strcmpi(artifactName,dstArtifactName)


                        cLinkInfo('DestinationFullID')=[dstArtifactName,dstArtifactID];
                        cLinkInfo('IsExternal')=false;
                    else


                        cLinkInfo('DestinationSummary')=[dstStr,'(',dstArtifactName,')'];
                        cLinkInfo('DestinationFullID')=[dstArtifactName,dstArtifactID];
                        cLinkInfo('IsExternal')=true;
                    end
                else
                    cLinkInfo('IsExternal')=true;
                end


                if cLinkInfo('IsExternal')

                    if~isempty(cLink.dest)

                        destClickStr=destAdapter.getURL(destUri,destID);

                        cLinkInfo('DestinationNavigateCmd')=destClickStr;
                        cLinkInfo('DestinationSummary')=destAdapter.getSummary(destUri,destID);
                        cLinkInfo('DestinationTooltip')=destAdapter.getTooltip(destUri,destID);
                        cLinkInfo('DestinationFullID')=[destUri,destID];
                    end
                end


                cLinkInfo('Description')=cLink.description;
                cLinkInfo('Label')=cLink.description;
                cLinkInfo('Rationale')=cLink.rationale;
                cLinkInfo('__##type##__')='sllink';
                typeInfo=this.LinkTypeInfo(cLink.type);
                cLinkInfo('Type')=typeInfo.ForwardName;
                cLinkInfo('TypeName')=cLink.type;
                cLinkInfo('TypeForwardName')=typeInfo.ForwardName;
                cLinkInfo('TypeBackwardName')=typeInfo.BackwardName;
                if isempty(cLink.keywords)
                    cLinkInfo('Keywords')={};
                else
                    cLinkInfo('Keywords')=cLink.keywords;
                end


                cLinkInfo('SID')=cLink.sid;
                cLinkInfo('Revision')=cLink.revision;
                cLinkInfo('CreatedBy')=cLink.createdBy;
                cLinkInfo('CreatedOn')=slreq.utils.getDateStr(cLink.createdOn);
                cLinkInfo('ModifiedBy')=cLink.modifiedBy;
                cLinkInfo('ModifiedOn')=slreq.utils.getDateStr(cLink.modifiedOn);
                cLinkInfo('IsDirectLink')=cLink.isDirectLink;


                cLinkInfo('DestinationChangeStatus')=char(cLink.destinationChangeStatus);


                attNames=dataLinkSet.CustomAttributeNames;
                cLinkInfo('__##CustomAttNameList##__')=attNames;
                for aindex=1:length(attNames)
                    attValue=cLink.getAttribute(attNames{aindex},true);
                    if isdatetime(attValue)
                        attValue=slreq.utils.getDateStr(attValue);
                    end

                    cLinkInfo(attNames{aindex})=attValue;
                end


                this.updateCommentsInfo(cLink);


                this.updateChangeInfo(cLink);
                out{index}=cLinkInfo;%#ok<AGROW>
                this.LinkDataInfo(cLink.getFullID)=cLinkInfo;
            end

            if isempty(out)
                out=[];
            end
        end


        function updateCommentsInfo(this,dataLinkOrReq)
            comments=dataLinkOrReq.comments;
            commentsData=cell(size(comments));
            for index=1:length(comments)
                comment=comments(index);
                tempComment.date=slreq.utils.getDateStr(comment.Date);
                tempComment.commentedBy=comment.CommentedBy;
                tempComment.text=comment.Text;
                tempComment.commentedRevision=comment.CommentedRevision;
                tempComment.CommentTitle=...
                getString(message('Slvnv:slreq:WhoCommentedAtWhenRev',...
                tempComment.commentedBy,tempComment.date,...
                tempComment.commentedRevision));
                commentsData{index}=tempComment;
            end

            if~isempty(commentsData)
                if isa(dataLinkOrReq,'slreq.data.Requirement')
                    this.ReqCommentsData(dataLinkOrReq.getFullID)=commentsData;
                else
                    this.LinkCommentsData(dataLinkOrReq.getFullID)=commentsData;
                end
            end
        end


        function updateChangeInfo(this,dataLink)
            changeIssue=containers.Map('keytype','char','valuetype','any');

            if dataLink.sourceChangeStatus.isFail||dataLink.destinationChangeStatus.isFail

                changeIssue('Title')=getString(message('Slvnv:slreq:ChangeInfoPanelNoChangeDetected'));
                if dataLink.sourceChangeStatus.isInvalidLink
                    changeIssue('SourceChangeStatus')=getString(message('Slvnv:slreq:ChangeInfoPanelUnresolvedLinkSource'));
                else
                    changeIssue('SourceChangeStatus')=getString(message('Slvnv:slreq:ChangeStatusUnsupportedArtifact'));
                end
            end


            changeIssue('IsFail')=false;
            if dataLink.sourceChangeStatus.isInvalidLink
                changeIssue('SourceChangeStatus')=getString(message('Slvnv:slreq:ChangeInfoPanelUnresolvedLinkSource'));
            else
                changeIssue('SourceChangeStatus')=getString(message('Slvnv:slreq:ChangeStatusUnsupportedArtifact'));
            end

            if dataLink.destinationChangeStatus.isInvalidLink
                changeIssue('DestinationChangeStatus')=getString(message('Slvnv:slreq:ChangeInfoPanelUnresolvedLinkDestination'));
            elseif dataLink.destinationChangeStatus.isFail
                changeIssue('IsFail')=true;
                changeIssue('DestinationChangeStatus')=getString(message('Slvnv:slreq:ChangeInfoPanelDestinationChanged'));
                changeIssue('DestinationStoredValue')=slreq.gui.ChangeInformationPanel.getRevisionInfo(dataLink.linkedDestinationRevision,dataLink.linkedDestinationTimeStamp);
                changeIssue('DestinationActualValue')=slreq.gui.ChangeInformationPanel.getRevisionInfo(dataLink.currentDestinationRevision,dataLink.currentDestinationTimeStamp);
            elseif dataLink.destinationChangeStatus.isPass
                changeIssue('DestinationChangeStatus')=slreq.gui.ChangeInformationPanel.getRevisionInfo(dataLink.linkedDestinationRevision,dataLink.linkedDestinationTimeStamp);
            else

                changeIssue('DestinationChangeStatus')='Unknown';
            end
            if changeIssue('IsFail')
                changeIssue('Title')=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueFound'));
            else
                changeIssue('Title')=getString(message('Slvnv:slreq:ReportContentChangeInfoChangeIssueNotFound'));
            end

            this.ChangeIssueData(dataLink.getFullID)=changeIssue;
            if dataLink.destinationChangeStatus.isFail&&slreq.utils.hasValidDest(dataLink)&&strcmpi(dataLink.destDomain,'linktype_rmi_slreq')
                destID=dataLink.dest.getFullID;
                this.ReqChangeIssueData(destID)=true;
            end
        end


        function convertReqSetReferencedDocs(this)
            for cDataReqSet=this.DataReqSets


                allReferencedFiles=cDataReqSet.getImageFileFullNamesToPack();
                this.createMapFromReferencedFileToCopiedFile(allReferencedFiles)
            end
        end


        function convertLinkSetReferencedDocs(this)
            for cDataReqSet=this.DataLinkSets
                allReferencedFiles=getArtifactListForDirectLinks(cDataReqSet);



                this.createMapFromReferencedFileToCopiedFile(allReferencedFiles)
            end
        end


        function traverseReqSetsData(this)
            allReqSet=this.DataReqSets;
            for index=1:length(allReqSet)
                cDataReqSet=allReqSet(index);
                this.traverseReqSetData(cDataReqSet,num2str(index-1));
            end
        end

        function traverseReqSetData(this,dataReqSet,hiearchyIndex)
            reqInfo=containers.Map('keytype','char','valuetype','any');
            reqInfo('Name')=dataReqSet.name;
            reqInfo('Index')=dataReqSet.name;
            reqInfo('HIndex')=hiearchyIndex;
            reqInfo('FullID')=dataReqSet.name;
            reqInfo('Filepath')=dataReqSet.filepath;
            reqInfo('IconType')='reqset-icon';
            reqInfo('IdPrefix')=dataReqSet.idPrefix;
            reqInfo('IdDelimiter')=dataReqSet.idDelimiter;
            reqInfo('Description')=dataReqSet.description;

            reqInfo('__##CustomAttNameList##__')=dataReqSet.CustomAttributeNames;
            this.updateCustomAttributesForReqSet(dataReqSet,dataReqSet.CustomAttributeNames);

            reqInfo('CreatedBy')=dataReqSet.createdBy;
            reqInfo('ModifiedBy')=dataReqSet.modifiedBy;
            reqInfo('CreatedOn')=slreq.utils.getDateStr(dataReqSet.createdOn);
            reqInfo('ModifiedOn')=slreq.utils.getDateStr(dataReqSet.modifiedOn);
            reqInfo('Revision')=dataReqSet.revision;
            reqInfo('__##type##__')='slreqset';
            reqInfo('Children')=this.traverseReqs(dataReqSet,reqInfo('FullID'),hiearchyIndex);
            this.ReqSetDataInfo{end+1}=reqInfo;
        end


        function out=traverseReqs(this,dataReqOrReqSet,parentID,parentIndex)
            out={};
            for index=1:length(dataReqOrReqSet.children)
                cChild=dataReqOrReqSet.children(index);
                cChildInfo=containers.Map;


                cChildInfo('Parent')=parentID;

                if cChild.isJustification
                    cChildInfo('IconType')='slreq-justification-icon';
                elseif cChild.external
                    cChildInfo('IconType')='slreq-ex-icon';
                else
                    cChildInfo('IconType')='slreq-in-icon';
                end
                if cChild.isJustification
                    cChildInfo('Type')='NA';
                else
                    selfTypeInfo=this.ReqTypeInfo(cChild.typeName);
                    if cChild.isChildOfInformationalType()
                        typeInfo=this.ReqTypeInfo('Informational');
                        cChildInfo('IsTypeShadowed')=true;
                    else
                        typeInfo=this.ReqTypeInfo(cChild.typeName);
                        cChildInfo('IsTypeShadowed')=false;
                    end
                    cChildInfo('Type')=typeInfo.DisplayName;
                    cChildInfo('SelfType')=selfTypeInfo.DisplayName;
                end
                cChildInfo('Summary')=cChild.summary;
                cChildInfo('FullID')=cChild.getFullID;


                cChildInfo('Description')=this.updateHTMLByUsingWebviewSrc(cChild,'description');
                cChildInfo('Rationale')=this.updateHTMLByUsingWebviewSrc(cChild,'rationale');
                if isempty(cChild.keywords)
                    cChildInfo('Keywords')={};
                else
                    cChildInfo('Keywords')=cChild.keywords;
                end

                cChildInfo('IsExternal')=cChild.external;
                cChildInfo('IsJustification')=cChild.isJustification;
                cChildInfo('SID')=cChild.sid;
                cChildInfo('Revision')=cChild.revision;
                cChildInfo('CreatedBy')=cChild.createdBy;
                cChildInfo('CreatedOn')=slreq.utils.getDateStr(cChild.createdOn);
                cChildInfo('ModifiedBy')=cChild.modifiedBy;
                cChildInfo('ModifiedOn')=slreq.utils.getDateStr(cChild.modifiedOn);
                cChildInfo('RefreshedOn')=slreq.utils.getDateStr(cChild.synchronizedOn);
                cChildInfo('Index')=cChild.index;
                cChildInfo('HIndex')=[parentIndex,'/',num2str(index-1)];
                cChildInfo('ReqID')=cChild.id;
                if isempty(cChild.customId)
                    cChildInfo('CustomID')=cChild.id;
                else
                    cChildInfo('CustomID')=cChild.customId;
                end
                cChildInfo('__##type##__')='slreq';


                this.updateCommentsInfo(cChild);




                dataReqSet=cChild.getReqSet();
                attNames=dataReqSet.CustomAttributeNames;
                cChildInfo('__##CustomAttNameList##__')=attNames;
                for aindex=1:length(attNames)
                    attValue=cChild.getAttribute(attNames{aindex},true);
                    if isdatetime(attValue)
                        attValue=slreq.utils.getDateStr(attValue);
                    end

                    cChildInfo(attNames{aindex})=attValue;

                end

                cChildInfo('Children')=this.traverseReqs(cChild,cChildInfo('FullID'),cChildInfo('HIndex'));

                this.updateLinksAsDst(cChild);
                out{index}=cChildInfo;%#ok<AGROW>
            end
            if isempty(out)
                out=[];
            end
        end


        function updateLinksAsSrc(this,dataLinkSet)
            allLinkedItems=dataLinkSet.getLinkedItems;
            mfLinkTypes=slreq.utils.getAllLinkTypes();

            for cSourceItem=allLinkedItems
                fullId=cSourceItem.getSID;
                cSourceInfo=containers.Map;
                for nLinkType=1:length(mfLinkTypes)

                    thisMFLinkType=mfLinkTypes(nLinkType);
                    thisLinkTypeName=thisMFLinkType.typeName;


                    allLinks=cSourceItem.getLinks(thisLinkTypeName);
                    allLinkIds=cell(size(allLinks));

                    for index=1:length(allLinks)
                        cLink=allLinks(index);
                        linkId=cLink.getFullID;
                        allLinkIds{index}=linkId;
                    end

                    if isempty(allLinkIds)
                        cSourceInfo(thisLinkTypeName)='';
                    else
                        cSourceInfo(thisLinkTypeName)=allLinkIds;
                    end
                end

                this.SourceDataInfo(fullId)=cSourceInfo;
            end
        end



        function updateLinksAsDst(this,dataReq)
            mfLinkTypes=slreq.utils.getAllLinkTypes();
            allModelFiles=get_param(this.AllModels,'FileName');
            cLinkInfo=containers.Map;

            for nLinkType=1:length(mfLinkTypes)

                thisMFLinkType=mfLinkTypes(nLinkType);
                thisLinkTypeName=thisMFLinkType.typeName;



                allLinks=dataReq.getLinks(thisLinkTypeName);
                allLinkIds={};

                for index=1:length(allLinks)
                    cLink=allLinks(index);
                    linkId=cLink.getFullID;
                    sourceInfo=cLink.source;
                    if ismember(sourceInfo.artifactUri,allModelFiles)
                        allLinkIds{end+1}=linkId;%#ok<AGROW>
                    end
                end

                if isempty(allLinkIds)
                    cLinkInfo(thisLinkTypeName)='';
                else
                    cLinkInfo(thisLinkTypeName)=allLinkIds;
                end
            end
            this.ReqAsDstDataInfo(dataReq.getFullID)=cLinkInfo;
        end


        function updateLinkTypeInfo(this)



            mfLinkTypes=slreq.utils.getAllLinkTypes();
            for index=1:length(mfLinkTypes)
                thisMFLinkType=mfLinkTypes(index);
                thisType.IsBuiltin=thisMFLinkType.isBuiltin;
                thisType.ForwardName=slreq.app.LinkTypeManager.getForwardName(thisMFLinkType.typeName);
                thisType.BackwardName=slreq.app.LinkTypeManager.getBackwardName(thisMFLinkType.typeName);
                thisType.SuperType=thisMFLinkType.superType.typeName;
                this.LinkTypeInfo(thisMFLinkType.typeName)=thisType;
            end
        end



        function updateReqTypeInfo(this)


            reqData=slreq.data.ReqData.getInstance();
            mfReqTypes=reqData.getAllRequirementTypes();

            for index=1:length(mfReqTypes)
                thisMFReqType=mfReqTypes(index);
                thisType.IsBuiltin=thisMFReqType.isBuiltin;
                thisType.TypeName=thisMFReqType.name;
                thisType.DisplayName=slreq.app.RequirementTypeManager.getDisplayName(thisMFReqType.name);
                thisType.superType=thisMFReqType.superType.name;
                this.ReqTypeInfo(thisMFReqType.name)=thisType;
            end

        end


        function updateCustomAttributesForReqSet(this,dataReqSet,attNames)

            reqData=slreq.data.ReqData.getInstance;
            attrRegistries=reqData.getCustomAttributeRegistries(dataReqSet);
            currentAttrInfo=containers.Map;
            for index=1:length(attNames)
                attrReg=attrRegistries.getByKey(attNames{index});
                info=containers.Map;
                info("Type")=attrReg.typeName.char;
                info("Name")=attrReg.name;
                info("Description")=attrReg.description;
                info("PropertiesOf")=getString(message("Slvnv:slreq:PropertiesOf",info("Name")));
                switch attrReg.typeName.char
                case 'Checkbox'
                    info("DefaultValue")=attrReg.default;
                case 'Combobox'
                    info("AttributeEntries")=strjoin(attrReg.entries.toArray,',');
                end
                currentAttrInfo(attNames{index})=info;
            end
            this.ReqCustomAttrRegData(dataReqSet.name)=currentAttrInfo;
        end


        function updateCustomAttributesForLinkSet(this,dataLinkSet,attNames)

            reqData=slreq.data.ReqData.getInstance;
            attrRegistries=reqData.getCustomAttributeRegistries(dataLinkSet);
            currentAttrInfo=containers.Map;
            for index=1:length(attNames)
                attrReg=attrRegistries.getByKey(attNames{index});
                info=containers.Map;
                info("Type")=attrReg.typeName.char;
                info("Name")=attrReg.name;
                info("Description")=attrReg.description;
                info("PropertiesOf")=getString(message("Slvnv:slreq:PropertiesOf",info("Name")));
                switch attrReg.typeName.char
                case 'Checkbox'
                    info("DefaultValue")=attrReg.default;
                case 'Combobox'
                    info("AttributeEntries")=strjoin(attrReg.entries.toArray,',');
                end
                currentAttrInfo(attNames{index})=info;
            end
            this.LinkCustomAttrRegData(dataLinkSet.name)=currentAttrInfo;
        end


        function updateMessageMapping(this)

            refreshNameString(this.REQSET_PROPERTY_LIST,this.ReqSetPropertyNameString);
            refreshNameString(this.REQ_PROPERTY_LIST,this.ReqPropertyNameString);
            refreshNameString(this.LINKSET_PROPERTY_LIST,this.LinkSetPropertyNameString);
            refreshNameString(this.LINK_PROPERTY_LIST,this.LinkPropertyNameString);
            refreshNameString(this.CUSTOM_ATTRIBUTE_PROPERTY_LIST,this.CustomAttributesPropertyNameString);
            refreshNameString(this.REQ_LAYOUT_COLUMN_LIST,this.ReqLayoutColumnNameString);
            refreshNameString(this.LINK_LAYOUT_COLUMN_LIST,this.LinkLayoutColumnNameString);
            refreshNameString(this.GENERAL_INFO_MESSAGE,this.GeneralNameString);
        end


        function out=updateHTMLByUsingWebviewSrc(this,dataReq,descriptionOrRationale)



            dataReqSet=dataReq.getReqSet;
            inStr=dataReqSet.unpackImages(dataReq.(descriptionOrRationale));
            htmlObj=slreq.utils.HTMLProcessor(inStr);
            if strcmpi(dataReq.([descriptionOrRationale,'EditorType']),'word')
                resourceBaseFolder=slreq.opc.getReqSetTempDir(dataReqSet.name);
                resourceFolder=[resourceBaseFolder,'/',num2str(dataReq.sid),'_',upper(descriptionOrRationale(1))];
            else
                resourceFolder=slreq.opc.getUsrTempDir;
            end
            htmlObj.setBaseDir(resourceFolder);
            htmlObj.refreshAllRequiredFiles();
            srcDir=['file:///',slreq.opc.getUsrTempDir];
            out=htmlObj.updateReferenceFileSrc(srcDir,this.WebViewSupportFileFolder);
        end


        function createMapFromDestinationDocToCopiedDoc(this,destinationDocs)
            this.DestinationDocs=containers.Map;
            copiedDoc=cell(size(destinationDocs));
            for index=1:length(destinationDocs)
                [~,filename,fileext]=fileparts(destinationDocs{index});
                copiedDoc{index}=[this.WebViewSupportFileFolder,'/',filename,fileext];
            end

            if~isempty(destinationDocs)
                this.DestinationDocs=containers.Map(destinationDocs,copiedDoc);
            end
        end


        function createMapFromReferencedFileToCopiedFile(this,referencedFiles)
            this.ReferencedDocs=containers.Map;
            copiedDoc=cell(size(referencedFiles));
            tempfolder=fullfile(tempdir,'RMI');

            cachefolder=this.CACHE_FOLDER;
            for index=1:length(referencedFiles)
                cFile=referencedFiles{index};
                if startsWith(cFile,'file:///')

                    if ispc
                        cFile=cFile(9:end);
                    else
                        cFile=cFile(8:end);
                    end
                end
                filePathInThisPlatform=fullfile(cFile);
                relativeToTempFolder=strrep(filePathInThisPlatform,tempfolder,'');
                if strcmp(relativeToTempFolder,filePathInThisPlatform)



                    [~,filename,fileext]=fileparts(cFile);
                    relativePath=[filename,fileext];
                else
                    relativePath=strrep(relativeToTempFolder,filesep,'/');
                end


                copiedDoc{index}=[this.WebViewSupportFileFolder,relativePath];
                if exist(cFile,'file')==2||exist(cFile,'file')==4

                    destFullFile=fullfile(cachefolder,relativePath);

                    destDir=fileparts(destFullFile);
                    if exist(destDir,'dir')~=7
                        mkdir(destDir);
                    end
                    copyfile(cFile,destFullFile,'f');
                end
                this.ReferencedDocs(cFile)=copiedDoc{index};
            end
        end
    end


    methods(Static)
        function exportModelLinkData(modelName,opts)





            exporter=slreq.report.webview.WebViewReqDataExporter(modelName,opts);
            exporter.export();
        end

        function refreshReqSetReferencedData(modelName,opts)


            exporter=slreq.report.webview.WebViewReqDataExporter(modelName,opts);
            exporter.convertReqSetReferencedDocs();
        end
    end
end

function refreshNameString(propertyList,mapContainer)
    if mapContainer.Count==0
        prefix='Slvnv:slreq:';
        for index=1:length(propertyList)
            propertyName=propertyList{index};
            propertyKey=[prefix,propertyName];
            propertyValue=getString(message(propertyKey));
            mapContainer(propertyName)=propertyValue;
        end
    end
end


function[reqColumns,linkColumns,dispChangeInfo]=queryViewSetting(modelHandle)
    hasViewSetting=false;
    dispChangeInfo=true;
    if slreq.app.MainManager.exists
        mgr=slreq.app.MainManager.getInstance;
        spreadDataManager=mgr.spreadSheetDataManager;
        if~isempty(spreadDataManager)&&spreadDataManager.SpreadSheetDataMap.isKey(modelHandle)
            spData=spreadDataManager.SpreadSheetDataMap(modelHandle);

            reqColumns=setdiff(spData.reqColumns,{'Implemented','Verified'},'stable');
            linkColumns=spData.linkColumns;
            dispChangeInfo=spData.displayChangeInformation;
            hasViewSetting=true;
        end

        spreadSheetManager=mgr.spreadsheetManager;
        if~isempty(spreadSheetManager)&&spreadSheetManager.spreadSheetMap.isKey(modelHandle)
            spObj=spreadSheetManager.spreadSheetMap(modelHandle);
            dispChangeInfo=spObj.displayChangeInformation;
        end
    end

    if~hasViewSetting
        reqColumns=slreq.app.MainManager.DefaultRequirementColumns;
        linkColumns=slreq.app.MainManager.DefaultLinkColumns;
    end
    [isIdIn,idPos]=ismember('ID',reqColumns);
    if isIdIn
        reqColumns{idPos}='ReqID';
    end


end


function libModels=getNonBuiltInLibs(modelHandle)
    allLibs=libinfo(modelHandle);
    libModels={};
    for index=1:length(allLibs)
        libName=allLibs(index).Library;
        if~rmiut.isBuiltinNoRmi(libName)
            libModels{end+1}=libName;%#ok<AGROW>
        end
    end
end

function linkTargetClass=getLinkTargetClass(linkSrcDst)
    if strcmpi(linkSrcDst.domain,'linktype_rmi_simulink')
        if isa(linkSrcDst,'slreq.data.SourceItem')
            if isa(linkSrcDst,'slreq.data.TextRange')

                linkTargetClass='simulink-eml';
            else
                linkTargetClass=slreq.utils.getSLType(linkSrcDst.artifactUri,linkSrcDst.id);
            end
        else
            linkTargetClass=slreq.utils.getSLType(linkSrcDst.artifactUri,linkSrcDst.artifactId);
        end

    elseif strcmpi(linkSrcDst.domain,'linktype_rmi_slreq')
        if isa(linkSrcDst,'slreq.data.SourceItem')
            linkedObj=slreq.utils.getReqObjFromSourceItem(linkSrcDst);
        else
            linkedObj=linkSrcDst;
        end
        if isempty(linkedObj)
            linkTargetClass='unresolved-item';
        elseif linkedObj.external
            linkTargetClass='slreq-ex';
        elseif linkedObj.isJustification
            linkTargetClass='slreq-justification';
        else
            linkTargetClass='slreq-in';
        end
    elseif slreq.data.Requirement.isExternallySourcedReqIF(linkSrcDst.domain)

        linkTargetClass='slreq-ex';
    else
        linkTargetClass=strrep(linkSrcDst.domain,'_','-');
    end
end

function artifactList=getArtifactListForDirectLinks(dataLinkSet)
    artifactListMap=containers.Map('KeyType','char','ValueType','logical');
    allDirectLinks=dataLinkSet.getDirectLinks;
    for lindex=1:length(allDirectLinks)
        cLink=allDirectLinks(lindex);
        destPath=slreq.uri.ResourcePathHandler.getFullPath(cLink.destUri,dataLinkSet.filepath);
        artifactListMap(destPath)=true;
    end
    artifactList=artifactListMap.keys;
end



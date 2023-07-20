


classdef ReportContent<handle

    properties(Access=private)
        MetaData;
        FuncData;
        StatusData;
        TraceData;
        UtilsData;
        ErrorData;

        metadataSection;
        interfaceSection;
        modelVerSection;
        codeVerSection;
        tempVarSection;
        typeReplacementSection;

        modelTraceSection;
        codeTraceSection;
        notProcessedCodeSection;
        errorSection;

        utilsVerSection;

        utilsNotProcessedSection;

        matlabNonInlinedFuncSection;

        subsystemFuncNameSection;

        subsystemFileNameSection;

        Config=slci.internal.ReportConfig;
        ReportUtil=slci.internal.ReportUtil;

    end

    properties(Access=public,Dependent=true)
        detailSection;
        summarySection;
        Section;
    end

    properties(Access=public)
        showTraceability=true;
        showVerification=true;
        showUtils=true;
    end

    properties(SetAccess=private)
        Status;
        VerificationStatus;
        TraceStatus;
        UtilsStatus;
    end

    methods(Access=public)


        function obj=ReportContent(ReportData)
            if isfield(ReportData,'metaData')
                obj.MetaData=ReportData.metaData;
            end

            if isfield(ReportData,'funcDescTable')
                obj.FuncData=ReportData.funcDescTable;
            end

            if isfield(ReportData,'statusData')
                obj.StatusData=ReportData.statusData;
            end

            if isfield(ReportData,'trace')
                obj.TraceData=ReportData.trace;
            end

            if isfield(ReportData,'utils')
                obj.UtilsData=ReportData.utils;
            end

            if isfield(ReportData,'errors')
                obj.ErrorData=ReportData.errors;
            end

            if isfield(ReportData,'Status')...
                &&~isempty(ReportData.Status)
                obj.Status=ReportData.Status;
            else
                obj.Status=obj.Config.defaultStatus;
            end

            if isfield(ReportData,'verificationStatus')...
                &&~isempty(ReportData.verificationStatus)
                obj.VerificationStatus=ReportData.verificationStatus;
            else
                obj.VerificationStatus=obj.Config.defaultStatus;
            end

            if isfield(ReportData,'traceabilityStatus')...
                &&~isempty(ReportData.traceabilityStatus)
                obj.TraceStatus=ReportData.traceabilityStatus;
            else
                obj.TraceStatus=obj.Config.defaultStatus;
            end

            if isfield(ReportData,'utilsStatus')...
                &&~isempty(ReportData.utilsStatus)
                obj.UtilsStatus=ReportData.utilsStatus;
            else
                obj.UtilsStatus=obj.Config.defaultStatus;
            end

            obj.metadataSection=obj.Config.defaultSection;
            obj.interfaceSection=slci.DetailSection;
            obj.modelVerSection=slci.DetailSection;
            obj.codeVerSection=slci.DetailSection;
            obj.modelTraceSection=slci.DetailSection;
            obj.codeTraceSection=slci.DetailSection;
            obj.tempVarSection=slci.DetailSection;
            obj.typeReplacementSection=slci.DetailSection;
            obj.notProcessedCodeSection=slci.DetailSection;
            obj.errorSection=obj.Config.defaultSection;
            obj.utilsVerSection=slci.DetailSection;
            obj.utilsNotProcessedSection=slci.DetailSection;
            obj.matlabNonInlinedFuncSection=slci.DetailSection;
            obj.subsystemFuncNameSection=slci.DetailSection;
            obj.subsystemFileNameSection=slci.DetailSection;
        end



        function obj=makeReportContent(obj,slciConfig,modelName)
            obj.genSections(slciConfig,modelName);
        end

    end


    methods
        function set.Status(obj,status)
            if~isempty(status)
                obj.Status=status;
            end
        end

        function set.VerificationStatus(obj,status)
            if~isempty(status)
                obj.VerificationStatus=status;
            end
        end

        function set.TraceStatus(obj,status)
            if~isempty(status)
                obj.TraceStatus=status;
            end
        end


        function set.UtilsStatus(obj,status)
            if~isempty(status)
                obj.UtilsStatus=status;
            end
        end

        function set.MetaData(obj,MetaData)
            obj.MetaData=[];
            if~isempty(MetaData)
                obj.MetaData=MetaData;
            end
        end

        function set.FuncData(obj,FuncData)
            obj.FuncData=[];
            if~isempty(FuncData)
                obj.FuncData=FuncData;
            end
        end

        function set.TraceData(obj,traceData)
            obj.TraceData=[];
            if~isempty(traceData)
                obj.TraceData=traceData;
            end
        end

        function set.StatusData(obj,statusData)
            obj.StatusData=[];
            if~isempty(statusData)
                obj.StatusData=statusData;
            end
        end


        function set.UtilsData(obj,utilsData)
            obj.UtilsData=[];
            if~isempty(utilsData)
                obj.UtilsData=utilsData;
            end
        end

        function set.ErrorData(obj,errorData)
            obj.ErrorData=[];
            if~isempty(errorData)
                obj.ErrorData=errorData;
            end
        end

        function set.showTraceability(obj,showTrace)
            if islogical(showTrace)
                obj.showTraceability=showTrace;
            else
                error(message('Slci:slci:ArgMustBeLogical','ShowTraceability'));
            end
        end

        function set.showVerification(obj,showVerification)
            if islogical(showVerification)
                obj.showVerification=showVerification;
            else
                error(message('Slci:slci:ArgMustBeLogical','ShowVerification'));
            end
        end


        function set.showUtils(obj,showUtils)
            if islogical(showUtils)
                obj.showUtils=showUtils;
            else
                error(message('Slci:slci:ArgMustBeLogical','ShowUtils'));
            end
        end

    end

    methods(Access=private)


        function out=getJsonFileName(~,slciConfig,modelName)
            out=fullfile(slciConfig.getReportFolder(),[char(modelName),'_justification.json']);
        end


        function out=setJustificationCommentsWithStyle(~,justification)
            brTag='<br/>';
            strComments='<h4 style="color:blue;margin-bottom: 0px;margin-top: 0px;">Comment : </h4>';

            uiJsonCommentThread=justification.getCommentThread();
            uiJsonCommentThreadTable=[];
            for i=1:uiJsonCommentThread.Size


                strDate=strcat('<p style= "background-color: #f1efeff5;">'...
                ,justification.getUser(),'&nbsp &nbsp',string(datetime(uiJsonCommentThread(i).timeStamp,'InputFormat',...
                'dd-MMM-yyyy HH:mm','Locale','en_US','Format','dd-MMM-yyyy HH:mm')));



                tempRow=strcat(strDate,brTag,uiJsonCommentThread(i).description,brTag,'</p>');
                uiJsonCommentThreadTable=[uiJsonCommentThreadTable,char(tempRow)];
            end
            out=append(strComments,uiJsonCommentThreadTable);
        end



        function out=modelToCodeHelper(~,tableData,index)
            temp1=string(split(tableData(index).SOURCEOBJ.CONTENT,"','"));
            temp2=split(temp1(2),"')");
            out=string(temp2(1));
        end


        function modelToCodeVerification(obj,modelManager)
            for j=1:numel(obj.StatusData.model.DETAIL.SECTIONLIST)
                tableData=obj.StatusData.model.DETAIL.SECTIONLIST(j).TABLEDATA;
                for k=1:numel(tableData)

                    sid=modelToCodeHelper(obj,tableData,k);


                    if isequal(tableData(k).STATUS.CONTENT,'Justified')&&modelManager.isFiltered(sid)
                        justification=slci.view.JustificationManager(...
                        modelManager.fMFModel,modelManager.getJustification(sid));
                        tableData(k).JUSTIFICATION.CONTENT=setJustificationCommentsWithStyle(obj,justification);
                    end
                end
                obj.StatusData.model.DETAIL.SECTIONLIST(j).TABLEDATA=tableData;
            end
        end


        function modelToCodeTracebiltiy(obj,modelManager)
            for j=1:numel(obj.TraceData.model.DETAIL.SECTIONLIST)
                tableData=obj.TraceData.model.DETAIL.SECTIONLIST(j).TABLEDATA;
                for k=1:numel(tableData)

                    sid=modelToCodeHelper(obj,tableData,k);


                    if modelManager.isFiltered(sid)
                        justification=slci.view.JustificationManager(...
                        modelManager.fMFModel,modelManager.getJustification(sid));
                        tableData(k).JUSTIFICATION.CONTENT=setJustificationCommentsWithStyle(obj,justification);
                        tableData(k).REASON.CONTENT='Justified';
                        tableData(k).REASON.ATTRIBUTES='JUSTIFIED';
                        splitCodeLines=split(justification.getCodeLines,"-");
                        tableData(k).SOURCELIST.SOURCEOBJ.CONTENT=char(splitCodeLines(2));
                    end
                end
                obj.TraceData.model.DETAIL.SECTIONLIST(j).TABLEDATA=tableData;
            end
        end


        function codeToModelVerification(obj,modelManager)
            for j=1:numel(obj.StatusData.code.DETAIL.SECTIONLIST)
                tableData=obj.StatusData.code.DETAIL.SECTIONLIST(j).TABLEDATA;
                for k=1:numel(tableData)
                    newtable=tableData(k).OBJECTLIST;
                    for l=1:numel(newtable)
                        codeline=newtable(l).SOURCEOBJ.CONTENT;


                        if modelManager.isFiltered(codeline)
                            justification=slci.view.JustificationManager(...
                            modelManager.fMFModel,modelManager.getJustification(codeline));
                            newtable(l).JUSTIFICATION.CONTENT=setJustificationCommentsWithStyle(obj,justification);
                            newtable(l).MESSAGE.CONTENT='';
                            newtable(l).STATUS.CONTENT='';
                            newtable(l).REASON.CONTENT='Justified';
                            newtable(l).REASON.ATTRIBUTES='JUSTIFIED';
                        end
                    end
                    tableData(k).OBJECTLIST=newtable;
                end
                obj.StatusData.code.DETAIL.SECTIONLIST(j).TABLEDATA=tableData;
            end
        end


        function codeToModelTracebility(obj,modelManager)
            for j=1:numel(obj.TraceData.code.DETAIL.SECTIONLIST)
                cf1=split(obj.TraceData.code.DETAIL.SECTIONLIST(j).SECTION.CONTENT,'>');
                cf2=split(cf1(2),'<');
                codeFile=string(cf2(1));
                tableData=obj.TraceData.code.DETAIL.SECTIONLIST(j).TABLEDATA;
                for k=1:numel(tableData)
                    codeline=strcat(codeFile,':',string(tableData(k).SOURCEOBJ.CONTENT));


                    if modelManager.isFiltered(codeline)
                        justification=slci.view.JustificationManager(...
                        modelManager.fMFModel,modelManager.getJustification(codeline));
                        tableData(k).JUSTIFICATION.CONTENT=setJustificationCommentsWithStyle(obj,justification);
                        tableData(k).REASON.CONTENT='Justified';
                        tableData(k).REASON.ATTRIBUTES='JUSTIFIED';
                    end
                end
                obj.TraceData.code.DETAIL.SECTIONLIST(j).TABLEDATA=tableData;
            end
        end





        function preProcessJustification(obj,slciConfig,modelName)

            fname=getJsonFileName(obj,slciConfig,modelName);

            if~isfile(fname)
                return;
            end


            modelManager=slci.view.ModelManager(fname);

            if isequal(modelManager.fManager.filters.Size,0)
                return;
            end


            try

                modelToCodeVerification(obj,modelManager);


                modelToCodeTracebiltiy(obj,modelManager);



                codeToModelVerification(obj,modelManager)


                codeToModelTracebility(obj,modelManager);


            catch exception
                disp(exception);
            end
        end



        function genSections(obj,slciConfig,modelName)

            if slcifeature('SLCIJustification')==1
                PreprocessJustification=slci.internal.Profiler('SLCI',...
                'preProcessJustification',...
                '','');
                obj.preProcessJustification(slciConfig,modelName);
                PreprocessJustification.stop();
            end


            if obj.showUtils
                obj.genUtilsSections();
            end

            obj.genMetaDataSection();

            if obj.showVerification
                obj.genVerificationSections();
            end

            if obj.showTraceability
                obj.genTraceabilitySections();
            end

        end

        function genVerificationSections(obj)
            obj.genInterface();
            obj.genModelVerification();
            obj.genCodeVerification();
            obj.genTempVarSection();
            obj.genTypeReplacementSection();
        end

        function genTraceabilitySections(obj)
            obj.genModelTraceability();
            obj.genCodeTraceability();
        end


        function genUtilsSections(obj)

            obj.genUtilsVerficationSection();

            obj.genUtilsNotProcessedSection();

            obj.genMatlabNonInlinedFuncSection();
        end

        function genErrorSection(obj)
            if~isempty(obj.ErrorData)
                errorMessage=cell(numel(obj.ErrorData),1);
                for k=1:numel(obj.ErrorData)



                    errorMsg=slci.internal.encodeString(...
                    obj.ErrorData(k).errorMessage,...
                    'printf','encode');

                    errorMsg=obj.ReportUtil.formatMessage(errorMsg);

                    errorMsg=obj.ReportUtil.appendColorAndTip(...
                    errorMsg,obj.Status);

                    errorMessage{k,1}=errorMsg;
                end
                obj.errorSection=obj.ReportUtil.genTable({},errorMessage,0);
            end
        end

        function genMetaDataSection(obj)
            metaData=obj.MetaData;
            if~isempty(metaData)
                for k=1:size(metaData,1)
                    metaData{k,1}=obj.ReportUtil.makeBold(metaData{k,1});
                    metaData{k,2}=metaData{k,2};
                end

                metaData{k+1,1}='&nbsp;';
                metaData{k+1,2}='';
                statusIdx=k+2;
            else
                statusIdx=1;
            end


            metaData{statusIdx,1}=obj.ReportUtil.makeBold('Overall Inspection Result : ');
            metaData{statusIdx,2}=obj.ReportUtil.makeBold(...
            obj.ReportUtil.appendColorAndTip(...
            obj.Config.getStatusMessage(obj.Status),obj.Status));


            if~isempty(obj.UtilsData)
                statusIdx=statusIdx+1;
                metaData{statusIdx,1}=obj.ReportUtil.makeBold(...
                message('Slci:slci:ManualReviewUtilsResult').getString);
                if~isempty(obj.utilsNotProcessedSection.SectionSummary)
                    metaData{statusIdx,2}='Yes';
                else
                    metaData{statusIdx,2}='No';
                end
            end


            if~isempty(metaData)
                obj.metadataSection=obj.ReportUtil.genTable({},metaData,0);
            end

            obj.genErrorSection;
            if~isempty(obj.errorSection)
                obj.metadataSection=[...
                obj.ReportUtil.addLineBreak(obj.metadataSection)...
                ,obj.errorSection];
            end

            if~isempty(obj.metadataSection)
                obj.metadataSection=obj.ReportUtil.addHorizontalBar(...
                obj.metadataSection);
            end
        end

        function genInterface(obj)
            if~isempty(obj.StatusData)&&~isempty(obj.StatusData.interface)
                try
                    obj.interfaceSection=slci.DetailSection(...
                    obj.StatusData.interface.DETAIL,...
                    obj.StatusData.interface.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            end

            obj.interfaceSection.SummaryCaption=...
            'Function Interface Verification Results : ';
            obj.interfaceSection.DetailCaption=...
            'Function Interface Verification ';

            obj.interfaceSection.DetailTableHeader={'Check','Status'};
            obj.interfaceSection.SummaryTableHeader=...
            {'Function','Status','Details'};
            obj.interfaceSection.makeDetailSection();
            obj.interfaceSection.makeSummarySection(false);

        end


        function genModelVerification(obj)
            if~isempty(obj.StatusData)&&~isempty(obj.StatusData.model)
                try
                    obj.modelVerSection=slci.DetailSection(...
                    obj.StatusData.model.DETAIL,...
                    obj.StatusData.model.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            end

            obj.modelVerSection.SummaryCaption=...
            'Model To Code Verification Results : ';
            obj.modelVerSection.DetailCaption=...
            'Model To Code Verification ';
            if slcifeature('SLCIJustification')==1
                obj.modelVerSection.DetailTableHeader=...
                {'Model object','Status','Details','Justification'};
            else
                obj.modelVerSection.DetailTableHeader=...
                {'Model object','Status','Details'};
            end
            obj.modelVerSection.SummaryTableHeader=...
            {'Status','Details'};
            obj.modelVerSection.makeDetailSection();
            obj.modelVerSection.makeSummarySection(false);

        end

        function genCodeVerification(obj)
            if~isempty(obj.StatusData)&&~isempty(obj.StatusData.code)
                try
                    codeVer=slci.DetailSection(...
                    obj.StatusData.code.DETAIL,...
                    obj.StatusData.code.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end

            codeVer.SummaryCaption='Code To Model Verification Results : ';
            codeVer.DetailCaption='Code To Model Verification ';
            codeVer.DetailTableHeader=...
            {'Function outputs/state variables',...
            'Contributing lines of code'};
            codeVer.SummaryTableHeader={'Function','Status','Details'};
            codeVer.makeDetailSection();
            codeVer.makeSummarySection(false);

            obj.codeVerSection=codeVer;
        end

        function genModelTraceability(obj)

            if~isempty(obj.TraceData)&&~isempty(obj.TraceData.model)
                try
                    mtrace=slci.DetailSection(...
                    obj.TraceData.model.DETAIL,...
                    obj.TraceData.model.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end
            mtrace.SummaryCaption='Model To Code Traceability Results : ';
            mtrace.DetailCaption='Model To Code Traceability ';
            if slcifeature('SLCIJustification')==1
                mtrace.DetailTableHeader=...
                {'Model object','Code location','Details','Justification'};
            else
                mtrace.DetailTableHeader=...
                {'Model object','Code location','Details'};
            end
            mtrace.SummaryTableHeader=...
            {'Status','Number of model objects'};
            mtrace.makeDetailSection();
            mtrace.makeSummarySection(false);

            obj.modelTraceSection=mtrace;
        end

        function genCodeTraceability(obj)

            if~isempty(obj.TraceData)&&~isempty(obj.TraceData.code)
                try
                    ctrace=slci.DetailSection(...
                    obj.TraceData.code.DETAIL,...
                    obj.TraceData.code.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end
            if slcifeature('SLCIJustification')==1
                ctrace.DetailTableHeader=...
                {'Code location','Code','Model object','Details','Justification'};
            else
                ctrace.DetailTableHeader=...
                {'Code location','Code','Model object','Details'};
            end
            ctrace.SummaryTableHeader=...
            {'Status','Number of code lines'};
            ctrace.SummaryCaption='Code To Model Traceability Results : ';
            ctrace.DetailCaption='Code To Model Traceability ';
            ctrace.makeDetailSection();
            ctrace.makeSummarySection(false);
            obj.codeTraceSection=ctrace;


            obj.genNotProcessedCodeSection();


            obj.genSubFuncNameSection();


            obj.genSubFileNameSection();
        end

        function genNotProcessedCodeSection(obj)

            if~isempty(obj.TraceData)&&...
                ~isempty(obj.TraceData.notProcessed)
                try
                    ctrace=slci.DetailSection(...
                    [],...
                    obj.TraceData.notProcessed.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end

            ctrace.SummaryTableHeader={};
            ctrace.SummaryCaption='Not processed code: ';
            ctrace.makeSummarySection(false);
            obj.notProcessedCodeSection=ctrace;
        end


        function genUtilsVerficationSection(obj)
            if~isempty(obj.UtilsData)...
                &&~isempty(obj.UtilsData.verStatus)
                try
                    funcCall=slci.DetailSection(...
                    [],...
                    obj.UtilsData.verStatus.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            if~isempty(funcCall.SummaryData.TABLEDATA)
                funcCall.SummaryTableHeader={...
                message('Slci:slci:FuncCallSumTableHeader1').getString...
                ,message('Slci:slci:FuncCallSumTableHeader2').getString...
                ,message('Slci:slci:FuncCallSumTableHeader3').getString...
                ,message('Slci:slci:FuncCallSumTableHeader4').getString...
                ,message('Slci:slci:FuncCallSumTableHeader5').getString};
                funcCall.SummaryCaption=...
                message('Slci:slci:UtilsStatusCaption').getString;
                funcCall.makeSummarySection(false);
                obj.utilsVerSection=funcCall;
            end
        end


        function genUtilsNotProcessedSection(obj)
            if~isempty(obj.UtilsData)...
                &&~isempty(obj.UtilsData.notProcessed)
                try
                    funcCall=slci.DetailSection(...
                    [],...
                    obj.UtilsData.notProcessed.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            if~isempty(funcCall.SummaryData.TABLEDATA)
                funcCall.SummaryTableHeader={...
                message('Slci:slci:FuncCallSumTableHeader1').getString...
                ,message('Slci:slci:FuncCallSumTableHeader2').getString...
                ,message('Slci:slci:FuncCallSumTableHeader3').getString...
                ,message('Slci:slci:FuncCallSumTableHeader4').getString};
                funcCall.SummaryCaption=...
                message('Slci:slci:UtilsNotProcessedCaption').getString;
                funcCall.makeSummarySection(false);
                obj.utilsNotProcessedSection=funcCall;
            end
        end



        function genMatlabNonInlinedFuncSection(obj)
            if~isempty(obj.UtilsData)...
                &&~isempty(obj.UtilsData.matlabFunc)
                try
                    nonInlinedFunc=slci.DetailSection(...
                    [],...
                    obj.UtilsData.matlabFunc.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            if~isempty(nonInlinedFunc.SummaryData.TABLEDATA)
                nonInlinedFunc.SummaryCaption=...
                message('Slci:slci:UtilsStatusCaption').getString;
                nonInlinedFunc.SummaryTableHeader={...
                message('Slci:slci:MatlabNonInlinedFuncTableHeader1').getString...
                ,message('Slci:slci:MatlabNonInlinedFuncTableHeader2').getString...
                ,message('Slci:slci:MatlabNonInlinedFuncTableHeader3').getString...
                ,message('Slci:slci:MatlabNonInlinedFuncTableHeader4').getString...
                };
                nonInlinedFunc.SummaryCaption=...
                message('Slci:slci:MatlabNonInlinedFuncTableCaption').getString;
                nonInlinedFunc.makeSummarySection(false);
                obj.matlabNonInlinedFuncSection=nonInlinedFunc;
            end
        end


        function genSubFuncNameSection(obj)
            if~isempty(obj.TraceData)...
                &&~isempty(obj.TraceData.subFuncName)
                try
                    subFuncName=slci.DetailSection(...
                    [],...
                    obj.TraceData.subFuncName.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            if~isempty(subFuncName.SummaryData.TABLEDATA)
                subFuncName.SummaryTableHeader={...
                message('Slci:slci:SubSystemFuncNameTableHeader1').getString...
                ,message('Slci:slci:SubSystemFuncNameTableHeader2').getString...
                ,message('Slci:slci:SubSystemFuncNameTableHeader3').getString};
                subFuncName.SummaryCaption=...
                message('Slci:slci:SubSystemFuncNameSumCaption').getString;
                subFuncName.makeSummarySection(true);
                obj.subsystemFuncNameSection=subFuncName;
            end
        end


        function genSubFileNameSection(obj)
            if~isempty(obj.TraceData)...
                &&~isempty(obj.TraceData.subFuncFileName)
                try
                    subFuncFileName=slci.DetailSection(...
                    [],...
                    obj.TraceData.subFuncFileName.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            if~isempty(subFuncFileName.SummaryData.TABLEDATA)
                subFuncFileName.SummaryTableHeader={...
                message('Slci:slci:SubSystemFileNameTableHeader1').getString...
                ,message('Slci:slci:SubSystemFileNameTableHeader2').getString...
                ,message('Slci:slci:SubSystemFileNameTableHeader3').getString};
                subFuncFileName.SummaryCaption=...
                message('Slci:slci:SubSystemFileNameSumCaption').getString;
                subFuncFileName.makeSummarySection(true);
                obj.subsystemFileNameSection=subFuncFileName;
            end
        end

        function genTempVarSection(obj)
            if~isempty(obj.StatusData)...
                &&~isempty(obj.StatusData.tempVar)
                try
                    tempVar=slci.DetailSection(...
                    obj.StatusData.tempVar.DETAIL,...
                    obj.StatusData.tempVar.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);
                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end
            tempVar.SummaryCaption='Temporary Variable Usage Results : ';
            tempVar.DetailCaption='Temporary Variable Usage ';
            tempVar.DetailTableHeader={'Temporary variable name','Status'};
            tempVar.SummaryTableHeader={'Function','Status','Details'};
            tempVar.makeDetailSection();
            tempVar.makeSummarySection(false);
            obj.tempVarSection=tempVar;

        end


        function genTypeReplacementSection(obj)
            if~isempty(obj.StatusData)...
                &&~isempty(obj.StatusData.typeReplacement)
                try
                    typeRepl=slci.DetailSection(...
                    obj.StatusData.typeReplacement.DETAIL,...
                    obj.StatusData.typeReplacement.SUMMARY,...
                    obj.ReportUtil,...
                    obj.Config);

                catch exception
                    disp(exception.message)
                    return;
                end
            else
                return;
            end


            typeRepl.DetailCaption='Data Type Replacement Verification ';
            typeRepl.DetailTableHeader={'Code generation type name ',...
            'Replacement name',...
            'Status',...
            'Code location'};
            typeRepl.makeDetailSection();


            assert(isempty(obj.StatusData.typeReplacement.SUMMARY),...
            'Data type replacement does not have a summary section');

            obj.typeReplacementSection=typeRepl;
        end


        function detailSection=addCodeInspectionDetails(obj)
            detailsCaption=obj.ReportUtil.makeHeader2(...
            'Code Verification Details');
            detailsSection=[obj.interfaceSection.SectionDetail...
            ,obj.modelVerSection.SectionDetail...
            ,obj.codeVerSection.SectionDetail...
            ,obj.tempVarSection.SectionDetail...
            ,obj.typeReplacementSection.SectionDetail...
            ];

            if~isempty(detailsSection)
                detailsSection=obj.ReportUtil.genTable({},{detailsSection},0);
                detailSection=[detailsCaption,detailsSection];
            else
                detailSection=obj.Config.defaultSection;
            end
        end


        function summarySection=addCodeInspectionSummary(obj)
            summaryCaption=obj.ReportUtil.makeHeader2([...
'Code Verification Results : '...
            ,obj.ReportUtil.appendColorAndTip(...
            obj.Config.getStatusMessage(obj.VerificationStatus),obj.VerificationStatus)]);

            summarySection=[obj.interfaceSection.SectionSummary...
            ,obj.modelVerSection.SectionSummary...
            ,obj.codeVerSection.SectionSummary...
            ,obj.tempVarSection.SectionSummary];

            if isempty(summarySection)
                summarySection=obj.Config.defaultSection;
            else
                summarySection=[summaryCaption,summarySection];
            end

        end

        function detailsSection=addTraceabilityDetails(obj)
            detailsCaption=obj.ReportUtil.makeHeader2(...
            'Traceability Details');

            detailsSection=[...
            obj.modelTraceSection.SectionDetail...
            ,obj.codeTraceSection.SectionDetail];

            if isempty(detailsSection)
                detailsSection=obj.Config.defaultSection;
            else
                detailsSection=...
                obj.ReportUtil.genTable({},{detailsSection},0);
                detailsSection=[detailsCaption,detailsSection];
            end
        end

        function summarySection=addTraceabilitySummary(obj)

            summarySection=[obj.modelTraceSection.SectionSummary,...
            obj.codeTraceSection.SectionSummary,...
            obj.notProcessedCodeSection.SectionSummary,...
            obj.subsystemFuncNameSection.SectionSummary,...
            obj.subsystemFileNameSection.SectionSummary];

            if isempty(summarySection)
                summarySection=obj.Config.defaultSection;
            else
                summaryCaption=obj.ReportUtil.makeHeader2([...
'Traceability Results : '...
                ,obj.ReportUtil.appendColorAndTip(...
                obj.Config.getStatusMessage(obj.TraceStatus),obj.TraceStatus)]);

                summarySection=[summaryCaption,summarySection];
            end

        end


        function detailsSection=addUtilsDetails(obj)
            detailsCaption=obj.ReportUtil.makeHeader2(...
            'Utils Details');

            detailsSection=[...
            obj.utilsVerSection.SectionDetail,...
            obj.utilsNotProcessedSection.SectionDetail,...
            obj.matlabNonInlinedFuncSection.SectionDetail...
            ];

            if isempty(detailsSection)
                detailsSection=obj.Config.defaultSection;
            else
                detailsSection=...
                obj.ReportUtil.genTable({},{detailsSection},0);
                detailsSection=[detailsCaption,detailsSection];
            end
        end


        function summarySection=addUtilsSummary(obj)
            summarySection=[obj.utilsVerSection.SectionSummary,...
            obj.utilsNotProcessedSection.SectionSummary,...
            obj.matlabNonInlinedFuncSection.SectionSummary...
            ];
            if isempty(summarySection)
                summarySection=obj.Config.defaultSection;
            elseif isempty(obj.utilsVerSection.SectionSummary)
                summaryCaption=obj.ReportUtil.makeHeader2(...
                'Utils Verification ');

                summarySection=[summaryCaption,summarySection];
            else
                summaryCaption=obj.ReportUtil.makeHeader2([...
'Utils Verification Results : '...
                ,obj.ReportUtil.appendColorAndTip(...
                obj.Config.getStatusMessage(obj.UtilsStatus),...
                obj.UtilsStatus)]);

                summarySection=[summaryCaption,summarySection];
            end
        end

    end

    methods

        function summarySection=get.summarySection(obj)

            summarySection=[];
            if obj.showVerification
                verSummary=obj.addCodeInspectionSummary();
                if~isempty(verSummary)
                    summarySection=obj.ReportUtil.addLineBreak(verSummary);
                end
            end

            if obj.showTraceability
                traceSummary=obj.addTraceabilitySummary();
                if~isempty(traceSummary)
                    traceSummary=obj.ReportUtil.addLineBreak(traceSummary);
                end
                summarySection=[summarySection,traceSummary];
            end


            if obj.showUtils
                utilsSummary=obj.addUtilsSummary();
                if~isempty(utilsSummary)
                    utilsSummary=obj.ReportUtil.addLineBreak(utilsSummary);
                end
                summarySection=[summarySection,utilsSummary];
            end

            if~isempty(summarySection)
                summarySection=obj.ReportUtil.addHorizontalBar(summarySection);
            end

        end

        function detailSection=get.detailSection(obj)
            detailSection=[];
            if obj.showVerification
                verDetail=obj.addCodeInspectionDetails();
                if~isempty(verDetail)
                    detailSection=obj.ReportUtil.addLineBreak(verDetail);
                end
            end

            if obj.showTraceability
                traceDetail=obj.addTraceabilityDetails();
                if~isempty(traceDetail)
                    traceDetail=obj.ReportUtil.addLineBreak(traceDetail);
                end
                detailSection=[detailSection,traceDetail];
            end


            if obj.showUtils
                utilsDetail=obj.addUtilsDetails();
                if~isempty(utilsDetail)
                    utilsDetail=obj.ReportUtil.addLineBreak(utilsDetail);
                end
                detailSection=[detailSection,utilsDetail];
            end

            if~isempty(detailSection)
                detailSection=obj.ReportUtil.addHorizontalBar(detailSection);
            end
        end


        function section=get.Section(obj)

            section=[obj.metadataSection...
            ,obj.summarySection...
            ,obj.detailSection];
        end

        function status=get.Status(obj)
            status=obj.Status;
        end

    end


end
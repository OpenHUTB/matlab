

classdef(Sealed)CodeMetricsReportService<codergui.internal.WebService






    properties(Hidden,Constant)
        CODE_METRICS_STATE='codeMetricsReportState'
        STATE_SUPPORTED='supported'
        STATE_GENERATED='generated'
        STATE_UNSUPPORTED='unsupported'
        EXPECTED_FILENAME='metrics.html'
    end

    properties(Access=private,Constant)
        CHANNEL_INBOUND='codeMetricsReportService/request'
        CHANNEL_OUTBOUND='codeMetricsReportService/reply'
    end

    properties(Access=private)
ReportViewer
ReportFileListener
CodeMetricsHelper
CachedPage
PersistedPage
    end

    methods
        function this=CodeMetricsReportService(reportViewer)
            this.ReportViewer=reportViewer;
            this.ReportFileListener=addlistener(reportViewer,'ReportFile',...
            'PostSet',@(varargin)this.handleReportChange());
        end

        function start(this,~)
            this.ReportViewer.Client.subscribe(this.CHANNEL_INBOUND,...
            @(msg)this.handleClientLoadRequest(msg));
        end

        function shutdown(this)
            delete(this.ReportFileListener);
        end
    end

    methods(Access=private)
        function handleReportChange(this)
            this.deleteCachedPage();

            if~isempty(this.ReportViewer.FileSystem)&&...
                this.ReportViewer.FileSystem.fileExists(this.EXPECTED_FILENAME)
                this.PersistedPage=this.EXPECTED_FILENAME;
                this.CodeMetricsHelper=[];
            else
                this.PersistedPage=[];
                this.CodeMetricsHelper=codergui.internal.OnDemandCodeMetrics(this.ReportViewer);
            end
        end

        function handleClientLoadRequest(this,request)
            switch validatestring(request.requestType,{'isLoadable','load'})
            case 'isLoadable'



                this.reply(this.ReportViewer,request,this.CHANNEL_OUTBOUND,'loadable',...
                ~isempty(this.PersistedPage)||...
                ~isempty(this.CachedPage)||...
                this.CodeMetricsHelper.Supported||...
                ~isempty(this.CodeMetricsHelper.UnsupportedReason));
            otherwise
                [replyContent,error]=this.processLoadRequest();
                if~isempty(replyContent)
                    this.reply(this.ReportViewer,request,this.CHANNEL_OUTBOUND,'content',replyContent);
                else
                    this.fail(this.ReportViewer,request,this.CHANNEL_OUTBOUND,error);
                end
            end
        end

        function[content,failReason]=processLoadRequest(this)
            content='';
            failReason='';
            try
                if isempty(this.PersistedPage)&&isempty(this.CachedPage)
                    if this.CodeMetricsHelper.Supported
                        if~this.generateCodeMetricsReport()
                            failReason=message('coderWeb:matlab:cmReasonGenerationFailed').getString();
                        end
                    else
                        failReason=this.CodeMetricsHelper.UnsupportedReason;
                    end
                end
                if isempty(failReason)
                    if~isempty(this.PersistedPage)
                        content=this.ReportViewer.FileSystem.readTextFile(this.PersistedPage,'UTF-8');
                    elseif~isempty(this.CachedPage)
                        fid=fopen(this.CachedPage,'r','native','utf-8');
                        content=fread(fid,[1,inf],'*char');
                        fclose(fid);
                    else
                        content='';
                    end
                end
            catch me %#ok<NASGU>
                if isempty(failReason)
                    failReason=message('coderWeb:matlab:cmReasonGeneric').getString();
                end
            end
        end

        function success=generateCodeMetricsReport(this)
            success=false;
            tempPage=[];
            spareTempPage=false;
            try
                [dir,name,~]=fileparts(tempname);
                tempPage=fullfile(dir,['cmr',name,'.html']);
                this.CodeMetricsHelper.generatePage(tempPage);
                if exist(tempPage,'file')
                    try
                        if this.ReportViewer.FileSystem.Writable
                            this.storePageInReport(tempPage);
                            success=true;
                        end
                    catch me %#ok<NASGU>                        
                    end
                    if~success
                        this.cachePage(tempPage);
                        spareTempPage=true;
                        success=true;
                    end
                end
            catch me %#ok<NASGU>
            end
            if~isempty(tempPage)&&~spareTempPage
                codergui.internal.OnDemandCodeMetrics.silentlyDeleteFile(tempPage);
            end
        end

        function storePageInReport(this,page)
            try
                this.ReportViewer.FileSystem.addFile(this.EXPECTED_FILENAME,page);
                this.PersistedPage=this.EXPECTED_FILENAME;
            catch me
                this.PersistedPage=[];
                rethrow(me);
            end
        end

        function cachePage(this,page)
            if~isempty(this.CachedPage)
                codergui.internal.OnDemandCodeMetrics.silentlyDeleteFile(this.CachedPage);
            end
            this.CachedPage=page;
        end

        function deleteCachedPage(this)
            if~isempty(this.CachedPage)
                codergui.internal.OnDemandCodeMetrics.silentlyDeleteFile(this.CachedPage);
                this.CachedPage=[];
            end
        end
    end
end
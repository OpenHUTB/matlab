classdef(Sealed)NtxLauncherService<codergui.internal.WebService




    properties(Constant)
        HISTOGRAM_MAT_FILE='instrumentation/histograms.mat'
        HISTOGRAM_PROPERTY='hasInstrumentationReportHistograms'
        OPEN_CHANNEL_REQUEST='openNtx/request'
        OPEN_CHANNEL_REPLY='openNtx/reply'
    end

    properties(SetAccess=immutable)
ReportViewer
    end

    properties(Access=private)
ReportFileListener
Subscription
HistogramFile
HistogramFileCleanup
    end

    methods
        function this=NtxLauncherService(reportViewer)
            this.ReportViewer=reportViewer;
            this.ReportFileListener=addlistener(reportViewer,'ReportFile',...
            'PostSet',@(varargin)this.handleReportChange());
        end

        function start(this,~)
            this.handleReportChange();
        end

        function shutdown(this)
            delete(this.ReportFileListener);
            this.HistogramFileCleanup=[];
            this.closeAll();
        end
    end

    methods(Hidden)
        function handleReportChange(this)
            this.HistogramFile=[];
            this.HistogramFileCleanup=[];
            this.closeAll();
            if~isempty(this.ReportViewer.FileSystem)&&~isempty(this.ReportViewer.Manifest)&&...
                this.ReportViewer.Manifest.Properties.isKey(this.HISTOGRAM_PROPERTY)&&...
                this.ReportViewer.Manifest.Properties(this.HISTOGRAM_PROPERTY)&&isempty(this.Subscription)&&...
                ~isempty(which('fixed.internal.launchNTX'))
                this.Subscription=this.ReportViewer.Client.subscribe(this.OPEN_CHANNEL_REQUEST,@(msg)this.handleRequest(msg));
            elseif~isempty(this.Subscription)
                this.ReportViewer.Client.unsubscribe(this.Subscription);
                this.Subscription=[];
            end
        end
    end

    methods(Access=private)
        function handleRequest(this,msg)
            histogramFile=this.getHistogramFile();
            indexVec=[msg.majorIndex,1];
            if isfield(msg,'minorIndex')&&msg.minorIndex~=0
                indexVec(2)=msg.minorIndex;
            end
            try
                fixed.internal.launchNTX(histogramFile,indexVec);
                this.reply(this.ReportViewer.Client,msg,this.OPEN_CHANNEL_REPLY);
            catch me
                this.fail(this.ReportViewer.Client,msg,this.OPEN_CHANNEL_REPLY,me.message);
            end
        end

        function histogramFile=getHistogramFile(this)
            if isempty(this.HistogramFile)
                histogramStruct=this.ReportViewer.FileSystem.loadMatFile(...
                this.HISTOGRAM_MAT_FILE);
                histogramStruct=histogramStruct.histogramStruct;%#ok<NASGU>
                histogramFile=[tempname(),'.mat'];
                save(histogramFile,'histogramStruct');
                this.HistogramFile=histogramFile;
                this.HistogramFileCleanup=onCleanup(@()delete(histogramFile));
            end
            histogramFile=this.HistogramFile;
        end
    end

    methods(Static,Access=private)
        function closeAll()
            try
                coder.internal.closeAllLocationLoggingNumericTypeScopes('MATLABCoder');
            catch
            end
        end
    end
end
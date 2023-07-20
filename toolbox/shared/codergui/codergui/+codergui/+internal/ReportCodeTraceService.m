classdef ReportCodeTraceService<codergui.internal.WebService




    properties(Constant)
        C_TRACE_DATA_FILE='traceData.json'
        F2F_TRACE_DATA_FILE='f2fTraceData.json'
    end

    properties(SetAccess=immutable)
ReportViewer
TraceDataFile
Enabled
InboundChannel
OutboundChannel
    end

    properties(Access=private)
ReportFile
ReportFileListener
Client
Subscription
TraceModel
TraceDataReader
    end

    methods
        function this=ReportCodeTraceService(reportViewer,traceType)
            traceType=validatestring(traceType,{'c','f2f'});

            this.ReportViewer=reportViewer;
            this.ReportFileListener=addlistener(reportViewer,'ReportFile',...
            'PostSet',@(varargin)this.handleReportChange());
            this.Enabled=true;

            switch traceType
            case 'c'
                channelBase='codeTrace';
                this.Enabled=license('test','RTW_Embedded_Coder');
                this.TraceDataFile=this.C_TRACE_DATA_FILE;
            case 'f2f'
                channelBase='f2fTrace';
                this.Enabled=license('test','Fixed_Point_Toolbox');
                this.TraceDataFile=this.F2F_TRACE_DATA_FILE;
            end
            this.InboundChannel=reportViewer.Client.channel([channelBase,'/request']);
            this.OutboundChannel=reportViewer.Client.channel([channelBase,'/reply']);

            this.TraceModel=mf.zero.Model();
            this.TraceDataReader=coderapp.internal.file.trace.Reader(this.TraceModel);
        end

        function start(this,client)
            this.Client=client;
            this.Subscription=client.subscribe(this.InboundChannel,@(msg)this.handleRequest(msg));
        end

        function shutdown(this)
            this.Client.unsubscribe(this.Subscription);
            this.Subscription=[];
            this.Client=[];
            if~isempty(this.ReportViewer)
                delete(this.ReportFileListener);
            end
        end
    end

    methods(Hidden)
        function handleReportChange(this,~,~)
            this.TraceDataReader.clearTraceData();
        end

        function handleRequest(this,msg)
            result=[];
            try
                if~this.TraceDataReader.hasTraceData()

                    fs=this.ReportViewer.FileSystem;
                    if~isempty(fs)&&fs.fileExists(this.TraceDataFile)
                        this.TraceDataReader.loadTraceData(fs.readTextFile(this.TraceDataFile));
                    end
                end
                if isfield(msg,'queryType')&&~isempty(msg.queryType)
                    queryType=msg.queryType;
                else
                    queryType='data';
                end
                switch queryType
                case 'data'
                    if isfield(msg,'file')&&~isempty(msg.file)
                        result=this.TraceDataReader.query(...
                        msg.file,...
                        msg.includeTargetFileLocations);
                    else
                        codergui.internal.util.customError("Request must specify a file");
                    end
                case 'traceableFiles'
                    result=this.TraceDataReader.getTraceableFiles();
                otherwise
                    codergui.internal.util.customError(...
                    sprintf("Unrecognized query type: %s",queryType));
                end
            catch me
                this.fail(this.Client,msg,this.OutboundChannel,me.getReport());
                return;
            end
            this.reply(this.Client,msg,this.OutboundChannel,'result',result);
        end
    end
end
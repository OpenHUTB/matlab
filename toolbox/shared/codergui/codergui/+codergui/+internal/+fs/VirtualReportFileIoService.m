

classdef(Sealed)VirtualReportFileIoService<codergui.internal.WebService

    properties(SetAccess=immutable)
VirtualFs
InboundChannel
OutboundChannel
    end

    properties
        DefaultEncoding=''
    end

    properties(Access=private)
Client
Subscription
    end

    methods
        function this=VirtualReportFileIoService(virtualFs,inChannel,outChannel)
            this.VirtualFs=virtualFs;
            this.InboundChannel=inChannel;
            this.OutboundChannel=outChannel;
        end

        function start(this,client)
            this.Client=client;
            this.Subscription=client.subscribe(this.InboundChannel,@(msg)this.handleRequest(msg));
        end

        function shutdown(this)
            this.Client.unsubscribe(this.Subscription);
            this.Subscription=[];
            this.Client=[];
        end
    end

    methods(Hidden)
        function handleRequest(this,msg)
            content=[];

            if~codergui.internal.util.isAbsolute(msg.file)
                if strcmp(msg.file,codergui.ReportServices.MANIFEST_FILENAME)
                    content=this.VirtualFs.VirtualReport.ManifestContent;
                elseif this.VirtualFs.VirtualReport.hasPartitionContent(msg.file)
                    content=this.VirtualFs.VirtualReport.getPartitionContent(msg.file);
                else
                    workingDir='';
                    if isfield(msg,'workingRoot')&&~isempty(msg.workingRoot)
                        [parent,~,ext]=fileparts(msg.workingRoot);
                        if~isempty(ext)
                            if~isempty(parent)
                                workingDir=parent;
                            end
                        else
                            workingDir=msg.workingRoot;
                        end
                    end
                    if isempty(workingDir)
                        workingDir=pwd();
                    end
                    absFile=fullfile(workingDir,msg.file);
                end
            else
                absFile=msg.file;
            end
            if isempty(content)
                if isfield(msg,'encoding')&&~isempty(msg.encoding)
                    encoding={msg.encoding};
                elseif~isempty(this.DefaultEncoding)
                    encoding={this.DefaultEncoding};
                else
                    encoding={};
                end
                try
                    content=this.VirtualFs.readTextFile(absFile,encoding{:});
                catch me
                    this.fail(this.Client,msg,this.OutboundChannel,me.getReport());
                    return;
                end
            end
            this.reply(this.Client,msg,this.OutboundChannel,'content',content);
        end
    end
end
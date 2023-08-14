classdef(Sealed)ReportFileIoService<codergui.internal.WebService



    properties(SetAccess=immutable)
FileSystem
InboundChannel
OutboundChannel
    end

    properties
        DefaultEncoding=''
WorkingDirectory
    end

    properties(Access=private)
Client
Subscription
    end

    methods
        function this=ReportFileIoService(fs,inChannel,outChannel)
            this.FileSystem=fs;
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
            if isfield(msg,'file')&&~isempty(msg.file)
                if isfield(msg,'encoding')&&~isempty(msg.encoding)
                    encoding=msg.encoding;
                else
                    encoding=this.DefaultEncoding;
                end
                try
                    if~codergui.internal.util.isAbsolute(msg.file)&&this.FileSystem.fileExists(msg.file)
                        content=this.FileSystem.readTextFile(msg.file,encoding);
                    end
                    if isempty(content)
                        if isfield(msg,'workingRoot')&&~isempty(msg.workingRoot)
                            [parent,~,ext]=fileparts(msg.workingRoot);
                            if~isempty(ext)
                                if~isempty(parent)
                                    workingDir=parent;
                                end
                            else
                                workingDir=msg.workingRoot;
                            end
                        elseif~isempty(this.WorkingDirectory)
                            workingDir=this.WorkingDirectory;
                        else
                            workingDir=pwd();
                        end
                        absFile=fullfile(workingDir,msg.file);
                        if this.FileSystem.fileExists(msg.file)
                            content=this.FileSystem.readTextFile(absFile,encoding);
                        end
                    end
                catch me
                    this.fail(this.Client,msg,this.OutboundChannel,me.getReport());
                    return;
                end
            end
            this.reply(this.Client,msg,this.OutboundChannel,'content',content);
        end
    end
end

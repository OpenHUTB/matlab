classdef SSH<handle

    events
ResultReady
    end


    properties(Constant,Hidden)

        ConverterPlugin=fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'sshmlconverter');

        DevicePlugin=fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'sshdevice');
    end

    properties(Access=private,Transient=true)

AsyncIOChannel
    end

    properties(GetAccess=public,SetAccess=protected)
Host
Port
User
Password
ResultPending
Blocking
    end

    properties(GetAccess=private,SetAccess=private)
CustomListener
    end


    methods(Access=public)
        function obj=SSH(host,port,user,password,varargin)
            host=convertCharsToStrings(host);
            user=convertCharsToStrings(user);
            password=convertCharsToStrings(password);

            try
                validateattributes(host,{'string'},{'scalar','nonempty'},'SSH','HOST');
                validateattributes(user,{'string'},{'scalar'},'SSH','USER');
                validateattributes(password,{'string'},{'scalar'},'SSH','PASSWORD');
                validateattributes(port,{'numeric'},{'>=',1,'<=',65535,'scalar',...
                'nonnegative','finite','integer'},'SSH','PORTNUMBER',2)

            catch validationException
                throwAsCaller(validationException);
            end

            obj.Host=host;
            obj.Port=port;
            obj.User=user;
            obj.Password=password;

            parser=inputParser;
            parser.FunctionName="SSH";
            isScalarLogical=@(x)islogical(x)&&isscalar(x);
            parser.addParameter('Blocking',false,isScalarLogical);
            parser.parse(varargin{:});
            obj.Blocking=parser.Results.Blocking;

            options.NewMessageStyle=true;
            options.HostName=host;
            options.PortNumber=int32(port);
            options.UserName=user;
            options.Password=password;
            options.Blocking=obj.Blocking;

            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(obj.DevicePlugin,obj.ConverterPlugin);
            obj.AsyncIOChannel.open(options);
            obj.CustomListener=addlistener(obj.AsyncIOChannel,'Custom',@obj.handleCustomEvent);
        end


        function execute(obj,cmd)
            if(obj.ResultPending)
                errID='slrealtime:target:sshExecBusy';
                msg=message(errID);
                exc=MException(errID,'%s',msg.getString());
                throw(exc);
            end

            cmd=convertCharsToStrings(cmd);
            try
                validateattributes(cmd,{'string'},{'scalar'},'SSH','COMMAND');
            catch validationException
                throwAsCaller(validationException);
            end

            try
                obj.AsyncIOChannel.execute(cmd);
            catch ME
                throwAsCaller(ME);
            end
        end


        function scpSend(obj,srcPath,destPath)
            if(obj.ResultPending)
                errID='slrealtime:target:sshExecBusy';
                msg=message(errID);
                exc=MException(errID,'%s',msg.getString());
                throw(exc);
            end
            srcPath=convertCharsToStrings(srcPath);
            destPath=convertCharsToStrings(destPath);
            try
                validateattributes(srcPath,{'string'},{'scalar'},'SSH','SRCPATH');
                validateattributes(destPath,{'string'},{'scalar'},'SSH','DESTPATH');
            catch validationException
                throwAsCaller(validationException);
            end

            options.Mode="scp_send";
            options.SourcePath=srcPath;
            options.DestPath=destPath;
            try
                obj.AsyncIOChannel.execute("",options);
            catch ME
                throwAsCaller(ME);
            end
        end


        function scpReceive(obj,srcPath,destPath)
            if(obj.ResultPending)
                errID='slrealtime:target:sshExecBusy';
                msg=message(errID);
                exc=MException(errID,'%s',msg.getString());
                throw(exc);
            end
            srcPath=convertCharsToStrings(srcPath);
            destPath=convertCharsToStrings(destPath);
            try
                validateattributes(srcPath,{'string'},{'scalar'},'SSH','SRCPATH');
                validateattributes(destPath,{'string'},{'scalar'},'SSH','DESTPATH');
            catch validationException
                throwAsCaller(validationException);
            end

            options.Mode="scp_recv";
            options.SourcePath=srcPath;
            options.DestPath=destPath;
            try
                obj.AsyncIOChannel.execute("",options);
            catch ME
                throwAsCaller(ME);
            end
        end


        function r=getResult(obj)
            r=obj.AsyncIOChannel.Result;
            if isfield(r,'ErrorID')
                error(message(r.ErrorID,r.ErrorMessage));
            end
            obj.ResultPending=false;
        end


        function r=waitForResult(obj)
            r=obj.AsyncIOChannel.Result;
            if obj.Blocking
                if isempty(r)
                    throw(MException('network:ssh:noResultError',...
                    message('network:ssh:noResultError').getString()));
                end
            else
                while isempty(r)
                    pause(.2);
                    r=obj.AsyncIOChannel.Result;
                end
            end

            obj.ResultPending=false;
        end

    end


    methods(Access=private)
        function handleCustomEvent(obj,~,eventData)


            obj.ResultPending=true;
            notify(obj,'ResultReady');
        end

        function terminateChannel(obj)
            if(~isempty(obj.AsyncIOChannel))
                obj.AsyncIOChannel.close();
                delete(obj.AsyncIOChannel);
                obj.AsyncIOChannel=[];

                delete(obj.CustomListener);
                obj.CustomListener=[];
            end
        end
    end

    methods(Access=public,Hidden)
        function test(obj,cmd,options)

            obj.AsyncIOChannel.execute(cmd,options)
        end

        function delete(obj)
            terminateChannel(obj);
        end

    end
end

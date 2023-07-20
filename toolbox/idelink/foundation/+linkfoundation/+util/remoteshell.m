classdef remoteshell





























































    properties
hostname
        username='';
        port=22;
        protocol='ssh';
    end

    properties(Hidden)
        password=''
    end

    properties(Constant,GetAccess=private)
        putils=fullfile(matlabroot,'toolbox','idelink',...
        'foundation','hostapps');
    end

    properties(Dependent,Access=protected)
cmdline
copycmd1
copycmd2
usernameprefix
    end


    methods

        function obj=remoteshell(hostname,username,password,protocol,port)
            narginchk(1,5);
            if(nargin==5)
                obj.port=port;
            end
            if(nargin>=4)
                obj.protocol=protocol;
            end
            if(nargin>=3)
                obj.password=password;
            end
            if(nargin>=2)
                obj.username=username;
            end
            obj.hostname=hostname;
        end


        function obj=set.port(obj,port)
            if(~(isnumeric(port)&&isscalar(port)&&(port>=1)&&(port<=65535)))
                DAStudio.error('ERRORHANDLER:utils:InvalidPort');
            end
            obj.port=int16(port);
        end


        function obj=set.protocol(obj,protocol)
            if(~isa(protocol,'char')||...
                ~(strcmpi(protocol,'ssh')||strcmpi(protocol,'rsh')))
                DAStudio.error('ERRORHANDLER:utils:UnknownProtocol',protocol);
            end
            if ispc&&strcmpi(protocol,'rsh')
                DAStudio.error('ERRORHANDLER:utils:RshNotSupporttedInWindows');
            end
            obj.protocol=protocol;
        end


        function obj=set.password(obj,password)
            if~isa(password,'char')
                DAStudio.error('ERRORHANDLER:utils:NotString','password');
            end
            obj.password=password;
        end


        function obj=set.hostname(obj,hostname)
            if~isa(hostname,'char')
                DAStudio.error('ERRORHANDLER:utils:NotString','hostname');
            end
            obj.hostname=strtrim(hostname);
        end


        function obj=set.username(obj,username)
            if~isa(username,'char')
                DAStudio.error('ERRORHANDLER:utils:NotString','username');
            end
            obj.username=strtrim(username);
        end


        function cmdline=get.cmdline(obj)
            if isequal(obj.protocol,'ssh')
                if ispc
                    cmdline=['"',fullfile(obj.putils,'plink'),'" -ssh -pw "',...
                    obj.password,'" -P ',num2str(obj.port),' ',...
                    obj.usernameprefix,obj.hostname,' '];
                elseif ismac
                    cmdline=['sshpass -p "',...
                    obj.password,'" ssh -o StrictHostKeyChecking=no -p ',num2str(obj.port),' ',...
                    obj.usernameprefix,obj.hostname,' '];
                elseif isunix
                    cmdline=['sshpass -p "',...
                    obj.password,'" ssh -o StrictHostKeyChecking=no -p ',num2str(obj.port),' ',...
                    obj.usernameprefix,obj.hostname,' '];
                else
                    cmdline=['sshpass -p "',...
                    obj.password,'" ssh -p ',num2str(obj.port),' ',...
                    obj.usernameprefix,obj.hostname,' '];
                end
            else
                cmdline=['rsh -l ',obj.username,' ',obj.hostname,' '];
            end
        end


        function value=get.copycmd1(obj)
            if isequal(obj.protocol,'ssh')
                if ispc
                    value=['"',fullfile(obj.putils,'pscp'),'" -pw "',...
                    obj.password,'" -P ',num2str(obj.port),' '];
                else
                    value=['sshpass -p "',...
                    obj.password,'" scp -P ',num2str(obj.port),' '];
                end
            else
                value='rcp ';
            end
        end


        function value=get.copycmd2(obj)
            if isequal(obj.protocol,'ssh')
                value=[obj.usernameprefix,obj.hostname,':'];
            else
                value='';
            end
        end


        function value=get.usernameprefix(obj)
            if isempty(obj.username)
                value='';
            else
                value=[obj.username,'@'];
            end
        end
    end


    methods(Access=public)
        function[status,msg]=connect(obj,cmd)






            if(nargin<2)
                cmd='echo Connection successful';
            end
            cmdprefix='echo y| ';
            [status,msg]=obj.execute(cmd,false,cmdprefix);
        end


        function[status,result]=execute(obj,cmd,echooutput,cmdprefix)







            if(nargin<3)
                echooutput=false;
            end
            if(nargin<4)
                cmdprefix='';
            end
            if(echooutput)
                [status,result]=system([cmdprefix,obj.cmdline,...
                obj.decoratecmd(cmd)],'-echo');
            else
                [status,result]=system([cmdprefix,obj.cmdline,...
                obj.decoratecmd(cmd)]);

            end
        end


        function[status,result]=run(obj,appname,openshell)







            if(nargin<3)
                openshell=false;
            end
            if(openshell)
                [status,result]=system([obj.cmdline,'"',appname,'"&'],'-echo');
            else
                [status,result]=system([obj.cmdline,'"',appname,'"']);
            end
        end


        function[status,result]=copyfile(obj,source,destination)








            copycmd=[...
            obj.copycmd1,obj.decoratecmd(source),...
            ' ',...
            obj.copycmd2,obj.decoratecmd(destination)];
            [status,result]=system(copycmd);
        end

        function[status,result]=putfile(obj,source,destination)








            copycmd=[...
            obj.copycmd1,obj.decoratecmd(source),...
            ' ',...
            obj.copycmd2,obj.decoratecmd(destination)];
            [status,result]=system(copycmd);
        end


        function[status,result]=getfile(obj,source,destination)








            copycmd=[obj.copycmd1,obj.copycmd2,...
            obj.decoratecmd(source),...
            ' ',...
            obj.decoratecmd(destination)];
            [status,result]=system(copycmd);
        end

    end

    methods(Static,Access=public)


        function cmd=decoratecmd(varargin)








            cmd='"';
            for i=1:nargin
                cmd=[cmd,varargin{i}];%#ok<AGROW>
                if(i~=nargin)
                    cmd=[cmd,' '];%#ok<AGROW>
                end
            end
            cmd=[cmd,'"'];
        end

    end

    methods(Hidden,Access=public)
        function cmd=insertpasswd(obj,cmd)


            cmd=sprintf(cmd,obj.password);
        end
    end

end


classdef BoardParameters





    properties
BoardName
    end

    properties(Constant,Hidden)
        DEFAULTHOSTNAMEPREF='DefaultIpAddress';
        DEFAULTUSERNAMEPREF='DefaultUserName';
        DEFAULTPASSWORDPREF='DefaultPasswordPref';
        DEFAULTBUILDDIRPREF='DefaultBuildDirPref';
        DEFAULTSSHPORTPREF='DefaultsshportPref';
        DEFAULTEXTPORTPREF='DefaultextmodeportPref';
        DEFAULTPILPORTPREF='DefaultpilportPref';
        DEFAULTHOSTNAME='10.10.10.1';
        DEFAULTUSERNAME='root';
        DEFAULTPASSWORD='root';
        DEFAULTSSHPORT=22;
        DEFAULTEXTPORT=17725;
        DEFAULTPILPORT=17725;
        GROUP='Hardware_Connectivity_Installer';
    end

    methods
        function obj=BoardParameters(boardName)

            if(nargin>0)
                obj.BoardName=boardName;
            end
        end

        function[hostName,userName,password,buildDir]=getBoardParameters(obj)

            if nargout>0
                hostName=obj.getParam('hostName');
            end
            if nargout>1
                userName=obj.getParam('userName');
            end
            if nargout>2
                password=obj.getParam('password');
            end
            if nargout>3
                buildDir=obj.getParam('buildDir');
            end
        end

        function clearBoardParams(obj)
            obj.removePref(obj.BoardName,obj.DEFAULTHOSTNAMEPREF);
            obj.removePref(obj.BoardName,obj.DEFAULTUSERNAMEPREF);
            obj.removePref(obj.BoardName,obj.DEFAULTPASSWORDPREF);
            obj.removePref(obj.BoardName,obj.DEFAULTBUILDDIRPREF);
        end

        function ret=getParam(obj,parameterName)

            switch lower(parameterName)
            case{'hostname','ipaddress'}
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTHOSTNAMEPREF);
                if isempty(ret)||~isa(ret,'char')

                    ret=obj.DEFAULTHOSTNAME;
                end
            case 'username'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTUSERNAMEPREF);
                if isempty(ret)||~isa(ret,'char')
                    ret=obj.DEFAULTUSERNAME;
                end
            case 'password'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTPASSWORDPREF);
                if~isa(ret,'char')
                    ret=obj.DEFAULTPASSWORD;
                end
            case 'builddir'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTBUILDDIRPREF);
                if isempty(ret)||~isa(ret,'char')
                    userName=obj.getParam('userName');
                    ret=['/home/',userName];
                end
            case 'sshport'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTSSHPORTPREF);
                if isempty(ret)||~isa(ret,'numeric')

                    ret=obj.DEFAULTSSHPORT;
                end
            case 'extmodeport'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTEXTPORTPREF);
                if isempty(ret)||~isa(ret,'numeric')

                    ret=obj.DEFAULTEXTPORT;
                end
            case 'pilport'
                ret=obj.getPref(...
                obj.BoardName,obj.DEFAULTPILPORTPREF);
                if isempty(ret)||~isa(ret,'numeric')

                    ret=obj.DEFAULTPILPORT;
                end
            otherwise

                ret=obj.getPref(...
                obj.BoardName,['Default',parameterName,'Pref']);
            end
        end

        function setParam(obj,parameterName,parameterValue)

            switch lower(parameterName)
            case{'hostname','ipaddress'}
                obj.setPref(...
                obj.BoardName,obj.DEFAULTHOSTNAMEPREF,...
                parameterValue);
            case 'username'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTUSERNAMEPREF,...
                parameterValue);
            case 'password'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTPASSWORDPREF,...
                parameterValue);
            case 'builddir'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTBUILDDIRPREF,...
                parameterValue);
            case 'sshport'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTSSHPORTPREF,...
                parameterValue);
            case 'extmodeport'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTEXTPORTPREF,...
                parameterValue);
            case 'pilport'
                obj.setPref(...
                obj.BoardName,obj.DEFAULTPILPORTPREF,...
                parameterValue);
            otherwise

                obj.setPref(...
                obj.BoardName,...
                ['Default',parameterName,'Pref'],...
                parameterValue);
            end
        end

        function removeParam(obj,parameterName)

            switch lower(parameterName)
            case{'hostname','ipaddress'}
                obj.removePref(...
                obj.BoardName,obj.DEFAULTHOSTNAMEPREF);
            case 'username'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTUSERNAMEPREF);
            case 'password'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTPASSWORDPREF);
            case 'builddir'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTBUILDDIRPREF);
            case 'sshport'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTSSHPORTPREF);
            case 'extmodeport'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTEXTPORTPREF);
            case 'pilport'
                obj.removePref(...
                obj.BoardName,obj.DEFAULTPILPORTPREF);
            otherwise

                obj.removePref(...
                obj.BoardName,...
                ['Default',parameterName,'Pref']);
            end
        end

        function prefValue=getPref(obj,group,pref)
            prefGroup=obj.GROUP;
            prefGroup=strcat(prefGroup,'_',group);
            if ispref(prefGroup,pref)
                prefValue=getpref(prefGroup,pref);
            else
                prefValue=[];
            end
        end

        function setPref(obj,group,pref,value)
            prefGroup=obj.GROUP;
            prefGroup=strcat(prefGroup,'_',group);
            setpref(prefGroup,pref,value);
        end

        function removePref(obj,group,pref)
            prefGroup=obj.GROUP;
            prefGroup=strcat(prefGroup,'_',group);
            rmpref(prefGroup,pref);
        end
    end
end


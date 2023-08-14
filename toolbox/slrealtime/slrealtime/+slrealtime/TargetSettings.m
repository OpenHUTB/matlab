classdef TargetSettings<matlab.mixin.SetGetExactNames






    methods(Access=public)



        function this=TargetSettings(name,varargin)
            p=inputParser;
            p.addRequired('name',@this.isCharOrString);
            p.addOptional('address','',@this.isCharOrString);
            p.addOptional('sshPort',22,@isnumeric);
            p.addOptional('xcpPort',5555,@isnumeric);
            p.addOptional('username','slrt',@this.isCharOrString);
            p.addOptional('userPassword','slrt',@this.isCharOrString);
            p.addOptional('rootPassword','root',@this.isCharOrString);
            p.parse(name,varargin{:});

            if isempty(p.Results.name)
                errId='slrealtime:settings:emptyName';
                msg=message(errId);
                exc=MException(errId,'%s',msg.getString());
                throw(exc);
            end

            this.name=convertStringsToChars(p.Results.name);
            this.address=convertStringsToChars(p.Results.address);
            this.sshPort=p.Results.sshPort;
            this.xcpPort=p.Results.xcpPort;
            this.username=convertStringsToChars(p.Results.username);
            this.userPassword=convertStringsToChars(p.Results.userPassword);
            this.rootPassword=convertStringsToChars(p.Results.rootPassword);
        end
    end

    methods



        function set.name(this,name)
            targets=slrealtime.Targets;
            if~targets.getInitializing()
                targetNames=targets.getTargetNames();
                if any(strcmp(targetNames,name))



                    this.throwErrorAsCaller('slrealtime:targets:targetExists',name)
                end
            end
            this.name=name;
        end
        function set.address(this,address)


            if~isempty(address)
                isValidIp=slrealtime.internal.validateIpAddress(address);
                if~isValidIp

                    this.throwErrorAsCaller('slrealtime:target:badipaddr',address);
                end
            end
            this.address=address;
        end
    end

    methods(Access=private,Static)



        function val=isCharOrString(str)
            val=isstring(str)||ischar(str);
        end
    end

    methods(Access=private,Static)



        function exc=createExc(errId,varargin)
            msg=message(errId,varargin{:});
            exc=MException(errId,'%s',msg.getString());
        end
        function throwError(errId,varargin)
            throw(slrealtime.TargetSettings.createExc(errId,varargin{:}));
        end
        function throwErrorAsCaller(errId,varargin)
            throwAsCaller(slrealtime.TargetSettings.createExc(errId,varargin{:}));
        end
    end

    properties(Access=public,SetObservable)
name
address
sshPort
xcpPort
username
userPassword
rootPassword
    end
end

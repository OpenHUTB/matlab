classdef(SupportExtensionMethods=true,Sealed)TargetHardware<handle %#ok<ATUNK>




    properties(SetAccess='private')
SupportPackageNames
TargetHardwareInfo
    end
    properties(SetAccess='private',Hidden)
TargetHardwareDeprecationInfo
    end
    methods(Access='private')
        function obj=TargetHardware
            obj.TargetHardwareInfo=containers.Map;
            obj.TargetHardwareDeprecationInfo=containers.Map;
            obj.SupportPackageNames={};
        end
    end
    methods(Static)
        function output=getInstance(varargin)
            mlock;
            persistent regInstance;
            if nargin>0&&ischar(varargin{1})&&isequal(varargin{1},'destroy')
                regInstance=[];
                output=regInstance;
            elseif nargin>0&&ischar(varargin{1})&&isequal(varargin{1},'refresh')
                regInstance=realtime.internal.TargetHardware;
                loc_refresh(regInstance);
                output=regInstance;
            elseif nargin>0&&ischar(varargin{1})&&isequal(varargin{1},'get')
                output=regInstance;
            else
                assert(false,'Invalid call to TargetHardware')
            end
        end
        function output=getAllTargetHardwareInfosInRegistry
            obj=realtime.internal.TargetHardware.getInstance('get');
            output=obj.TargetHardwareInfo;
        end
        function out=getTargetHardwareInfoFromRegistry(supportPackageName)


            obj=realtime.internal.TargetHardware.getInstance('get');
            if~obj.TargetHardwareInfo.isKey(supportPackageName)
                error('The support package ''%s'' is not in the Target Hardware Registry',...
                supportPackageName);
            end
            out=obj.TargetHardwareInfo(supportPackageName);
        end
        function out=getTargetHardwareDeprecationInfo(targetHardwareName)


            obj=realtime.internal.TargetHardware.getInstance('get');
            if~obj.TargetHardwareDeprecationInfo.isKey(targetHardwareName)
                out=[];
            else
                out=obj.TargetHardwareDeprecationInfo(targetHardwareName);
            end
        end
        function out=getAllDeprecatedTargetHardwares
            obj=realtime.internal.TargetHardware.getInstance('get');
            out=obj.TargetHardwareDeprecationInfo.keys;
        end
    end
    methods(Access='private')


        function addSupportPacakgeToRegistry(hObj,supportPackageName)

            if~any(ismember(hObj.SupportPackageNames,supportPackageName))
                hObj.SupportPackageNames{end+1}=supportPackageName;
            end
        end
        function addSupportPackageToRegistry(hObj,supportPackageName)

            if~any(ismember(hObj.SupportPackageNames,supportPackageName))
                hObj.SupportPackageNames{end+1}=supportPackageName;
            end
        end
        function addTargetHardwareInfoToRegistry(hObj,supportPackageName,targetHardware,dataFile)





            narginchk(4,4);
            if~any(ismember(hObj.SupportPackageNames,supportPackageName))


                error(['The Support Package ''%s'' does not exist in the',...
                ' RealtimeInfo registry. Please run addSupportPacakgeToRegistry',...
                ' to add this file to the registry before running addTargethardwareInfoToRegistry'],supportPackageName);
            else
                if hObj.TargetHardwareInfo.isKey(supportPackageName)
                    targetHardwareInfo=hObj.TargetHardwareInfo(supportPackageName);
                else
                    targetHardwareInfo=containers.Map;
                end
            end
            targetHardwareInfo(targetHardware)=dataFile;
            hObj.TargetHardwareInfo(supportPackageName)=targetHardwareInfo;
        end
        function addDeprecatedTargetHardware(hObj,targetHardware,deprecationFcnHandle)



            narginchk(3,3);
            hObj.TargetHardwareDeprecationInfo(targetHardware)=...
            codertarget.tools.TargetHardwareDeprecationInfo(deprecationFcnHandle);
        end
        function loc_refresh(hObj)
            metadata=meta.class.fromName('realtime.internal.TargetHardware');
            m={metadata.MethodList(ismember({metadata.MethodList(:).Access},'public')).Name};
            type='addTargetHardware_';
            for index=1:length(m)
                if strncmp(m{index},type,length(type))
                    try
                        feval(m{index},hObj);
                    catch ME
                        warning(ME.identifier,'%s',ME.getReport);
                    end
                end
            end
        end
    end
end
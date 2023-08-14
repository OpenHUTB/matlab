classdef(Hidden)Hardware<embedded.HardwareBase




    properties(Dependent,Hidden)
InTestEnvironment
    end

    properties(Access=private)
pSupportedHardwareInfo
pSupportedHardware
pEmbeddedFWInfo
pTargetName
pIsBoardCustom
    end

    methods(Access=public)
        function obj=Hardware(hwName,varargin)
            obj=obj@embedded.HardwareBase(hwName);
            [validHW,validHWInfo]=soc.internal.customoperatingsystem.getHardwareBoards;
            boardIdx=find(contains(validHW,hwName,'IgnoreCase',true));
            if boardIdx
                hwInfo=codertarget.targethardware.getTargetHardwareFromNameForSoC(hwName);
                obj.pTargetName=getTargetName(hwInfo);
                obj.pEmbeddedFWInfo=validHWInfo{boardIdx};
                obj.pIsBoardCustom=false;
            else
                if nargin>1
                    obj.DeviceID=varargin{1};
                end
                obj.pIsBoardCustom=true;
            end
        end
    end

    methods
        function boardInterfaceArgs=getBoardParameters(obj,operatingSystemName)
            if obj.pIsBoardCustom
                boardInterfaceArgs=[];
            else
                validatestring(operatingSystemName,{obj.pEmbeddedFWInfo.OperatingSystems.Name},'getBoardParameters','OperatingSystemName',2);
                fwInfo=getFirmwareInformation(obj,operatingSystemName);
                boardInterfaceArgs=cell(1,numel(fwInfo.BoardParameters));
                boardParamObj=matlabshared.internal.BoardParameters(obj.pEmbeddedFWInfo.BoardParameterGroupName);
                for i=1:numel(fwInfo.BoardParameters)
                    boardInterfaceArgs{i}=getParam(boardParamObj,fwInfo.BoardParameters{i});
                end
            end
        end

        function ret=getFirmwareInformation(obj,operatingSystemName)
            if obj.pIsBoardCustom
                ret=[];
            else
                validatestring(operatingSystemName,{obj.pEmbeddedFWInfo.OperatingSystems.Name},'getFirmwareInformation','OperatingSystemName',2);
                [found,idx]=ismember(lower(operatingSystemName),lower({obj.pEmbeddedFWInfo.OperatingSystems.Name}));
                if found
                    ret=obj.pEmbeddedFWInfo.OperatingSystems(idx);
                else
                    error(message('soc:os:UnsupportedOS',operatingSystemName));
                end
            end
        end

        function ret=getValidOperatingSystem(obj)
            if obj.pIsBoardCustom
                ret='linux';
            else
                ret={obj.pEmbeddedFWInfo.OperatingSystems.Name};
            end
        end
    end

end

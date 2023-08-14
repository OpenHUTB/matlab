classdef TargetHardwarePlugin<handle





    properties(Abstract)
TgtHwID
TgtName
TgtHwFolder
    end

    properties
        IsSoCPlugin=true;
    end

    methods
        function out=getSupportedHwBoards(obj)
            out={};
            for i=1:numel(obj.TgtHwFolder)
                baseFolder='';
                try
                    baseFolder=eval(obj.TgtHwFolder{i});
                catch
                end
                if~isempty(baseFolder)
                    boardFolder=codertarget.target.getTargetHardwareRegistryFolder(baseFolder);
                    boardInfo=codertarget.target.getTargetHardwareInfo(baseFolder,boardFolder,obj.TgtName{i});
                    if~isempty(boardInfo)
                        if obj.IsSoCPlugin
                            boardInfo=boardInfo([boardInfo.IsSoCCompatible]);
                        end
                        out=[out,{boardInfo.Name}];
                    end
                end
            end
        end
    end
end
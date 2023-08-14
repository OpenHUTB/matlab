classdef DeviceSetup<handle





    properties(Abstract,Constant)
BitstreamFolder
Application
    end

    properties
Radio
App
HandOff
    end

    methods
        function obj=DeviceSetup(radioObj,appObj)
            obj.Radio=radioObj;
            obj.App=appObj;
            obj.HandOff=getHandOff(obj);
        end
        function flag=canRadioRunApplication(obj,driver)
            [names,ids]=getCompatibleBlocksAndIDs(obj);
            flag=radioHasBlocks(driver,names,ids);
        end
        function handoff=getHandOff(obj,varargin)



            handoff.bitstream=fullfile(obj.BitstreamFolder,strcat(obj.Application,'_',lower(obj.Radio.Product),'_hg.bit'));
        end

        function success=setupHardware(obj,varargin)
            success=obj.Radio.setupHardware(obj.HandOff);
            if~success
                error(message("wt:rfnoc:hardware:RadioSetupFailed"));
            end
        end

        function[names,ids]=getCompatibleBlocksAndIDs(obj)%#ok<MANU>
            names=[];
            ids=[];
        end
    end
end


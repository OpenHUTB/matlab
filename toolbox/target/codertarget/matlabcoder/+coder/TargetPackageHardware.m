classdef TargetPackageHardware<coder.HardwareBase




    methods(Access=public)
        function obj=TargetPackageHardware(name)
            obj.Name=name;

            board=obj.getBoard();

            obj.DeviceName=board.Processors(1).getQualifiedParameterString();

            obj.HardwareInfo.ProdHWDeviceType=obj.DeviceName;
            obj.HardwareInfo.Name=name;
            obj.HardwareInfo.TargetName=name;
            menuItem=codertarget.utils.getDropDownItemFromBoard(board);
            obj.HardwareInfo.DisplayName=menuItem.disp;
        end

        function addedToConfig(obj,cfg)
            if cfg.HardwareImplementation.ProdEqTarget
                cfg.HardwareImplementation.ProdHWDeviceType=obj.DeviceName;
            else
                cfg.HardwareImplementation.TargetHWDeviceType=obj.DeviceName;
            end
        end

        function preBuild(obj,cfg)
        end

        function postCodegen(obj,cfg,buildInfo)
        end

        function postBuild(obj,cfg,buildInfo)
        end

        function errorHandler(obj,cfg)
        end

        function board=getBoard(obj)
            [valid,board]=codertarget.utils.isTargetFrameworkTarget(obj.Name);
            assert(valid,message('codertarget:utils:InvalidTargetPackageHardware',obj.Name));
        end

        function s=saveobj(obj)

            s.Name=obj.Name;
            s.Version=obj.Version;
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)



                obj=coder.hardware(s.Name);
                obj.Version=s.Version;
            end
        end
    end

    properties
        Name char=''
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
        DeviceName char='';
        Version char='1.0'
    end
end

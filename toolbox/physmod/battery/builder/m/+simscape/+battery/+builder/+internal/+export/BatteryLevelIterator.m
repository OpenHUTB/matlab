classdef(Sealed=true,Hidden=true)BatteryLevelIterator<handle





    properties(GetAccess=private,SetAccess=immutable)
        BatteryTree(1,1){mustBeA(BatteryTree,["simscape.battery.builder.Pack"...
        ,"simscape.battery.builder.ModuleAssembly","simscape.battery.builder.Module"...
        ,"simscape.battery.builder.ParallelAssembly"])}...
        =simscape.battery.builder.Pack;
        RootLevelIndex(1,1)int64{mustBeGreaterThan(RootLevelIndex,0),mustBeLessThanOrEqual(RootLevelIndex,5)}=1;
    end

    properties(Access=private)
        CurrentLevelIdx=0;
        BatteriesAtCurrentLevel=[];
    end

    properties(Constant,Access=private)
        BatteryLevels=[simscape.battery.builder.ParallelAssembly.Type,simscape.battery.builder.Module.Type,...
        simscape.battery.builder.ModuleAssembly.Type,simscape.battery.builder.Pack.Type];
    end

    methods
        function obj=BatteryLevelIterator(batteryTree)

            obj.BatteryTree=batteryTree;
            obj.RootLevelIndex=find(obj.BatteryLevels==obj.BatteryTree.Type);
        end

        function hasNextLevel=hasNextLevel(obj)

            hasNextLevel=obj.CurrentLevelIdx<obj.RootLevelIndex;
        end

        function batteries=getNextLevel(obj)

            obj.BatteriesAtCurrentLevel=[];
            obj.goToNextLevel();
            obj.getBatteriesOfType(obj.BatteryTree)
            batteries=obj.BatteriesAtCurrentLevel;
        end
    end

    methods(Access=private)
        function getBatteriesOfType(obj,battery)


            if isequal(obj.BatteryLevels(obj.CurrentLevelIdx),battery.Type)

                if isempty(obj.BatteriesAtCurrentLevel)||all([obj.BatteriesAtCurrentLevel.BlockType]~=battery.BlockType)
                    obj.BatteriesAtCurrentLevel=[obj.BatteriesAtCurrentLevel,battery];
                else


                end
            else

                switch battery.Type
                case simscape.battery.builder.ParallelAssembly.Type
                    obj.getBatteriesOfType(battery.Cell);

                case simscape.battery.builder.Module.Type
                    obj.getBatteriesOfType(battery.ParallelAssembly);

                case simscape.battery.builder.ModuleAssembly.Type
                    modules=battery.Module;
                    for moduleIdx=1:length(modules)
                        obj.getBatteriesOfType(modules(moduleIdx));
                    end

                case simscape.battery.builder.Pack.Type
                    moduleAssemblies=battery.ModuleAssembly;
                    for moduleAssemblyIdx=1:length(moduleAssemblies)
                        obj.getBatteriesOfType(moduleAssemblies(moduleAssemblyIdx));
                    end

                otherwise


                end
            end
        end
        function goToNextLevel(obj)

            assert(obj.hasNextLevel,message("physmod:battery:builder:export:NoNextLevel"));
            obj.CurrentLevelIdx=obj.CurrentLevelIdx+1;
        end
    end
end


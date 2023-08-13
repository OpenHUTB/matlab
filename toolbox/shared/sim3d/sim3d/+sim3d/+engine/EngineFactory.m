classdef EngineFactory<handle

    properties(Constant=true,Access=private)
        map=containers.Map({'win64','glnxa64','maci64'},{'EngineWin64','EngineGlnxa64',[]});
    end

    methods
        function self=EngineFactory()

        end

        function engine=createEngine(self)

            engineClass=self.map(computer('arch'));
            if isempty(engineClass)
                error(message('shared_sim3dblks:sim3dblkConfig:blkPrmError_UnsupportedPlatform'));
            else
                engine=eval(['sim3d.engine.',engineClass,'()']);
            end
        end
    end
end


classdef EngineFactory<handle
    properties(Constant=true,Access=private)
        map=containers.Map({'win64','glnxa64','maci64'},{'EngineWin64','EngineGlnxa64',[]});
    end


    methods

        function self=EngineFactory()
        end


        % 用虚幻引擎的工厂创建虚幻引擎
        % 定一个用于创建对象的接口，让子类决定实例化哪一个类（工厂方法）
        function engine=createEngine(self)
            engineClass=self.map(computer('arch'));
            if isempty(engineClass)
                error(message('shared_sim3dblks:sim3dblkConfig:blkPrmError_UnsupportedPlatform'));
            else
                engine = eval(['sim3d.engine.', engineClass,'()']);  % 根据不同平台(engineClass:win64, Glnxa64)创建不同的
            end
        end
    end
end


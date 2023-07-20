

classdef CodeGenInfoManager<handle

    methods(Static,Access=public)
        function h=instance()
            mlock;
            persistent singleton;
            if isempty(singleton)
                singleton=emlhdlcoder.WorkFlow.CodeGenInfoManager;
            end
            h=singleton;
        end
    end

    properties(Access=private)
        CgInfo;
    end

    methods(Access=private)
        function this=CodeGenInfoManager
            this.reset;
        end
    end


    methods
        function reset(this)
            this.CgInfo=struct;
        end

        function addField(this,prop,value)
            this.CgInfo.(prop)=value;
        end

        function r=getCgInfo(this)
            r=this.CgInfo;
        end

        function save(this,filepath)
            CodeGenInfo=this.CgInfo;%#ok<NASGU>
            save(filepath,'CodeGenInfo');
        end

    end
end

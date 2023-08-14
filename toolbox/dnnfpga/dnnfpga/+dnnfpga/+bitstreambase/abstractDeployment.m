classdef abstractDeployment



    properties(Access=protected)
m_deployableNetwork
m_platform
    end

    methods(Access=public,Hidden=true)
        function obj=abstractDeployment(deployableNetwork,platform)
            obj.m_deployableNetwork=deployableNetwork;
            obj.m_platform=platform;
        end
    end

    methods(Access=public)
        function dn=getDeployableNetwork(this)
            dn=this.m_deployableNetwork;
        end
    end

    methods(Access=public,Abstract=true)
        pass=check(this)
        init(this,args)
        output=predict(this,input)
    end

    methods(Access=protected,Abstract=true)
    end
end


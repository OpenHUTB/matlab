classdef BaseComponent<matlabshared.application.Component

    properties(Constant,Hidden)
        ResourceCatalog='fusion:trackingScenarioApp:Component:'
    end

    methods
        function this=BaseComponent(varargin)
            this@matlabshared.application.Component(varargin{:});
        end

        function name=getName(this)
            name=msgString(this,'');
        end

        function[str,id]=msgString(this,key,varargin)
            id=strcat(this.ResourceCatalog,getTag(this),key);
            str=getString(message(id,varargin{:}));
        end

        function[str,id]=errorString(this,key,varargin)

            id=strcat(this.ResourceCatalog,'Property',key);
            str=getString(message(id,varargin{:}));
        end

        function str=iconFile(~,filename)
            str=fullfile(matlabroot,'toolbox','fusion','fusion','+fusion','+internal','+scenarioApp','icons',...
            filename);
        end
    end

    methods
        function b=isIntrinsic(~)
            b=false;
        end
    end

    methods(Access=protected)
        function b=useAppContainer(this)
            b=useAppContainer(this.Application);
        end
    end
end

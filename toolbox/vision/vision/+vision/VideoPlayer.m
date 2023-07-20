classdef(StrictDefaults)VideoPlayer<matlabshared.scopes.UnifiedSystemScope

























































%#ok<*EMCLS>
%#ok<*EMCA>

    properties




        Name='Video Player';
    end

    properties(Dependent,Hidden)



        WindowCaption;
    end

    methods
        function obj=VideoPlayer(varargin)
            obj@matlabshared.scopes.UnifiedSystemScope();
            setProperties(obj,nargin,varargin{:});
        end

        function set.Name(this,value)
            setScopeName(this,value);
            this.Name=value;
        end

        function set.WindowCaption(this,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(this),'WindowCaption','Name'));

            this.Name=value;
        end

        function value=get.WindowCaption(this)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(this),'WindowCaption','Name'));

            value=this.Name;
        end

        function value=isOpen(this)
            value=isVisible(this);
        end

    end

    methods(Access=protected)
        function hScopeCfg=getScopeCfg(~)
            hScopeCfg=vipscopes.VideoPlayerScopeCfg;
        end

        function num=getNumInputsImpl(~)

            num=1;
        end

    end

    methods(Hidden)

        function hmply=getMPlayObj(this)
            hmply=getFramework(this);
        end
        function hsrc=getSourceObj(this)
            hsrc=getSource(this);
        end
    end

    methods(Sealed,Hidden)
        function close(this)




            warning(message('MATLAB:system:throwObsoleteMethodWarningNewName',...
            class(this),'close','release'));
            release(this);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsinks/Video Viewer';
        end
    end

end


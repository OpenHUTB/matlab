classdef CodePerspectiveConfig<handle


    properties(Constant)
        id='CodePerspective'
        title='Code Perspective'
        comp='GLUE2:DDG Component'
    end

    properties
studio
    end

    methods
        function obj=CodePerspectiveConfig(varargin)

            if nargin==1
                obj.studio=varargin{1};
            end
        end

        show(obj)
        showEmbedded(obj)
        schema=getDialogSchema(obj)
        schema=getTitleSchema(obj)
        schema=getMainSchema(obj)
        schema=getOptionSchema(obj)
        dialogCallback(obj,tag,value)
    end
end


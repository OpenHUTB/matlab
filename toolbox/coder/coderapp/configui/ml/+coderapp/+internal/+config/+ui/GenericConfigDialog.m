classdef(Sealed)GenericConfigDialog<coderapp.internal.config.ui.ConfigDialog






    properties(Constant)
        Factory=coder.internal.gui.Serviceable([],@coderapp.internal.config.ui.GenericConfigDialog)
    end

    properties(Dependent)
        Title{mustBeTextScalar(Title)}
    end

    methods
        function this=GenericConfigDialog(configOrSchema,varargin)
            this@coderapp.internal.config.ui.ConfigDialog(configOrSchema,varargin{:},...
            'Page','toolbox/coder/coderapp/configui/web/configdialog');
        end

        function set.Title(this,title)
            this.Controller.UiModel.Title=title;
        end

        function title=get.Title(this)
            title=this.Controller.UiModel.Title;
        end
    end
end



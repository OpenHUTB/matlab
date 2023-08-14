function out=ToolchainSettingsToggle(varargin)



    if isa(varargin{1},'DAStudio.Dialog')


        dlg=varargin{1};

        state=varargin{3};
        cs=dlg.getSource;
        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
        cs.getDialogController.showDetails=state;
        out=state;

    elseif ischar(varargin{1})&&strcmp(varargin{1},'web')

        cs=varargin{2};
        msg=varargin{3};
        state=msg.expand;
        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
        cs.getDialogController.showDetails=state;
        out=state;

    else

        cs=varargin{1};


        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
        out=cs.getDialogController.showDetails;
        return

    end

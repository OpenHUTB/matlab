function out=SolverToggleStatus(varargin)





    if isa(varargin{1},'DAStudio.Dialog')


        dlg=varargin{1};

        state=varargin{3};
        cs=dlg.getSource;
        if state
            cs.set_param('SolverInfoToggleStatus','on');
        else
            cs.set_param('SolverInfoToggleStatus','off');
        end
        out=state;

    elseif ischar(varargin{1})&&strcmp(varargin{1},'web')

        cs=varargin{2};
        msg=varargin{3};
        state=msg.expand;
        if isa(cs,'Simulink.ConfigSet')
            if state
                cs.set_param('SolverInfoToggleStatus','on');
            else
                cs.set_param('SolverInfoToggleStatus','off');
            end
        end
        out=state;
    else

        cs=varargin{1};


        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
        out=strcmp(cs.get_param('SolverInfoToggleStatus'),'on');
    end



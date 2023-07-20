function openCSAndHighlight(system,varargin)



    try
        model=get_param(bdroot(modeladvisorprivate('HTMLjsencode',system,'decode')),'handle');
    catch %#ok<CTCH>
        warndlg(DAStudio.message('ModelAdvisor:engine:ModelClosed'));
        return
    end

    try
        params=varargin{1};

        if params(1)=='{'&&params(end)=='}'
            params=eval(params);
        end

        if nargin>2
            view=varargin{2};
            configset.highlightParameter(model,params,'default',view);
        else
            configset.highlightParameter(model,params);
        end

    catch ME






        if strcmp(ME.identifier,'Simulink:dialog:NoSuchParameter')
            hwarn=warndlg(DAStudio.message('Simulink:dialog:NonUIParameter',varargin{1}));
            set(hwarn,'tag','Tag_Highlight_Warning');
            setappdata(hwarn,'warnId','Simulink:dialog:NonUIParameter');
        else
            rethrow(ME);
        end
    end

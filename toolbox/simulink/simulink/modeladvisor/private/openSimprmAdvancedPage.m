function openSimprmAdvancedPage(system,varargin)


    if nargin>1
        activePage='';
        for i=1:nargin-1
            activePage=[activePage,' ',varargin{i}];
        end
        activePage(1)='';
        if strcmp(activePage,'Data Import/Export')
            activePage='Data Import//Export';
        end
    else
        activePage='Hardware Implementation';
    end

    try
        model=get_param(bdroot(modeladvisorprivate('HTMLjsencode',system,'decode')),'handle');
    catch %#ok<CTCH>
        warndlg(DAStudio.message('ModelAdvisor:engine:ModelClosed'));
        return
    end
    slCfgPrmDlg(model,'Open');



    try
        slCfgPrmDlg(model,'TurnToPage',activePage);
    catch err
        if strcmp(err.identifier,'Simulink:dialog:PageNotValid')
            warndlg(DAStudio.message('ModelAdvisor:engine:ConfigSetParamLinkCallbackErrorMsg',activePage));
        else
            rethrow(err);
        end
    end
function utilPerformanceAdvisorStart(varargin)








    autoRestore=false;
    cleanup=false;
    if nargin==1&&isa(varargin{1},'DAStudio.CallbackInfo')
        switch varargin{1}.userdata
        case 'ToolbarMenuEntry'
            mdl_o=varargin{1}.model;
            scope_o=varargin{1}.uiObject;
        case 'ContextMenuEntry'
            scope_o=get_param(gcb,'object');
            mdl_o=get_param(bdroot(gcb),'Object');
        otherwise
            DAStudio.error('SimulinkPerformanceAdvisor:advisor:NotSupportedCaseA',...
            varargin{1}.userdata);
        end
    elseif nargin>=2&&strcmpi(varargin{2},'CommandLineEntry')
        scope_o=get_param(varargin{1},'object');
        if nargin==3&&strcmpi(varargin{3},'AutoRestore')
            autoRestore=true;
        end
    elseif nargin==2&&strcmpi(varargin{2},'Cleanup')
        cleanup=true;

        am=Advisor.Manager.getInstance;
        applicationObj=am.getApplication(...
        'advisor','com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor',...
        'Root',varargin{1},'Legacy',true,'MultiMode',false,...
        'token','MWAdvi3orAPICa11');

        if isobject(applicationObj)
            mdladvObj=applicationObj.getRootMAObj();
            utilCreatePerformanceProgress(mdladvObj,cleanup);
        end
        return;
    else
        DAStudio.error('SimulinkPerformanceAdvisor:advisor:NotSupportedCase');
    end



    mdlAdv=Simulink.ModelAdvisor.getModelAdvisor(scope_o.getFullName,'new','com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor');


    mdlAdv.ResetAfterAction=false;
    mdlAdv.ShowActionResultInRpt=true;


    utilCreatePerformanceProgress(mdlAdv,cleanup);


    mdlAdv.displayExplorer;

function[varargout]=modeladvisorutil(system,methods,varargin)






    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(modeladvisorprivate('HTMLjsencode',system,'decode'));
    if~isa(mdladvObj,'Simulink.ModelAdvisor')
        DAStudio.error('Simulink:tools:MAUnableLocateMAObj',system);
    end

    switch methods
    case 'pushResultToME'

        try
            showobjects=mdladvObj.CheckCellArray{str2double(varargin{1})}.Result{2}{str2double(varargin{2})};
            try
                if isnumeric(showobjects)
                    showobjects=num2cell(showobjects);
                end
                cacheObj=[];
                for i=1:length(showobjects)
                    cacheObj=[cacheObj,get_param(showobjects{i},'object')];
                end
                showobjects=cacheObj;
                if~isa(showobjects,'DAStudio.Object')&&~isa(showobjects,'Simulink.DABaseObject')
                    warndlg('WARNING: Unsupported object type. Can''t push them into Model Explorer.');
                    return
                end
            catch E
                disp(E.message);
                warndlg('WARNING: Unsupported object type. Can''t push them into Model Explorer.');
                return;
            end
        catch E
            warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
            return;
        end
        ListViewParameterStruct.Data=cacheObj;
        ListViewParameterStruct.Attributes=mdladvObj.CheckCellArray{str2double(varargin{1})}.PushToModelExplorerProperties;
        mdladvObj.displayListView(ListViewParameterStruct);
    otherwise
        DAStudio.error('Simulink:tools:MAUnknownMethod',methods);
    end



    function[name,value]=analyzeToken(token)
        [name,value]=strtok(token,'=');
        value=value(2:end);
        value=strrep(value,'+',' ');

function varargout=hconfigureJDBCDataSource(varargin)

















    narginchk(0,2);

    if nargin==1
        error(message('database:configureJDBCDataSource:InvalidNoOfArgs'))
    end

    if nargin==0


        h=findall(0,'Type','Figure','Tag','DataSourceConfigurationDialog');


        isStartUp=isempty(h)||~isa(h,'handle')||~isvalid(h);

        if isStartUp

            database.internal.utilities.repairOldJDBCDataSources;


            h=dbgui.internal.JDBCConfigurationDialog();


            setappdata(groot,'DataSourceConfigurationDialog',h);


            addlistener(h,'ObjectBeingDestroyed',@removeJDBCConfigurationDialogFromAppData);
        else
            figure(h);
        end
        varargout{1}={};
    else
        database.internal.utilities.repairOldJDBCDataSources;
        varargout{1}={database.options.JDBCConnectionOptions(varargin{:})};
    end

end


function removeJDBCConfigurationDialogFromAppData(~,~)
    if isappdata(groot,'DataSourceConfigurationDialog')
        rmappdata(groot,'DataSourceConfigurationDialog');
    end
end


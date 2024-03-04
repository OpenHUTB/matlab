classdef UiConfiguration
    methods(Static)

        function setLayoutConfigFile(project,configFile)
            if nargin<2
                error(message('dashboard:uidatamodel:AtLeastInput',2));
            end

            metric.dashboard.Verify.ScalarCharOrString(project);
            metric.dashboard.Verify.ScalarCharOrString(configFile);

            if isempty(char(configFile))
                configFile=fullfile(metric.dashboard.Configuration.DefaultConfigLocation,...
                metric.dashboard.Configuration.DefaultConfigFileName);
            else
                if exist(configFile,'file')~=2
                    error(message('dashboard:uidatamodel:ConfigNotExist',...
                    configFile));
                end
                [loc,name,ext]=fileparts(configFile);
                name=[name,ext];
                if isempty(loc)
                    loc=pwd;
                end
                cfg=metric.dashboard.Configuration.open(...
                'FileName',name,'Location',loc);
                cfg.verify();
                configFile=fullfile(loc,name);
            end

            config=dashboard.internal.UiConfiguration();
            config.setLayoutConfigFile(project,configFile,'DashboardApp');
        end

        function configFile=getLayoutConfigFile(project)
            if nargin<1
                error(message('dashboard:uidatamodel:AtLeastInput',1));
            end

            metric.dashboard.Verify.ScalarCharOrString(project);

            config=dashboard.internal.UiConfiguration();
            configFile=config.getLayoutConfigFile(project,'DashboardApp');
        end

    end
end

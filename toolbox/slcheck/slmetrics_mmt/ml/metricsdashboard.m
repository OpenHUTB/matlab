function metricsdashboard(varargin)


    warning(message('slcheck:metricengine:MetricsDashboardToBeRemoved'));

    if~matlab.internal.lang.capability.Capability.isSupported(matlab.internal.lang.capability.Capability.LocalClient)
        error(message('slcheck:metricengine:NotSupportedInOnline'));
    end

    if~license('checkout','SL_Verification_Validation')
        DAStudio.error('slcheck:metricengine:LicenseError');
    end

    ip=inputParser();
    ip.addRequired('System',@slmetric.internal.isCharOrString);
    ip.parse(varargin{:});

    if isstring(ip.Results.System)
        systemName=char(ip.Results.System);
    else
        systemName=ip.Results.System;
    end

    if strcmpi(systemName,'help')
        web(fullfile(docroot,'slvnv/ref/model-metric-checks.html'));
    else


        modelName=strtok(systemName,'/');

        if strcmp(modelName,systemName)
            type='Model';
        else
            type='SubSystem';
        end


        if bdIsLoaded(modelName)

            file=get_param(modelName,'FileName');


            if exist(file,'file')==0
                DAStudio.error('slcheck:mmt:UnsavedModel',modelName);
            end
        else
            file=sls_resolvename(modelName);
        end

        if isempty(file)
            if bdIsLoaded(modelName)
                DAStudio.error('slcheck:mmt:UnsavedModel',modelName);
            else
                DAStudio.error('slcheck:mmt:MetricsAPIModelNotExists',modelName);
            end
        else

            if~bdIsLoaded(modelName)
                load_system(modelName);
            end

            if strcmp(type,'SubSystem')

                try
                    sysObj=get_param(systemName,'Object');
                    isValid=Advisor.component.isValidAnalysisRoot(sysObj);
                catch E %#ok<NASGU>
                    isValid=false;
                end
            else
                isValid=true;
            end

            if isValid


                sessionID=slmetric.internal.getExistingSessionIDForDataSet(systemName,type);
                m=slmetric.internal.mmt.Manager.get();

                if isempty(sessionID)





                    if(m.checkExplorerBySystemAndType(systemName,type))
                        explorer=slmetric.Explorer;
                        explorer.open(systemName,type);
                    end
                else

                    explorer=m.getExplorerByID(sessionID);
                    explorer.bringToFront();
                end
            else
                DAStudio.error('slcheck:metricengine:InvalidMetricSystem',systemName);
            end
        end
    end
end
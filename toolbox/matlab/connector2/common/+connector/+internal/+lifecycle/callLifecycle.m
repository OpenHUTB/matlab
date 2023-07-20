function callLifecycle(lifecycleName,varargin)
    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::lifecycle');
    end

    persistent suppressedLifecycleEvents
    if isempty(suppressedLifecycleEvents)&&isnumeric(suppressedLifecycleEvents)
        suppressedLifecycleEvents=getenv('CONNECTOR_SUPPRESSED_LIFECYCLE_FUNCTIONS');
        if~isempty(suppressedLifecycleEvents)
            logger.event('Suppressed lifecycle functions: %s',suppressedLifecycleEvents);
            suppressedLifecycleEvents=strsplit(string(suppressedLifecycleEvents),',');
        else
            suppressedLifecycleEvents={};
        end
    end

    logger.event('Searching for %s lifecycle functions',lifecycleName);
    package=meta.package.fromName(['connector.internal.lifecycle.',lifecycleName]);

    if~isempty(package)
        functions=package.FunctionList;

        logger.event('Found %d functions for %s: ',numel(functions),lifecycleName);

        for i=1:numel(functions)
            func=functions(i);
            if any(contains(suppressedLifecycleEvents,func.Name))
                logger.event('Skipping suppressed function %d: %s',i,func.Name);
            else
                logger.event('Calling function %d: %s',i,func.Name);
                try
                    feval(['connector.internal.lifecycle.',lifecycleName,'.',func.Name],varargin{:});
                catch ex
                    report=getReport(ex);
                    logger.error('Error while calling function %s: %s',func.Name,report);
                end
            end
        end
    else
        logger.event('No lifecycle package found');
    end

    logger.event('Done calling %s lifecycle functions',lifecycleName);
end

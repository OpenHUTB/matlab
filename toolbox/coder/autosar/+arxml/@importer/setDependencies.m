function setDependencies(this,aDependencies)















    if iscellstr(aDependencies)||isStringScalar(aDependencies)||...
        ischar(aDependencies)||isstring(aDependencies)||isempty(aDependencies)

        p_setdependencies(this,aDependencies);

    else
        autosar.mm.util.MessageReporter.createWarning('RTW:autosar:badImporterDependencies');
    end

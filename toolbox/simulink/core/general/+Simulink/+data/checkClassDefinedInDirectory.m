function checkClassDefinedInDirectory(fullClassName,varargin)





    par=inputParser;
    par.addOptional('SuperClassName','',@ischar);
    par.parse(varargin{:});

    superClassName=par.Results.SuperClassName;


    hClass=meta.class.fromName(fullClassName);
    if(isempty(hClass.ContainingPackage)||...
        ~isempty(hClass.ContainingPackage.ContainingPackage))
        if isempty(superClassName)
            superClassName=l_findSuperclassToDisplay(hClass);
        end
        DAStudio.error('Simulink:Data:ClassMustBeInPackage',fullClassName,...
        superClassName);
    end


    [pkgName,clsName]=strtok(fullClassName,'.');
    clsName=clsName(2:end);
    actualPath=which(fullClassName);
    expectedPath=['+',pkgName,filesep,'@',clsName,filesep,clsName];
    startIdx=length(actualPath)-length(expectedPath)-1;
    if~isequal(actualPath(startIdx:end-2),expectedPath)
        if isempty(superClassName)
            superClassName=l_findSuperclassToDisplay(hClass);
        end
        DAStudio.error('Simulink:Data:ClassMustBeInClassDir',fullClassName,...
        superClassName);
    end
end




function superClassName=l_findSuperclassToDisplay(hClass)



    superClassName='';
    customBaseClass=?Simulink.data.HasPropertyType;

    for idx=1:length(hClass.SuperclassList)
        thisSuperclass=hClass.SuperclassList(idx);
        if(thisSuperclass==customBaseClass)
            superClassName=hClass.Name;
            return;
        else

            superClassName=l_findSuperclassToDisplay(thisSuperclass);
            if~isempty(superClassName)
                return;
            end
        end
    end
end



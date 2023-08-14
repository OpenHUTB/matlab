function blockTypes=getSupportedBlockTypes()



    packageName='slci.simulink';
    packageInfo=meta.package.fromName(packageName);
    classes=packageInfo.ClassList;
    packageNameLength=numel(packageName);

    blockTypes={};
    for i=1:numel(classes)
        class=classes(i).Name;
        if strcmpi(class(end-4:end),'Block')
            candidate=class(packageNameLength+2:end-5);
            if~isempty(candidate)
                if strcmpi(candidate,'Unsupported')

                elseif((slcifeature('CCallerSupport')==0)...
                    &&(strcmpi(candidate,'CCaller')))

                elseif strcmpi(candidate,'S_Function')
                    blockTypes{end+1}='S-Function';%#ok
                elseif strcmpi(candidate,'Lookup_n_D')
                    blockTypes{end+1}='Lookup_n-D';%#ok
                elseif strcmpi(candidate,'Interpolation_n_D')
                    blockTypes{end+1}='Interpolation_n-D';%#ok
                else
                    blockTypes{end+1}=candidate;%#ok
                end
            end
        end
    end


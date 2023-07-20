function loadComponent(obj,className,componentPath)





    dm=obj.MetaCS;
    if dm.ComponentMap.isKey(className)

        c=dm.ComponentMap(className);

        if strcmp(c.Type,'Custom')
            if isempty(componentPath)
                matFile=obj.getMatFile(className,'');
            else
                matFile=obj.getMatFile(className,fullfile(matlabroot,componentPath));
            end
            if exist(matFile,'file')
                tmp=load(matFile);
                obj.addComponentParameters(tmp.componentLayout);
            end
        end
    end
end



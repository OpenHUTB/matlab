function filenames=getEntityFileNames(this,p)




    names=p.getEntityNames;
    if isempty(names)
        filenames={};
        return;
    end

    suffix=p.getHDLFileExtension;

    if this.getParameter('isvhdl')
        package_required=this.getParameter('vhdl_package_required');
        package_name=[p.getTopNetwork.Name,this.getParameter('package_suffix')];




        if package_required&&~isempty(names{1})&&~strcmp(names{1},package_name)

            names=[{package_name},names(~strcmp(names,package_name))];
        elseif~package_required&&strcmp(names{1},package_name)
            names=names(2:end);
        end

        if this.getParameter('split_entity_arch')
            if package_required
                package_name=names{1};
                names=names(2:end);
                filenames={[package_name,suffix]};
            else
                filenames=[];
            end

            entity_names=strcat(names,...
            this.getParameter('split_entity_file_postfix'),...
            suffix);
            arch_names=strcat(names,...
            this.getParameter('split_arch_file_postfix'),...
            suffix);
            for n=1:length(names)
                filenames{end+1}=entity_names{n};%#ok  % there must be better way...
                filenames{end+1}=arch_names{n};%#ok
            end
        else
            filenames=strcat(names,suffix);
        end
    else
        filenames=strcat(names,suffix);
    end
end


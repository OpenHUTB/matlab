function displayNonScalarObject(obj)







    isFormatCompact=strcmp(get(0,'FormatSpacing'),'compact');



    fprintf('%s\n',getHeader(obj));



    displayProperties(obj);
    if isFormatCompact
        fprintf('\n');
    end



    fprintf('%s',getFooter(obj));
    if~isFormatCompact
        fprintf('\n');
    end

    function displayProperties(obj)

        groups=getPropertyGroups(obj);


        for i=1:length(groups)
            displayPropertyGroup(obj,groups(i));
        end

        function displayPropertyGroup(obj,group)

            fprintf('  %s\n',group.Title);


            for i=1:group.NumProperties
                propName=group.PropertyList{i};
                s.(propName)=obj.(propName);
            end
            disp(s);
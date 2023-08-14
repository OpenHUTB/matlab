function result=option(variable,value)





    persistent inheritedLibraryLinkOption
    if isempty(inheritedLibraryLinkOption)
        inheritedLibraryLinkOption=false;
    end


    if strcmp(variable,'inheritLibLinksOption')
        inheritedLibraryLinkOption=value;
        return;
    end



    prefix=length('filter');
    if strcmp(variable(1:prefix),'filter')
        filters=rmi.settings_mgr('get','filterSettings');
        switch variable
        case 'filters'
            result=filters.enabled;
        case 'filterin'
            result=filter_cell2string(filters.tagsRequire);
        case 'filterout'
            result=filter_cell2string(filters.tagsExclude);
        otherwise
            error(message('Slvnv:RptgenRMI:option:UnsupportedVariable',variable));
        end

    else
        settings=rmi.settings_mgr('get','reportSettings');

        if isfield(settings,variable)

            result=settings.(variable);

            if islogical(result)
                if nargin>1&&logical(value)~=result&&...
                    any(strcmp(variable,{'toolsReqReport','followLibraryLinks'}))

                    settings.(variable)=logical(value);
                    rmi.settings_mgr('set','reportSettings',settings);

                elseif nargin==1&&~result&&strcmp(variable,'followLibraryLinks')


                    result=inheritedLibraryLinkOption;
                end
            end
        else

            switch variable
            case 'highlight'
                result=settings.highlightModel;
            case 'missingReqs'
                result=settings.includeMissingReqs;
            case 'docIndex'
                result=settings.useDocIndex;
            case 'followLibraryLinks'



                result=false;
            otherwise
                error(message('Slvnv:RptgenRMI:option:UnsupportedVariable',variable));
            end
        end
    end

    function result=filter_cell2string(cell_array)
        if isempty(cell_array)
            result='<No tags entered>';
        else
            string='';
            for i=1:length(cell_array)
                string=[string,', ',cell_array{i}];%#ok
            end
            result=string(2:end);
        end

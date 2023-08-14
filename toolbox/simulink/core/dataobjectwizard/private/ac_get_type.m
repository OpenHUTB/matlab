function strMatch=ac_get_type(typeName,referenceType,desiredType,option)


























    userTypes=cusattic('AtticData','userTypes');

    strMatch='';

    try
        switch(referenceType)
        case{'userName','tmwName'}
        otherwise
            disp('ac_get_type invalid referenceType name');
            return;
        end

        switch(desiredType)
        case{'userName','tmwName'}
        otherwise
            disp('ac_get_type invalid desiredType name');
            return;
        end

        switch(option)
        case 'all'
            for i=1:length(userTypes)
                name=getfield(userTypes{i},referenceType);
                if strcmp(name,typeName)==1
                    strMatch{end+1}=getfield(userTypes{i},desiredType);
                end
            end
        case 'depend'
            for i=1:length(userTypes)
                name=getfield(userTypes{i},referenceType);
                if strcmp(name,typeName)==1
                    strMatch=getfield(userTypes{i},'userTypeDepend');
                    break;
                end
            end
        otherwise
        end
    catch merr
        strMatch='';
        warning(merr.message);
    end

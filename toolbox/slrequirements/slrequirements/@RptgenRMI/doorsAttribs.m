function result=doorsAttribs(action,arg)



































































    if nargin>0
        action=convertStringsToChars(action);
    end

    reportSettings=rmi.settings_mgr('get','reportSettings');
    doorsDetails=reportSettings.detailsDoors;

    if strcmpi(action,'show')
        result=doorsDetails';

    elseif strcmpi(action,'default')
        defaultSettings=rmi.settings_mgr('default','reportSettings');
        if(numel(reportSettings.detailsDoors)==numel(defaultSettings.detailsDoors))&&...
            all(strcmp(reportSettings.detailsDoors,defaultSettings.detailsDoors))
            result=false;
        else
            reportSettings.detailsDoors=defaultSettings.detailsDoors;
            rmi.settings_mgr('set','reportSettings',reportSettings);
            result=true;
        end

    elseif nargin<2
        error(message('Slvnv:RptgenRMI:doorsAttribs:invalidUsage',action));

    else
        modified=false;
        switch lower(action)
        case 'type'
            type=arg;
            isAll=strcmp(doorsDetails,'$AllAttributes$');
            isUser=strcmp(doorsDetails,'$UserAttributes$');
            if strcmpi(type,'all')
                if any(isUser)
                    doorsDetails(isUser)=[];
                    modified=true;
                end
                if~any(isAll)
                    doorsDetails=[doorsDetails,{'$AllAttributes$'}];
                    modified=true;
                end
                if modified
                    disp('Including all attributes...');
                end
            elseif strcmpi(type,'user')
                if any(isAll)
                    doorsDetails(isAll)=[];
                    modified=true;
                end
                if~any(isUser)
                    doorsDetails=[doorsDetails,{'$UserAttributes$'}];
                    modified=true;
                end
                if modified
                    disp('Including user attributes...');
                end
            elseif strcmpi(type,'none')
                if any(isUser)
                    doorsDetails(isUser)=[];
                    modified=true;
                end
                if any(isAll)
                    doorsDetails(isAll)=[];
                    modified=true;
                end
                if modified
                    disp('Excluding attributes...');
                end
            else
                error(message('Slvnv:RptgenRMI:doorsAttribs:invalidType',type));
            end
        case 'add'
            if strcmpi(arg,'Object Heading')
                if~any(strcmp(doorsDetails,'Object Heading'))
                    doorsDetails=[doorsDetails,{'Object Heading'}];
                    modified=true;
                end
            elseif strcmpi(arg,'Object Text')
                if~any(strcmp(doorsDetails,'Object Text'))
                    doorsDetails=[doorsDetails,{'Object Text'}];
                    modified=true;
                end
            else
                change=['+',arg];
                isAdd=strncmp(doorsDetails,'+',1);
                addedItems=doorsDetails(isAdd);
                if~any(strcmp(addedItems,change))
                    doorsDetails=[doorsDetails,{change}];
                    modified=true;
                    doorsDetails(strcmp(doorsDetails,['-',arg]))=[];
                end
            end
            if modified
                disp(['Adding ',arg,'...']);
            end
        case 'remove'
            if strcmpi(arg,'Object Heading')
                isHeading=strcmp(doorsDetails,'Object Heading');
                if any(isHeading)
                    doorsDetails(isHeading)=[];
                    modified=true;
                end
            elseif strcmpi(arg,'Object Text')
                isText=strcmp(doorsDetails,'Object Text');
                if any(isText)
                    doorsDetails(isText)=[];
                    modified=true;
                end
            else
                change=['-',arg];
                isSkip=strncmp(doorsDetails,'-',1);
                skippedItems=doorsDetails(isSkip);
                if~any(strcmp(skippedItems,change))
                    doorsDetails=[doorsDetails,{change}];
                    modified=true;
                    doorsDetails(strcmp(doorsDetails,['+',arg]))=[];
                end
            end
            if modified
                disp(['Removing ',arg,'...']);
            end
        case 'nonempty'
            if(islogical(arg)&&arg)||strcmpi(arg,'on')
                if~any(strcmp(doorsDetails,'$NonEmpty$'))
                    doorsDetails=[doorsDetails,{'$NonEmpty$'}];
                    modified=true;
                end
            elseif(islogical(arg)&&~arg)||strcmpi(arg,'off')
                isNonEmpty=strcmp(doorsDetails,'$NonEmpty$');
                if any(isNonEmpty)
                    doorsDetails(isNonEmpty)=[];
                    modified=true;
                end
            else
                error(message('Slvnv:RptgenRMI:doorsAttribs:invalidArg',arg,action));
            end
            if modified
                disp(['NonEmpty filter ',arg,'...']);
            end
        otherwise
            error(message('Slvnv:RptgenRMI:doorsAttribs:invalidAction',action));
        end

        if modified
            reportSettings.detailsDoors=doorsDetails;
            rmi.settings_mgr('set','reportSettings',reportSettings);
        end
        result=modified;
    end
end

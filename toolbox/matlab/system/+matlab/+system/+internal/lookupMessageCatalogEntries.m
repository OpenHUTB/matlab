function values=lookupMessageCatalogEntries(messageIDs,forceUS,catalog)
    values=initializeOutputType(messageIDs,catalog);

    if forceUS
        locale=matlab.internal.i18n.locale('en_US');
    else
        locale=matlab.internal.i18n.locale.default();
    end
    for n=1:numel(messageIDs)
        values{n}=lookupMessageCatalogIdentifier(messageIDs{n},locale,catalog);
    end
end

function values=initializeOutputType(messageIDs,catalog)
    if isstring(messageIDs)
        values=strings(numel(messageIDs),1);
    elseif iscellstr(messageIDs)
        values=cell(numel(messageIDs),1);
    else
        matlab.system.internal.error(['MATLAB:system:',catalog,':InvalidMessageIdentifiers'])
    end
end

function value=lookupMessageCatalogIdentifier(messageID,locale,catalog)
    try
        value=getString(message(messageID),locale);
    catch me
        switch me.identifier
        case 'MATLAB:builtins:IncorrectHoleCount'
            throwError('InvalidMessageWithHoles',messageID,catalog);
        case{'MATLAB:builtins:MessageNotFound','MATLAB:builtins:InvalidMessageID'}
            throwError('InvalidMessageCatalogIdentifer',messageID,catalog);
        otherwise
            rethrow(me);
        end
    end
end

function throwError(errorID,messageID,catalog)
    matlab.system.internal.error(['MATLAB:system:',catalog,':',errorID],char(messageID));
end

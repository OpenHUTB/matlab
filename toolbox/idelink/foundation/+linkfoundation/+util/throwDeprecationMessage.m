function varargout=throwDeprecationMessage(msgid,adaptorName)

    if isempty(adaptorName)
        varargout{1}=message('ERRORHANDLER:pjtgenerator:AdaptorNameNone');
        return;
    end
    [allDeprecated,allDepTags]=loc_getDeprecatedAdaptorNames();
    varargout{1}='';
    varargout{2}=allDeprecated;
    varargout{3}=allDepTags;


    switch(lower(msgid))
    case lower('AdaptorNotInstalled')
        if ismember(adaptorName,allDeprecated)
            varargout{1}=message('ERRORHANDLER:pjtgenerator:AdaptorDeprecated',adaptorName,adaptorName);
        else
            varargout{1}=message('ERRORHANDLER:pjtgenerator:AdaptorNotInstalled',adaptorName,adaptorName,adaptorName);
        end
    case lower('AdaptorNotInstalledCopy')
        if ismember(adaptorName,allDeprecated)
            varargout{1}=message('ERRORHANDLER:pjtgenerator:AdaptorDeprecated',adaptorName,adaptorName);
        else
            varargout{1}=message('ERRORHANDLER:pjtgenerator:AdaptorNotInstalled',adaptorName,adaptorName,adaptorName);
        end
    end
end


function varargout=loc_getDeprecatedAdaptorNames(varargin)



    varargout{1}={'Green Hills MULTI','Eclipse','Wind River Diab/GCC (makefile generation only)'};
    varargout{2}={'multilinktgtpref','eclipseidetgtpref','wrworkbenchtgtpref'};
end



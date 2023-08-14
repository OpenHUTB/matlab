function out=covariatehandler(action,varargin)











    out={action};

    switch action
    case 'parseCovariateExpression'
        out=parseCovariateExpression(action,varargin{:});
    end

end

function out=parseCovariateExpression(action,input)

    expression=input.expression;
    msg='';
    parsedModel=[];


    oldWarningState=warning('off');
    warningStateCleanup=onCleanup(@()warning(oldWarningState));

    try
        parsedModel=sbiogate('parseCovariateModel',{expression});
        parsedModel=struct(parsedModel);
    catch ex
        msg=SimBiology.web.internal.errortranslator(ex);
    end

    info.message=msg;
    info.parsedModel=parsedModel;
    info.rowID=input.rowID;

    out={action,info};

end

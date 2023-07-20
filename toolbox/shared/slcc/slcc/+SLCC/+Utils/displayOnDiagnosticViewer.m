function displayOnDiagnosticViewer(modelName,type,mSLException)

    slccStage=Simulink.output.Stage('Simulink','ModelName',modelName,'UIMode',true);%#ok<NASGU>

    SLOutputArgs={'Component','Simulink','Category','Custom Code'};
    switch(lower(type))
    case 'error'
        Simulink.output.error(mSLException,SLOutputArgs{:});
    case 'warning'
        mSLException=MSLException(mSLException,'COMPONENT','Simulink','CATEGORY','Custom Code');
        MSLDiagnostic(mSLException).reportAsWarning;
    case 'message'
        Simulink.output.info(mSLException,SLOutputArgs{:});
    otherwise

    end


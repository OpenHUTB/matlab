function resolvedSymbol=ec_mp_tool_version




    topComm1='/*======================== TOOL VERSION INFORMATION ==========================*';
    botComm1=' *============================================================================*/';
    topComm2='/*======================= LICENSE IN USE INFORMATION =========================*';
    botComm2=' *============================================================================*/';

    featureList={'matlab'
'simulink'
'simulinkcoder'
'embeddedcoder'
'stateflow'
    'fixedpoint'};



    hcustom=sldowprivate('cusattic','AtticData','miscCustomizations');
    if~isempty(hcustom)&&~isempty(hcustom.MPFToolVersion)
        try
            resolvedSymbol=eval(hcustom.MPFToolVersion);
            if ischar(resolvedSymbol)
                return
            else
                MSLDiagnostic('RTW:mpt:ToolVersionWarn').reportAsWarning;
            end
        catch merr


            warning(merr.identifier,merr.message);
        end
    end



    resolvedSymbol=[topComm1,newline];


    vLineAccum=[];
    for i=1:length(featureList)
        verStruct=coder.make.internal.cachedVer(featureList{i});
        if~isempty(verStruct)
            vLine=sprintf('%s %s %s',verStruct.Name,verStruct.Version,verStruct.Release,verStruct.Date);
            vLineAccum=[vLineAccum,' * ',vLine,blanks(75-length(vLine)),'*',newline];
        end
    end

    resolvedSymbol=[resolvedSymbol,vLineAccum,botComm1];


    inUse=license('inuse');
    resolvedSymbol=[resolvedSymbol,newline,newline,topComm2,newline];


    vLineAccum=[];
    for i=1:length(inUse)
        vLine=sprintf('%s %s %s',inUse(i).feature);
        vLineAccum=[vLineAccum,' * ',vLine,blanks(75-length(vLine)),'*',newline];
    end

    resolvedSymbol=[resolvedSymbol,vLineAccum,botComm2];


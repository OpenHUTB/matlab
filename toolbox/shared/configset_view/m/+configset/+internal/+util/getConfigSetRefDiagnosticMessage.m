function out=getConfigSetRefDiagnosticMessage(diag,html)




    if isempty(diag)
        out='';
        return
    end

    switch diag.identifier
    case 'Simulink:ConfigSet:ConfigSetRef_SourceNameUnset'
        id='Simulink:ConfigSet:ConfigSetRef_SourceNameUnspecified';
        suggestions={id};
    case 'Simulink:ConfigSet:ConfigSetRef_SourceNameNotInBaseWorkspace'
        id='Simulink:ConfigSet:ConfigSetRef_SourceNameNotFound';
        suggestions={
        'Simulink:ConfigSet:ConfigSetRef_SourceNameUnspecified',...
'Simulink:ConfigSet:ConfigSetRef_LoadMATFile'
        };
    case 'Simulink:ConfigSet:ConfigSetRef_NotFoundInDataDictionary'
        id='Simulink:ConfigSet:ConfigSetRef_SourceNameNotFound';
        suggestions={
        'Simulink:ConfigSet:ConfigSetRef_SourceNameUnspecified'};
    case{'Simulink:ConfigSet:ConfigSetRef_SourceObjectNotAConfigSet'
'Simulink:ConfigSet:ConfigSetRef_ExtraIndirectionInBaseWorkspace'
        'Simulink:ConfigSet:ConfigSetRef_ExtraIndirectionInDataDictionary'}
        id='Simulink:ConfigSet:ConfigSetRef_SourceNameInvalid';
        suggestions={};
    otherwise
        id='';
        suggestions={};
    end

    if html==true
        if~isempty(suggestions)
            suggestions=['<ul>',cell2mat(cellfun(@(x)sprintf('<li>%s.</li>',getString(message(x))),...
            suggestions,'UniformOutput',false)),'</ul>'];
        else
            suggestions='';
        end
        iconPath='csview/images/warning.png';
        out=[...
'<html><head><style>'...
        ,'body {background-color: rgb(250,250,250); color: rgb(64,64,64); }'...
        ,'</style></head>'...
        ,'<div>&nbsp;</div>'...
        ,'<div style="margin: auto;">'...
        ,'<div><img src="',iconPath,'"/></div>'...
        ,'<h1>',getString(message('Simulink:ConfigSet:ConfigSetRef_SourceNameNotFound')),'</h1>'...
        ,'<p id="message">',diag.message,'</p>'...
        ,'<div id="suggestions">',suggestions,'</div>'...
        ,'</div></body></html>'];
    else
        if id==""
            out=diag.message;
        else
            out=getString(message(id));
        end
    end



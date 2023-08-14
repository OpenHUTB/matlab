function out=resolveFunctionNameToken(obj,token)




    if strcmp(token,'$M')

        previewStr=obj.MangledToken;
    else
        identifierResolver=coder.preview.internal.IdentifierResolver(...
        'R',obj.ModelName,'N',obj.FunctionName,'U',obj.CustomToken);
        previewStr=identifierResolver.getIdentifier(token);
    end
    tooltipStr=[message('SimulinkCoderApp:sdp:FunctionFunctionNamingRuleLabel').getString,': ',token];
    classStr='tk';
    property='FUNCTIONNAME';
    out=obj.getPropertyPreview(tooltipStr,classStr,property,previewStr);



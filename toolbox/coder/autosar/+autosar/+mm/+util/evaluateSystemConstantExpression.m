function value=evaluateSystemConstantExpression(model,m3iCondAccess)




    autosar.mm.util.validateM3iArg(m3iCondAccess,...
    'Simulink.metamodel.arplatform.variant.ConditionByFormula');

    expression=m3iCondAccess.Body;
    expression=regexprep(expression,'&amp;','&');
    expression=regexprep(expression,'&lt;','<');
    expression=regexprep(expression,'&gt;','>');


    for ii=1:m3iCondAccess.SysConst.size()
        sysConst=m3iCondAccess.SysConst.at(ii);
        qName=autosar.api.Utils.getQualifiedName(sysConst);
        expression=regexprep(expression,['<SYSC-REF DEST="SW-SYSTEMCONST">',qName,'</SYSC-REF>'],...
        [sysConst.Name,'.Value']);
    end

    try
        value=evalinGlobalScope(model,expression);
    catch err
        DAStudio.error('autosarstandard:common:ErrorEvaluatingConditionExpression',...
        expression,...
        autosar.api.Utils.getQualifiedName(m3iCondAccess),...
        err.message);
    end
end


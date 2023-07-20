function condExpr=extractCondExpressionFromM3iCondAccess(m3iCondAccess)




    autosar.mm.util.validateM3iArg(m3iCondAccess,...
    'Simulink.metamodel.arplatform.variant.ConditionByFormula');

    condExpr=m3iCondAccess.Body;
    condExpr=regexprep(condExpr,'&amp;','&');
    condExpr=regexprep(condExpr,'&lt;','<');
    condExpr=regexprep(condExpr,'&gt;','>');


    for ii=1:m3iCondAccess.SysConst.size()
        sysConst=m3iCondAccess.SysConst.at(ii);
        qName=autosar.api.Utils.getQualifiedName(sysConst);
        condExpr=regexprep(condExpr,['<SYSC-REF DEST="SW-SYSTEMCONST">',qName,'</SYSC-REF>'],...
        sysConst.Name);
    end
end


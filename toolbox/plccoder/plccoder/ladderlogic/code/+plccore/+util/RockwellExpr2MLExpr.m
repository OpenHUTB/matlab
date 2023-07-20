function[globalsList,script]=RockwellExpr2MLExpr(expr,isRHS)




    expr=strrep(expr,'[','(');
    expr=strrep(expr,']',')');




    expr=regexprep(expr,'[a-zA-Z].*\.(\d+)$','${plccore.util.replaceBitIndexWithBITTxt($0)}');

    out=plccore.util.mtreeGenerateMLOperand(expr);
    out2=plccore.util.mtreeUpdateIntegerBitAccessRead(out.MFBScript,isRHS);



    globalsList=out.globalsList;
    script=out2.MFBScript;

end


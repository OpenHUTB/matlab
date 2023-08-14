function datadict_varview(filename,varname,entrykey)






    realFilename=urldecode(filename);
    blankentry='';

    vs1Str=['slddEvalDataSrc(''',realFilename,''', ''',entrykey,''')'];
    vs2Str=['slddEvalDataSrc(''',realFilename,''', ''',blankentry,''')'];

    vs1=comparisons.internal.var.makeVariableSource(varname,vs1Str);
    vs2=comparisons.internal.var.makeVariableSource(varname,vs2Str);

    comparisons.internal.var.startComparison(vs1,vs2)






end

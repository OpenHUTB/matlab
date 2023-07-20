function datadict_varcompare(leftfilename,rightfilename,leftvarname,rightvarname,leftentrykey,rightentrykey)






    realLeftFilename=urldecode(leftfilename);
    realRightFilename=urldecode(rightfilename);

    vs1Str=['slddEvalDataSrc(''',realLeftFilename,''', ''',leftentrykey,''')'];
    vs2Str=['slddEvalDataSrc(''',realRightFilename,''', ''',rightentrykey,''')'];

    vs1=comparisons.internal.var.makeVariableSource(leftvarname,vs1Str);
    vs2=comparisons.internal.var.makeVariableSource(rightvarname,vs2Str);

    comparisons.internal.var.startComparison(vs1,vs2)

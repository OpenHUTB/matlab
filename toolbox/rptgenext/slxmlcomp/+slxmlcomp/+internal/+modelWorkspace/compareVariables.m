function compareVariables(fileName1,fileName2,varName1,varName2)




    refName1=comparisons.internal.loadVariable(fileName1,varName1,'_left');
    refName2=comparisons.internal.loadVariable(fileName2,varName2,'_right');
    [~,f1]=fileparts(fileName1);
    [~,f2]=fileparts(fileName2);
    if~strcmp(f1,f2)
        sourcename1=[f1,'.',varName1];
        sourcename2=[f2,'.',varName2];
    else
        sourcename1=[f1,'_left.',varName1];
        sourcename2=[f2,'_right.',varName2];
    end
    vs1=com.mathworks.comparisons.source.impl.VariableSource(sourcename1,...
    ['evalin(''base'',''',refName1,''')'],...
    ['comparisons_private(''varcleanup'',''',refName1,''')']);
    vs2=com.mathworks.comparisons.source.impl.VariableSource(sourcename2,...
    ['evalin(''base'',''',refName2,''')'],...
    ['comparisons_private(''varcleanup'',''',refName2,''')']);
    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(vs1,vs2,true)
end

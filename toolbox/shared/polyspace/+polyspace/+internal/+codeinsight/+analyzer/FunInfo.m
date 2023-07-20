

classdef FunInfo<handle

    properties
        Name(1,1)string
        IsDefined(1,1)logical=true
        GlobalRead polyspace.internal.codeinsight.analyzer.VarInfo
        GlobalWrite polyspace.internal.codeinsight.analyzer.VarInfo
        Callee polyspace.internal.codeinsight.analyzer.FunInfo
        ModifiedArgs string
    end

end
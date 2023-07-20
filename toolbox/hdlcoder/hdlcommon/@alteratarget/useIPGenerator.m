


function useIPG=useIPGenerator()
    preferred=hdlgetparameter('useAlteraIPGenerate');
    isNewFamily=alteratarget.isFamilyArria10OrLater(hdlgetparameter('synthesisToolChipFamily'));
    isVerilog=strcmpi(hdlgetparameter('target_language'),'verilog');

    if(isNewFamily)
        assert(isVerilog==false);
        useIPG=true;
    else
        useIPG=~isVerilog&&preferred;
    end
end
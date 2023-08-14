function out=getCodeGenRptFileName(h)




    if~isempty(h.TmpModel)

        model=h.TmpModel;
    else
        model=h.Model;
    end
    out=[model,'_codegen_rpt.html'];

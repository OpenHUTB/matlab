function hf=updateStateInfo(this,hf,hC,arith)






    if isFilterFIRt(hf)

        if~strcmpi(arith,'double')
            hf.statesltype=hf.Accumsltype;

        else
            hf.statesltype=hf.inputsltype;
        end
    end



    function isFIRt=isFilterFIRt(hf)
        isFIRt=isa(hf,'hdlfilter.dffirt');


function result=showState(~,blkObj)




    result=false;
    if strcmpi(blkObj.TypePopup,'FIR (all zeros)')
        if contains(blkObj.FIRFiltStruct,'transposed')||strcmpi(blkObj.FIRFiltStruct,'Lattice MA')
            result=true;
        end
    elseif strcmpi(blkObj.TypePopup,'IIR (all poles)')
        if~strcmpi(blkObj.AllPoleFiltStruct,'Direct form')
            result=true;
        end
    elseif strcmpi(blkObj.TypePopup,'IIR (poles & zeros)')

        if contains(blkObj.IIRFiltStruct,'II')||contains(blkObj.IIRFiltStruct,'transposed')
            result=true;
        end
    end
end



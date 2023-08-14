
function slciLibName=getSLCILibName()
    if ispc
        slciLibName='slci_engine';
    else
        slciLibName='libmwslci_engine';
    end
end

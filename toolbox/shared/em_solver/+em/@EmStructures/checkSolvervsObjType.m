function checkSolvervsObjType(obj,propVal)



    switch propVal
    case 'MOM-PO'
        if~isMoMPOSupported(obj)
            error(message('antenna:antennaerrors:Unsupported',...
            'MoM-PO as solver',class(obj)));
        end

    case 'PO'

    end

end
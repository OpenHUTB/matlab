
function v=validateBlock(~,hC)
    hCRn=hC.ReferenceNetwork;
    v=hdlvalidatestruct;
    for ii=1:length(hCRn.PirInputSignals)
        if hdlsignaliscomplex(hC.ReferenceNetwork.PirInputSignals(ii))
            errorStatus=1;
            v=hdlvalidatestruct(errorStatus,...
            message('hdlcoder:validate:UnsupportedDataTypeComplexOnInport'));
            break;
        end
    end
end

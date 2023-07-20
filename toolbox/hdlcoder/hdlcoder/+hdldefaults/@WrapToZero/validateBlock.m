
function v=validateBlock(~,hC)
    bfp=hC.SimulinkHandle;
    v=hdlvalidatestruct;
    thresh=get_param(bfp,'Threshold');

    if(numel(str2num(thresh))>1)%#ok<ST2NM>
        hCRn=hC.ReferenceNetwork;
        vecc=hdlsignalvector(hCRn.PirInputSignals(1));
        if~isequal(vecc,numel(str2num(thresh)))%#ok<ST2NM>
            errorStatus=1;
            v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:inputthresholdmismatch'));
        end
    end
end

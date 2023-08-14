function castSection=elabcastout(~,hTopN,blockInfo,slRate,gcOut_re,gcOut_im,dataOut_re,dataOut_im)




    in1=gcOut_re;
    in2=gcOut_im;

    out1=dataOut_re;
    out2=dataOut_im;


    castSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','castSection',...
    'InportNames',{'gcOut_re','gcOut_im'},...
    'InportTypes',[in1.Type,in2.Type],...
    'Inportrates',[slRate,slRate],...
    'OutportNames',{'dataOut_re','dataOut_im'},...
    'OutportTypes',[out1.Type,out2.Type]...
    );


    gcOut_re=castSection.PirInputSignals(1);
    gcOut_im=castSection.PirInputSignals(2);

    dataOut_re=castSection.PirOutputSignals(1);
    dataOut_im=castSection.PirOutputSignals(2);

    if blockInfo.GainCorrection
        pirelab.getDTCComp(castSection,gcOut_re,dataOut_re,'Nearest','Saturate');
        pirelab.getDTCComp(castSection,gcOut_im,dataOut_im,'Nearest','Saturate');
    else
        if strcmp(blockInfo.OutputDataType,'Same word length as input')
            pirelab.getDTCComp(castSection,gcOut_re,dataOut_re,'Nearest','Saturate');
            pirelab.getDTCComp(castSection,gcOut_im,dataOut_im,'Nearest','Saturate');
        else
            pirelab.getDTCComp(castSection,gcOut_re,dataOut_re,'Floor','Wrap');
            pirelab.getDTCComp(castSection,gcOut_im,dataOut_im,'Floor','Wrap');
        end
    end
end

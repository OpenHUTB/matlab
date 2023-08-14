function cgirComp=getBitExtractComp(hN,hInSignals,hOutSignals,...
    upperlimit,lowerlimit,treatbitsAsInt,compName)

    if(nargin<7)
        compName='extract';
    end

    treatBoolAsUfix1=true;
    treatIntsAsFixpt=true;

    outTpEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);

    bmp={upperlimit+1,lowerlimit+1,treatbitsAsInt,outTpEx};
    ipf='hdleml_extractbits_vector';

    numInports=length(hInSignals);


    if numInports==1

        hCInSignal=hInSignals(1);
        hCOutSignal=hOutSignals(1);

        cgirComp=getCgirComp(hN,hCInSignal,hCOutSignal,compName,ipf,bmp);


    elseif numInports==2

        hCInSignal=hInSignals;
        hCOutSignal=hOutSignals(1);

        cgirComp=getCgirComp(hN,hCInSignal,hCOutSignal,compName,ipf,bmp);


    else
        dimLen=pirelab.getVectorTypeInfo(hInSignals(1));
        hCOutSignal=hOutSignals(1);


        if dimLen==1
            opInSignals=hInSignals;


        else
            for ii=1:numInports

                demuxComp=pirelab.getDemuxCompOnInput(hN,hC.SLInputSignals(ii));
                hDemuxOutSignals{ii}=demuxComp.PirOutputSignals;
            end


            for ii=1:dimLen
                for jj=1:numInports
                    opInSignals(jj+(ii-1)*numInports)=hDemuxOutSignals{jj}(ii);%#ok<AGROW>
                end
            end
        end

        cgirComp=getCgirComp(hN,opInSignals,hCOutSignal,compName,ipf,bmp);
    end



    cgirComp.paramsFollowInputs(false);


    cgirComp.treatInputIntsAsFixpt(treatIntsAsFixpt);


    cgirComp.treatInputBoolsAsUfix1(treatBoolAsUfix1);

end

function cgirComp=getCgirComp(hN,hInSignals,hOutSignals,name,ipf,bmp)



    slHandle=-1;

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'Name',name,...
    'SimulinkHandle',slHandle);


    cgirComp.IpFileName=ipf;
    cgirComp.ParamInfo=bmp;

end


function cgirComp=getBitConcatComp(hN,hInSignals,hOutSignals,compName)










    if(nargin<4)
        compName='concat';
    end

    numInports=length(hInSignals);


    if numInports<=2

        ipf='hdleml_bitconcat';
        bmp={};


    else
        dimLen=hInSignals(1).Type.getDimensions;


        if dimLen==1
            ipf='hdleml_bitconcat';
            bmp={};


        else
            outTpEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);
            ipf='hdleml_bitconcat_vec';
            bmp={outTpEx,numInports};

            for ii=1:numInports

                hDeMuxInSignal=hInSignals(ii);
                inName=hDeMuxInSignal.Name;
                if~isempty(inName)
                    demuxName=inName;
                else
                    demuxName='vs';
                end
                [numDemuxOut,hBT]=pirelab.getVectorTypeInfo(hDeMuxInSignal);
                for jj=1:numDemuxOut
                    newSignal=hN.addSignal(hBT,sprintf('%s_%d',demuxName,jj-1));
                    hDeMuxOutSignals(jj)=newSignal;%#ok<AGROW>
                end
                pirelab.getDemuxComp(hN,hDeMuxInSignal,hDeMuxOutSignals,'demux');

                hDemuxOut{ii}=hDeMuxOutSignals;%#ok<AGROW>
            end


            for ii=1:dimLen
                for jj=1:numInports
                    opInSignals(jj+(ii-1)*numInports)=hDemuxOut{jj}(ii);%#ok<AGROW>
                end
            end
            hInSignals=opInSignals;
        end
    end

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end


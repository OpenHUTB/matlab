function[hMFcn,hdataTypeConversionBlk,latency]=utilAddUpdateSubsystem(parent,mfcn,position,dataType,sampleTime,latencyStrategy,globalInfo)





    numStates=globalInfo.numStates;
    numInputs=globalInfo.numInputs;
    numModes=globalInfo.totalModes;
    numQs=globalInfo.numQs;
    numCIs=globalInfo.numCIs;


    if numInputs<1
        numInputs=1;
    end
    if(numCIs<1)
        numCIs=1;
    end
    if(numModes<1)
        numModes=1;
    end
    argDims={[numStates,1],...
    [numInputs,1],...
    [1,1],...
    [numModes,1],...
    [1,numQs],...
    [1,numCIs]};

    [hMFcn,mfcnInfo]=utilAddML2SLSubsystem(parent,mfcn,...
    position,dataType,argDims,sampleTime,latencyStrategy,numQs>0);

    latency=mfcnInfo.mlfbBlkLatency;







    logic=Simulink.findBlocksOfType(hMFcn,'Logic');

    for(block=logic')

        lines=get_param(block,'LineHandles');

        portInd=0;
        for line=lines.Inport

            portInd=portInd+1;
            sourceB=get_param(line,'SrcBlockHandle');
            destB=get_param(line,'DstBlockHandle');

            if(strcmp(get_param(sourceB,'BlockType'),'Selector'))
                DTC=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(gcs,'/Data Type Conversion'),...
                'MakeNameUnique','on',...
                'Position',[225,266,300,304],...
                'OutDataTypeStr','boolean',...
                'RndMeth','Nearest');


                linePorts(1,:)={strcat(get_param(sourceB,'Name'),'/1'),...
                strcat(get_param(DTC,'name'),'/1')};


                linePorts(2,:)={strcat(get_param(DTC,'name'),'/1'),...
                strcat(get_param(destB,'Name'),'/',int2str(portInd))};
                delete(line)
                add_line(hMFcn,linePorts(:,1),linePorts(:,2),'AutoRouting','smart');
            end
        end
    end



    dtc=Simulink.findBlocksOfType(hMFcn,'DataTypeConversion');

    for i=1:length(dtc)
        set_param(getfullname(dtc(i)),'SaturateOnIntegerOverflow','off');
    end

    hdataTypeConversionBlk=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(parent,'/Data Type Conversion'),...
    'MakeNameUnique','on',...
    'Position',[290,378,325,412],...
    'OutDataTypeStr',dataType,...
    'RndMeth','Nearest');

end

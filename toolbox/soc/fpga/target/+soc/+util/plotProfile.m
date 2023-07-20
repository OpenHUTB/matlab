function plotProfile(PMInfo,ProfileDataStruct)

    metricTimestamps=ProfileDataStruct.Time;
    metricValues=ProfileDataStruct.Data;






    metricValues(1,:,13)=zeros(1,PMInfo.NumSlots);
    for slot=1:PMInfo.NumSlots
        overflowFlags(:,:,slot)=dec2bin(metricValues(:,slot,13),10);
    end




    metricDims=size(metricValues);
    mvNew=zeros([metricDims(1),metricDims(2)*2,8]);
    ovNew=zeros([metricDims(1),metricDims(2)*2,5]);
    masterNames=cell(1,PMInfo.NumSlots*2);
    for slot=1:PMInfo.NumSlots
        midx=slot*2-1;
        masterNames{midx}=sprintf('Master%dWrite',slot);
        mvNew(:,midx,(1:6))=metricValues(:,slot,[3,1,5,6,7,11]);
        ovNew(:,midx,(1:5))=(overflowFlags(:,[8,10,6,5,4],slot)~='0');

        midx=midx+1;
        masterNames{midx}=sprintf('Master%dRead',slot);
        mvNew(:,midx,(1:6))=metricValues(:,slot,[4,2,8,9,10,12]);
        ovNew(:,midx,(1:5))=(overflowFlags(:,[7,9,3,2,1],slot)~='0');
    end


    nSamples=length(metricTimestamps(:));
    timeDiff(1)=0;
    timeDiff(2:nSamples)=round(double(metricTimestamps(2:nSamples)-metricTimestamps(1:nSamples-1))/PMInfo.AXI4LiteClkFreq,3);
    timeRelative=double(metricTimestamps-metricTimestamps(1))/PMInfo.AXI4LiteClkFreq;



    BWNormalizer=timeDiff;
    throughputData=(mvNew(:,:,1)/1e6)./BWNormalizer';
    BytesOvFlow=ovNew(:,:,1);
    usedSlots=[];
    usedMasters={};
    for nn=1:PMInfo.NumSlots*2
        if~isempty(find(throughputData(2:end,nn),1))
            usedSlots=[usedSlots,nn];%#ok<AGROW>
            usedMasters{end+1}=masterNames{nn};%#ok<AGROW>
        end
    end

    throughputVals=throughputData(:,usedSlots);
    bytesOvFlowFlags=BytesOvFlow(:,usedSlots);


    transactionData=mvNew(:,usedSlots,2);
    tranOvFlow=ovNew(:,usedSlots,2);
    latencyOvFlow=ovNew(:,usedSlots,3:5);


    latencyData=(mvNew(:,usedSlots,3:5)/PMInfo.CoreClkFreq)./transactionData;


    bitmask=hex2dec('0000FFFF');
    minlatclks=uint16(bitand(mvNew(:,usedSlots,4),bitmask));
    minlat=double(minlatclks)/PMInfo.CoreClkFreq;
    maxlatclks=uint16(bitshift(mvNew(:,usedSlots,4),-16));
    maxlat=double(maxlatclks)/PMInfo.CoreClkFreq;
    latneg=latencyData-minlat;
    latpos=maxlat-latencyData;


    for slotCtrl=1:length(usedSlots)
        profileDiag.(usedMasters{slotCtrl}).Data=[throughputVals(:,slotCtrl)...
        ,transactionData(:,slotCtrl),latencyData(:,slotCtrl,1)...
        ,latencyData(:,slotCtrl,2),latencyData(:,slotCtrl,3)];
        profileDiag.(usedMasters{slotCtrl}).Overflow=[bytesOvFlowFlags(:,slotCtrl)...
        ,tranOvFlow(:,slotCtrl),latencyOvFlow(:,slotCtrl,1)...
        ,latencyOvFlow(:,slotCtrl,2),latencyOvFlow(:,slotCtrl,3)];
    end
    if(~isempty(usedSlots))
        funCallStack=dbstack;
        jtagScriptName=funCallStack(3).file;
        [~]=soc.util.perfMemoryStatics(['Performance Plots for ',jtagScriptName],usedMasters,profileDiag,timeRelative);
    else
        disp(message('soc:msgs:noTransactionDetected').getString());
    end
end

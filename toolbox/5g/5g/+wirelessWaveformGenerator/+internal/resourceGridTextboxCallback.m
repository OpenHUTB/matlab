






function resourceGridTextboxCallback(fig,~,wgc,waveInfo,conflicts)


    textBoxTag='wirelessWaveformGenerator.internal.plotResourceGrid/TextBox';
    tbox=findall(fig,'Tag',textBoxTag);
    if isempty(tbox)||~isvalid(tbox)
        tbox=annotation(fig,'textbox',[1e-3,0.81,0.1,0.18],...
        'FitBoxToText',true,'Tag',textBoxTag);
    end

    tbox.String=getString(message('nr5g:waveformGeneratorApp:RBGridTextBoxUnallocatedOutBWP'));
    tbox.Visible=false;


    rgtag='wirelessWaveformGenerator.internal.plotResourceGrid';
    rbGridImage=findall(fig.Children,'Tag',rgtag);
    rbGridAxes=rbGridImage.Parent;


    pointer=rbGridAxes.CurrentPoint(1,:);
    xlims=rbGridAxes.XAxis.Limits;
    ylims=rbGridAxes.YAxis.Limits;
    pointerInAxes=pointer(1)>=xlims(1)&&pointer(1)<=xlims(2)&&pointer(2)>=ylims(1)&&pointer(2)<=ylims(2);
    if~pointerInAxes
        return;
    end
    pointer=round(pointer);


    pointerOverGrid=all((pointer(1:2)>=0)&(pointer(1:2)<fliplr(size(rbGridImage.CData))));
    if~pointerOverGrid
        return;
    end


    str=strsplit(fig.Tag,'BWP');
    bpID=str2double(str{2});


    carriers=wgc.SCSCarriers;
    bwps=wgc.BandwidthParts;
    [carrier,bwp]=getCarrierByBWPID(carriers,bwps,bpID);
    [prb,nslot,sym]=getPointerPositionInGrid(carrier,bwp,pointer);


    bwpIdx=find(cellfun(@(x)x.BandwidthPartID==bpID,bwps));
    bwp=bwps{bwpIdx};


    [tbcol,pointColorIdx,isConflict]=getPointerColor(rbGridAxes,pointer);





    if isConflict



        inBWP=any(bwpIdx==vertcat(conflicts(:).BwpIdx),2);
        conflicts=conflicts(inBWP);
        cflText=getConflictDisplayText(conflicts,waveInfo,bwpIdx,prb,sym);


        textInBox=cflText;

    else

        backgroundColorIndex=getChannelColorIndex("Background");
        bwpColorIndex=getChannelColorIndex("BWP");
        ssbColorIndex=getChannelColorIndex("SS Burst");


        switch pointColorIdx
        case backgroundColorIndex
            textInBox=getString(message('nr5g:waveformGeneratorApp:RBGridTextBoxUnallocatedOutBWP'));
        case bwpColorIndex
            textInBox=getString(message('nr5g:waveformGeneratorApp:RBGridTextBoxUnallocatedInBWP'));
        case ssbColorIndex
            textInBox="SS Burst";
        otherwise

            [fWaveInfo,chNames,chIdx]=flattenWaveInfo(waveInfo);


            channelBWPIDs=getChannelBWPID(wgc,chNames,chIdx);
            fWaveInfo=fWaveInfo(channelBWPIDs==bpID);


            textInBox=getChannelDisplayText(bwp,fWaveInfo,prb,sym);
        end

    end


    str=getString(message('nr5g:waveformGeneratorApp:RBGridTextBoxLocation',nslot,prb));
    textInBox=[string(textInBox);str];


    tbox.String=textInBox;
    tbox.BackgroundColor=tbcol;



    if all(tbcol(3)>2*tbcol(1:2))
        textColor=[1,1,1];
    else
        textColor=[0,0,0];
    end
    tbox.Color=textColor;
    tbox.Visible=true;

end



function text=getChannelDisplayText(bwp,chInfo,pprb,psym)

    text=[];


    symPerSlot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
    slotGridSize=[bwp.NSizeBWP,symPerSlot];
    pslot=floor(psym/symPerSlot);
    psym=mod(psym,symPerSlot);


    index=cellfun(@(x)any([x.Resources.NSlot]==pslot),chInfo);
    chInfo=chInfo(index);


    pointerIdx=sub2ind(slotGridSize,pprb+1,psym+1);


    numChannels=length(chInfo);
    for c=1:numChannels
        ch=chInfo{c};
        slotIdx=[ch.Resources.NSlot]==pslot;

        if any(slotIdx)



            reind=getSinglePlaneIndices(ch.Resources(slotIdx),slotGridSize);
            rbind=ceil(reind/12);
            if any(rbind==pointerIdx)
                text=[text;string(ch.Name)];%#ok<AGROW> 
            end
        end
    end


    if isempty(text)
        text=getString(message('nr5g:waveformGeneratorApp:RBGridTextBoxUnallocatedInBWP'));
    end

end



function[color,colorIdx,isConflict]=getPointerColor(ax,pointer)

    colorIdx=[];
    color=[];
    isConflict=false;
    tag='wirelessWaveformGenerator.internal.plotResourceGridConflicts';
    conflictsImage=findall(ax.Children,'Tag',tag);


    if~isempty(conflictsImage)&&~isempty(conflictsImage.CData)
        conflictColor=conflictsImage.CData(pointer(2)+1,pointer(1)+1,:);
        color=conflictColor(:)';
        isConflict=any(color);
    end



    if~isConflict
        tag='wirelessWaveformGenerator.internal.plotResourceGrid';
        rbGridImage=findall(ax.Children,'Tag',tag);
        colorIdx=floor(rbGridImage.CData(pointer(2)+1,pointer(1)+1,:));
        color=ax.Colormap(colorIdx+1,:);
    end

end



function text=getConflictDisplayText(conflicts,waveInfo,bpIdx,prb,sym)

    text=[];
    conflictTextHeader=getString(message('nr5g:waveformGeneratorApp:RBGridConflictTextBoxHeader'));
    isConflict=false;
    chLabels=[];

    l=sym;
    for c=1:length(conflicts)

        cfl=conflicts(c);


        idx=find(cfl.BwpIdx==bpIdx,1,'first');
        Grid=cfl.Grid{idx};



        k=prb*12;
        pointerInConflict=any(Grid(k+(1:12),l+1));

        if pointerInConflict

            cflLabels=getConflictChannelText(cfl,waveInfo);
            chLabels=[chLabels;cflLabels];%#ok<AGROW>
            isConflict=true;
        end

    end


    if isConflict
        chLabels=unique(string(chLabels));
        text=[conflictTextHeader;chLabels];
    end

end

function label=getConflictChannelText(cfl,waveInfo)

    label=repmat("",2,1);
    for i=1:2
        channelIdx=cfl.ChannelIdx(i);
        channelType=cfl.ChannelType{i};

        if strcmpi(channelType,"SSBurst")
            label(i)=replace(channelType,"SSBurst","SS Burst");
        else
            label(i)=waveInfo.(channelType)(channelIdx).Name;
            label(i)=replace(label(i),"CSIRS","CSI-RS");
        end
    end

end

function colorIndex=getChannelColorIndex(chNames)

    [chplevel,cscaling]=wirelessWaveformGenerator.internal.channelPowerLevelsMap();

    colorIndex=NaN(1,length(chNames));
    isk=isKey(chplevel,chNames);
    colorIndex(isk)=floor(cscaling*cellfun(@(x)chplevel(x),chNames(isk)));

end

function[carrier,bwp]=getCarrierByBWPID(carriers,bwps,bwpID)

    carriers=[carriers{:}];
    bwps=[bwps{:}];

    bwp=bwps([bwps.BandwidthPartID]==bwpID);
    carrier=carriers([carriers.SubcarrierSpacing]==bwp.SubcarrierSpacing);

end

function[prb,nslot,sym]=getPointerPositionInGrid(carrier,bwp,pointer)

    symPerSlot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
    crb=pointer(2);
    prb=crb-bwp.NStartBWP+carrier.NStartGrid;
    nslot=floor(pointer(1)/symPerSlot);
    sym=pointer(1);

end


function[fWaveInfo,chNames,chIdx]=flattenWaveInfo(waveInfo)

    fnames=fieldnames(waveInfo);
    fWaveInfo={};
    chNames={};
    chIdx=zeros(1,0);
    numChTypes=numel(fnames);
    for f=1:numChTypes
        chInfo=num2cell(waveInfo.(fnames{f}));
        fWaveInfo=[fWaveInfo,chInfo];%#ok<AGROW>
        numChs=length(chInfo);
        chNames=[chNames,repmat(fnames(f),1,numChs)];%#ok<AGROW>
        chIdx=[chIdx,1:numChs];%#ok<AGROW>
    end

end

function indices=getSinglePlaneIndices(resource,slotGridSize)

    if isfield(resource,'SignalIndices')
        indField='SignalIndices';
    else
        indField='ChannelIndices';
    end


    ind=resource.(indField)(:);

    if isfield(resource,'DMRSIndices')
        ind=[ind;resource.DMRSIndices(:)];
    end

    if isfield(resource,'PTRSIndices')
        ind=[ind;resource.PTRSIndices];
    end

    indices=1+mod(double(ind)-1,12*prod(slotGridSize));
end

function bwpID=getChannelBWPID(wgc,chNames,chIdx)

    bwpID=cellfun(@(name,index,prop)wgc.(name){index}.BandwidthPartID,chNames,num2cell(chIdx));

end

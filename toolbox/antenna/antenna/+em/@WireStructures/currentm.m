function[current,Points,hfig]=currentm(obj,frequency,flag,scale)























    hfig=[];
    Points=[];
    current=[];
    currentShow=[];
    for WireInd=1:length(obj.WiresInt)

        allPts=obj.MesherStruct.Mesh.bothPts{WireInd};
        allPtsOnWire=obj.WiresInt{WireInd}.relLocationOnWire(allPts);
        allPtsOnWire=allPtsOnWire+(allPtsOnWire==0)*sqrt(eps(1))-...
        (allPtsOnWire==1)*sqrt(eps(1));
        allCurrents=obj.WiresInt{WireInd}.CalcSegIs(allPtsOnWire*...
        obj.WiresInt{WireInd}.SegmentLength);


        addedCurrents=reshape(repmat(allCurrents,2,1),1,[]);
        addedCurrents=addedCurrents(2:end-1);
        current=[current,allCurrents];%#ok<AGROW>
        currentShow=[currentShow,addedCurrents];%#ok<AGROW>
        Points=[Points,allPts];%#ok<AGROW>
    end
    [Points,UniqPtInd,UniqPtInvInd]=uniquetol(Points.','ByRows',true,'DataScale',...
    sqrt(eps(max(abs(Points),[],2))));
    Points=Points(unique(UniqPtInvInd,'stable'),:).';
    current=current(UniqPtInd);
    current=current(unique(UniqPtInvInd,'stable'));

    if flag==0

        currentNorm=sqrt(currentShow.*conj(currentShow));
        [currentNorm1,~,U]=engunits(currentNorm);

        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,currentNorm1,scale);


        if strcmpi(scale,'linear')
            ylabel(clrbarHdl,[U,'A']);
            title(axesHdl,'Current intensity');
        elseif strcmpi(scale,'log')
            ylabel(clrbarHdl,['log(',U,'A)']);
            title(axesHdl,'Current intensity (log)');
        elseif strcmpi(scale,'log10')
            ylabel(clrbarHdl,['log10(',U,'A)']);
            title(axesHdl,'Current intensity (log10)');
        else
            ylabel(clrbarHdl,[char(scale),'(',U,'A)']);
            title(axesHdl,['Current intensity (',char(scale),')']);
        end










    end

end




















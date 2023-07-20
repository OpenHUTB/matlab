function[charge,Points,hfig]=chargem(obj,freq,flag,scale)





















    hfig=[];
    Points=[];
    charge=[];
    chargeShow=[];
    for WireInd=1:length(obj.WiresInt)

        allPts=obj.MesherStruct.Mesh.bothPts{WireInd};
        allPtsOnWire=obj.WiresInt{WireInd}.relLocationOnWire(allPts);
        allPtsOnWire=allPtsOnWire+(allPtsOnWire==0)*sqrt(eps(1))-...
        (allPtsOnWire==1)*sqrt(eps(1));
        allCharges=obj.WiresInt{WireInd}.CalcSegQtags(allPtsOnWire*...
        obj.WiresInt{WireInd}.SegmentLength);


        addedCharges=reshape(repmat(allCharges,2,1),1,[]);
        addedCharges=addedCharges(2:end-1);
        charge=[charge,allCharges];%#ok<AGROW>
        chargeShow=[chargeShow,addedCharges];%#ok<AGROW>
        Points=[Points,allPts];%#ok<AGROW>
    end

    if flag==0

        chargeabs1=sqrt(chargeShow.*conj(chargeShow))+eps(0);
        [chargeabs,~,U]=engunits(chargeabs1);

        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,chargeabs,scale);

        if strcmpi(scale,'linear')
            ylabel(clrbarHdl,[U,'C/m']);
            title(axesHdl,'Charge density');
        elseif strcmpi(scale,'log')
            ylabel(clrbarHdl,['log(',U,'C/m)']);
            title(axesHdl,'Charge density (log)');
        elseif strcmpi(scale,'log10')
            ylabel(clrbarHdl,['log10(',U,'C/m)']);
            title(axesHdl,'Charge density (log10)');
        else
            ylabel(clrbarHdl,[char(scale),'(',U,'C/m)']);
            title(axesHdl,['Charge density (',char(scale),')']);
        end
    end

end










function[fpTransmitMap,fpScanMap]=getFpMap(~,inSignals,vectorPortSize,src)









    isVhdl=hdlgetparameter('isvhdl');
    if isVhdl
        inSigs={inSignals};
    else
        if length(src.HDLPortName)~=1
            if src.dataIsComplex
                inSigs={inSignals(1:2*vectorPortSize)};
            else
                inSigs={inSignals(1:vectorPortSize)};
            end
        else
            inSigs={inSignals};
        end
    end

    len=cellfun('length',inSigs);
    if len==1
        fpSet=inSigs{1};
        fpScanMap=containers.Map(fpSet,fpSet);
        fpTransmitMap=containers.Map(fpSet,{inSignals});
    else

        fpTxtKeySet=inSigs;
        for ii=1:len
            fpTxtValueSet{ii}=inSignals(ii:len:end);%#ok
        end
        fpTransmitMap=containers.Map(fpTxtKeySet{:},fpTxtValueSet);

        if isVhdl
            fpScanMap=[];
        else

            fpTemp=reshape(inSigs{:},vectorPortSize,len/vectorPortSize);
            fpScanKeySet=fpTemp(1,:);
            for jj=1:len/vectorPortSize
                fpScanValueSet{jj}=fpTemp(:,jj);%#ok
            end
            fpScanMap=containers.Map(fpScanKeySet,fpScanValueSet);
        end
    end
end



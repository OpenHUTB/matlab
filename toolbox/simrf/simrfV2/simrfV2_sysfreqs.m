function[UniqueFreqs,strTip,combsOut]=simrfV2_sysfreqs(tones,harms,...
    maketooltip)























    if nargin<3
        maketooltip=1;
    end

    if sum(size(tones)~=size(harms))||(size(tones,1)~=1)
        error(message('simrf:simrfV2errors:InconsistentHarmonics'));
    end


    if length(tones)>1
        ldcTones=(tones~=0);
        tones=tones(ldcTones);
        harms=harms(ldcTones);
    else
        if tones==0
            UniqueFreqs=0;
            strTip{1}={'0Hz','',' f1'};
            return
        end
    end


    combs=combHarms(harms);

    allFreqs=tones*combs;

    epsTones=eps(tones);
    epsVec=epsTones*abs(combs);


    [orderFreqs,idxAllFreqs]=sort(allFreqs);
    gtez_idx=orderFreqs>=0;
    orderFreqsGTEZ=orderFreqs(gtez_idx);
    idxAllFreqsGTEZ=idxAllFreqs(gtez_idx);

    epsDiff=epsVec(idxAllFreqsGTEZ(1:end-1))+epsVec(idxAllFreqsGTEZ(2:end));

    uniqueIdx=[0,find((diff(orderFreqsGTEZ)-epsDiff)>=0)]+1;
    UniqueFreqs=orderFreqsGTEZ(uniqueIdx);
    orderCombsGTEZ=combs(:,idxAllFreqsGTEZ);
    combsOut=arrayfun(@(x,y)orderCombsGTEZ(:,x:y),uniqueIdx(1:end),...
    [uniqueIdx(2:end),length(orderFreqsGTEZ)+1]-1,'UniformOutput',false);


    if(maketooltip)
        strTip=cell(1,length(uniqueIdx));
        tip_idx=[uniqueIdx(2:end),length(orderFreqsGTEZ)+1]-1;
        strTip_idx=1;
        colStr='';
        for col_idx=1:length(orderFreqsGTEZ)
            tmpStr=[];
            for row_idx=1:length(tones)
                coeff=orderCombsGTEZ(row_idx,col_idx);
                if coeff~=0
                    tmpStr=sprintf('%s%+df%d',tmpStr,coeff,row_idx);
                end
            end
            if~isempty(tmpStr)
                colStr=sprintf('%s%s,',colStr,regexprep(tmpStr,'^\+',' '));
            end
            if col_idx>=tip_idx(strTip_idx)
                colStr=regexprep(colStr,',\+',', ');
                colStr=regexprep(colStr,'(\D)1f','$1f');
                colStr=sprintf('%gHz,,%s',orderFreqsGTEZ(col_idx),...
                regexprep(colStr,',$',''));
                strTip{strTip_idx}=regexp(colStr,',','split');
                strTip_idx=strTip_idx+1;
                colStr='';
            end
        end
    else
        strTip=[];
    end

    function combs=combHarms(harms)






        harm_len=size(harms,2);
        combs=-harms(harm_len):harms(harm_len);
        num_tiles=1;

        for h_idx=harm_len-1:-1:1
            num_tiles=num_tiles*(2*harms(h_idx+1)+1);
            top_row=reshape(repmat(-harms(h_idx):harms(h_idx),num_tiles,1),1,[]);
            bot_row=repmat(combs,1,2*harms(h_idx)+1);
            combs=cat(1,top_row,bot_row);
        end
function[freqList,BlkList]=simrfV2_read_freqs(block,blks,freqParamName,condParamName)









    freqList=[];
    BlkList={};
    for m=1:numel(blks)
        blkval=blks{m};
        MaskVals=get_param(blkval,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(blkval);
        MaskWSValues=simrfV2getblockmaskwsvalues(blkval);

        if isempty(condParamName)||MaskWSValues.(condParamName)
            try
                CF=slResolve(MaskVals{idxMaskNames.(freqParamName)},block);
            catch me %#ok<NASGU> % specified value
                CF=MaskWSValues.(freqParamName);
            end
            validateattributes(CF,{'numeric'},...
            {'nonempty','row','finite','real','nonnegative'},...
            block,'specified frequencies');
            freqList=[freqList,simrfV2convert2baseunit(CF,...
            MaskVals{idxMaskNames.([freqParamName,'_unit'])})];%#ok<AGROW>
            BlkList=[BlkList,blks{m}];%#ok<AGROW>
        end
    end

function[spsBlks,pssBlks]=utilGetConverterBlocks(Inputs,Outputs)




    spsBlks={};
    pssBlks={};

    for ss=1:numel(Inputs)
        spsBlks{ss}=Inputs(ss).object;%#ok<AGROW>
    end

    for pp=1:numel(Outputs)
        pssBlks{pp}=Outputs(pp).object;%#ok<AGROW>
    end

end

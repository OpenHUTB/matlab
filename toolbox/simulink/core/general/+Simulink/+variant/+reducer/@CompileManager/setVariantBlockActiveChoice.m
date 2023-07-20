function setVariantBlockActiveChoice(obj,val)






    if isempty(obj.VariantBlockActiveChoiceStruct)
        obj.VariantBlockActiveChoiceStruct=val;
    else
        existingBlocks=arrayfun(@(x)(x.VariantBlock),obj.VariantBlockActiveChoiceStruct,...
        'UniformOutput',false);
        for ii=1:length(val)
            idx=find(strcmp(val(ii).VariantBlock,existingBlocks),1);
            if isempty(idx)
                obj.VariantBlockActiveChoiceStruct=[obj.VariantBlockActiveChoiceStruct;val(ii)];
            else


                obj.VariantBlockActiveChoiceStruct(idx).CompiledActiveChoice...
                ={obj.VariantBlockActiveChoiceStruct(idx).CompiledActiveChoice;...
                val(ii).CompiledActiveChoice};
            end
        end
    end
end



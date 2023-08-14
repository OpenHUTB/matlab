

function[variantNames,blkNames,comboBoxEntries]=getVariantInfoFromBlock(blkH)

    variants=get_param(blkH,'Variants');

    variantNames=cell(1,numel(variants));
    blkNames=cell(1,numel(variants));
    comboBoxEntries=cell(1,numel(variants));

    for ii=1:numel(variants)
        blkNames{ii}=get_param(variants(ii).BlockName,'Name');
        blkNames{ii}=strrep(blkNames{ii},newline,' ');
        variantNames{ii}=variants(ii).Name;

        comboBoxEntries{ii}=sprintf('%s%s%s%s',variantNames{ii},' (',blkNames{ii},') ');
    end
end


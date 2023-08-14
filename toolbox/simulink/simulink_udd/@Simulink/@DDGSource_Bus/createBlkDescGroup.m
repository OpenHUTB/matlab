function[descGroup]=createBlkDescGroup(~,block)





    descText.Name=block.BlockDescription;
    descText.Type='text';
    descText.WordWrap=true;

    descGroup.Name=block.BlockType;
    descGroup.Type='group';
    descGroup.Items={descText};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];

end


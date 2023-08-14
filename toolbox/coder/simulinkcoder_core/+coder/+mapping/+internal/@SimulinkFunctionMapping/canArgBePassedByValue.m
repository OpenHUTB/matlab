function byValue=canArgBePassedByValue(arg)





    byValue=true;
    isImage=arg.IsImage;
    isBus=arg.IsBus;
    isArray=~arg.IsScalar;
    if isArray||isBus||isImage

        byValue=false;
    end

    return;
end

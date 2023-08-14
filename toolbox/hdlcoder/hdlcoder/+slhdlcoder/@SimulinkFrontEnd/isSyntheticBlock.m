function synthetic=isSyntheticBlock(slbh)



    obj=get(slbh,'ObjectAPI_FP');
    if obj.isSynthesized
        synthetic=true;
    else
        synthetic=false;
    end
end

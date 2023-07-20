function SetSourceData(this,srcData)












    if(isempty(srcData{2}))

        srcData{2}=getlocalhostname;
    end

    srcData{1}=this.UddUtil.MaskEnum2Bool(srcData{1});
    srcData{3}=this.UddUtil.EnumInt2Str(...
    'CoSimConnectionMethodEnum',...
    this.UddUtil.MaskEnum2Bool(srcData{3}));
    srcData{5}=this.UddUtil.MaskEnum2Bool(srcData{5});

    [this.CommLocal,this.CommHostName,this.CommSharedMemory,...
    this.CommPortNumber,this.CommShowInfo]=srcData{1:5};
    if strcmp(srcData{6},'Full Simulation')
        this.CosimBypass=0;
    elseif strcmp(srcData{6},'Confirm Interface Only')
        this.CosimBypass=1;
    elseif strcmp(srcData{6},'No Connection')
        this.CosimBypass=2;
    end
    [this.localHostName,this.lastRemoteHostName]=deal(this.CommHostName);

end

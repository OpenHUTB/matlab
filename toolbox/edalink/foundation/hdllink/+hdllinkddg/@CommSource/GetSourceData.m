function srcData=GetSourceData(this)




    srcData={this.CommLocal,this.CommHostName,this.CommSharedMemory...
    ,this.CommPortNumber,this.CommShowInfo,this.CosimBypass};

    srcData{3}=this.UddUtil.EnumStr2Int('CoSimConnectionMethodEnum',srcData{3});



    if(this.CommLocal==1),srcData{2}='';end

end

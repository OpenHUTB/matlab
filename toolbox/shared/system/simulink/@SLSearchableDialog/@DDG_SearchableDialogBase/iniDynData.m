function iniDynData(this)




    block=this.getBlock();
    maskObj=Simulink.Mask.get(block.Handle);
    paraObj=maskObj.Parameters;


    this.DialogData.ListReadOnly=this.str2logic({paraObj(:).ReadOnly});

end

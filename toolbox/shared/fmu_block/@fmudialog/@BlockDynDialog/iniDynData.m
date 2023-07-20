function iniDynData(this)




    block=this.getBlock();
    maskObj=Simulink.Mask.get(block.Handle);
    paraObj=maskObj.Parameters;


    this.DialogData.ListReadOnly=cellfun(@str2logic,{paraObj(:).ReadOnly});

end


function result=str2logic(str)


    if strcmp(str,'on')
        result=true;
    else
        result=false;
    end

end

function v=validateBlock(this,hC)%#ok<INUSD> 



    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;



    satMethodInputType=get_param(bfp,'satMethodInputType');
    if~strcmpi(satMethodInputType,'Specify via dialog')
        errorStatus=1;
        errorMsg=satMethodInputType;
        v(end+1)=hdlvalidatestruct(errorStatus,message('mcb:blocks:HdlDQLimiterSatMethodInputType',errorMsg));
    end



    satMethodSelected=get_param(bfp,'satMethodSelected');
    if~strcmpi(satMethodSelected,'D-Q equivalence')
        errorStatus=1;
        errorMsg=satMethodSelected;
        v(end+1)=hdlvalidatestruct(errorStatus,message('mcb:blocks:HdlDQLimiterSatMethod',errorMsg));
    end



    satLimitInputType=get_param(bfp,'satLimitInputType');
    if~strcmpi(satLimitInputType,'Specify via dialog')
        errorStatus=1;
        errorMsg=satLimitInputType;
        v(end+1)=hdlvalidatestruct(errorStatus,message('mcb:blocks:HdlDQLimiterSatMethodLimit',errorMsg));
    end

end
function param=quantizedinputParams(this,WL,param,layer,mapObjInputExp,mapObjOutputExp,fiMath)




    if(~(WL==1))
        keyLayerName=erase(layer.Name,'_insertZeros');
        param.ExpData=mapObjInputExp(keyLayerName);
        param.OutputExpData=mapObjOutputExp(keyLayerName);
        param.WL=WL;




        param.fiMath=fiMath;
    end
end


function autoscaler=getAutoscaler(this,blockObj)



    key=this.getXMLKeyForBlock(blockObj);


    if ismember(key,this.AutoscalersCell)

        autoscaler=this.AutoscalerMap(key);
    else

        autoscaler=SimulinkFixedPoint.EntityAutoscalers.DefaultEntityAutoscaler;
    end

end
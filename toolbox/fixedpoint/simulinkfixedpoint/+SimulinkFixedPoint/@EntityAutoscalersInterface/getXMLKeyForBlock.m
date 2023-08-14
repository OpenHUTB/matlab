function key=getXMLKeyForBlock(this,blockObj)





    if isa(blockObj,'Simulink.MATLABSystem')
        key=this.getMATLABSystemBlockKey(blockObj);
    elseif isa(blockObj,'Simulink.SFunction')
        key=this.getSFunctionBlockKey(blockObj);
    elseif isa(blockObj,'SimulinkFixedPoint.DataObjectWrapper')
        key=blockObj.EntityAutoscalerID;
    else

        key=this.getGeneralBlockKey(blockObj);
    end
end
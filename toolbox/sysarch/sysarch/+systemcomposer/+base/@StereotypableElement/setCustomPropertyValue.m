function setCustomPropertyValue(this,propObj,value)




    t=this.MFModel.beginTransaction;
    this.getPrototypable.setPropVal([propObj.propertySet.getName,'.',propObj.getName],value);
    t.commit;
end
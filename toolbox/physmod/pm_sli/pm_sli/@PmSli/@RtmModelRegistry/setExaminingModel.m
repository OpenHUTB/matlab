function setExaminingModel(this,mdl,isExamining)




    idx=this.createModelEntry(mdl);

    this.modelInfo(idx).modelData.examining=isExamining;





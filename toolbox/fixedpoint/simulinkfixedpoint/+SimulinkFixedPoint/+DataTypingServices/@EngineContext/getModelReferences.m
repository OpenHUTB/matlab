function getModelReferences(this)







    this.topModelModelReferences=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.topModel);


    this.systemUnderDesignModelReferences=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.systemUnderDesign);
end
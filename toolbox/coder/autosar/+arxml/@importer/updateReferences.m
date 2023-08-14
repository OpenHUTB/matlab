function updateReferences(this,modelName,varargin)





    autosar.mm.util.MessageReporter.print(...
    message('autosarstandard:api:ObsoleteUpdateReferences').getString())
    this.updateAUTOSARProperties(modelName,varargin{:});



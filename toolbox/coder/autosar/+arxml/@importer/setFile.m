function setFile(this,aFilename)










    if ischar(aFilename)||isStringScalar(aFilename)
        p_setfile(this,aFilename);

    else
        autosar.mm.util.MessageReporter.createWarning('RTW:autosar:badFilename');
    end

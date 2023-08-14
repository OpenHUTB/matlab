function[theMode,isLibrary]=getModelEditingMode(hh)









    this=PmSli.RunTimeModule.getInstance;

    if isempty(this)
        pm_error(Error.RtmNotInitialized_msgid);
    end

    propOwningObj=this.getConfigSet(hh.Handle);

    if isempty(propOwningObj)

        isLibrary=true;
        theMode=EDITMODE_AUTHORING;

    else

        isLibrary=false;
        theMode=this.getConfigSetEditingMode(propOwningObj);

    end







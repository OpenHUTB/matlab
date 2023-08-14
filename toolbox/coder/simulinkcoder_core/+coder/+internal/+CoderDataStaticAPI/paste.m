function paste(destinationDD)
















    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cdict=hlp.openDD(destinationDD);
    hlp.setProp(cdict.owner,'Status','Pasting');
    oc=onCleanup(@()hlp.setProp(cdict.owner,'Status','Ready'));
    coderdictionary.data.api.paste(cdict.owner);
end
function out=getCurrentNonBuiltinPackages(sourceDD)











    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    dd=hlp.openDD(sourceDD);
    out=coderdictionary.data.api.getNonBuiltinPackageNames(dd.owner);
end
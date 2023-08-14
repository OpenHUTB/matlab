function[update,out]=createCustomAttributesObject(sourceDD,scDecoratedName,currentAttribClassName)



















    import coder.internal.CoderDataStaticAPI.*;
    update=0;
    out=[];
    type='StorageClass';
    try
        hlp=getHelper();
        dd=hlp.openDD(sourceDD);
        scObj=hlp.findEntry(dd,type,scDecoratedName);
        if(isa(scObj,'coderdictionary.data.LegacyStorageClass')&&...
            ~strcmp(scObj.Package,'SimulinkBuiltin'))
            pkgName=scObj.Package;
            scName=scObj.ClassName;

            outClassName=['ModelAttribClass_',pkgName,'_',scName];
            if~strcmp(currentAttribClassName,outClassName)
                out=processcsc('CreateAttributesObject',pkgName,scName,true);
                assert(strcmp(class(out),['SimulinkCSC.',outClassName]));
                update=1;
            end
        else


            outClassName='AttribClass_Simulink_Default';
            if~strcmp(currentAttribClassName,outClassName)
                out=processcsc('CreateAttributesObject','Simulink','Default');
                assert(strcmp(class(out),['SimulinkCSC.',outClassName]));
                update=1;
            end
        end
    catch me
        rethrow(me);
    end
end

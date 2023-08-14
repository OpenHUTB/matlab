function out=isCoderDictionaryDefault(sourceDD)









    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    if isempty(sourceDD)||(isnumeric(sourceDD)&&any(sourceDD==0))
        out=false;
        return;
    end
    out=false;
    try

        slRoot=slroot;
        if slRoot.isValidSlObject(sourceDD)
            dd=hlp.openDD(sourceDD,'C',true);
        else
            dd=hlp.openDD(sourceDD);
        end
        m=mf.zero.Model;
        cont=coderdictionary.data.Container(m)
        cont.init();
        cdefOther=cont.CDefintions;
        initilializeDictionary(cdefOther);
        out=isequal(dd,cdefOther);
    catch


    end
end

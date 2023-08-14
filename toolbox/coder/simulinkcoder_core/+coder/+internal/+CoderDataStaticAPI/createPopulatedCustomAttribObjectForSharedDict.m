function cscAttribObj=createPopulatedCustomAttribObjectForSharedDict(sourceDD,category,packageName,className,instSpValues)






    import coder.internal.CoderDataStaticAPI.*;
    cscAttribObj=processcsc('CreateAttributesObject',packageName,className);

    hlp=getHelper();
    cdict=hlp.openDD(sourceDD);


    sc=hlp.findEntry(cdict,'StorageClass',className);
    if~isempty(sc)&&isvalid(sc)
        containerIsModel=strcmp(cdict.owner.context,'model');
        if containerIsModel
            return;
        end




        dc=cdict.SoftwareComponentTemplates(1).(category);
        if isempty(instSpValues)
            values=jsondecode(dc.InitialCSCAttributesSchema);
        else
            values=instSpValues;
        end
        for i=1:length(values)
            currentVal=values(i);
            cscAttribObj.(currentVal.Name)=currentVal.Value;
        end

    end
end
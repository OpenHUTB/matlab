function validateInstanceSpecificProperty(sourceDD,category,packageName,...
    className,property,value,instSpValues)


















    import coder.internal.CoderDataStaticAPI.*;

    if nargin<7
        instSpValues='';
    end
    hlp=getHelper();
    cdict=hlp.openDD(sourceDD);

    category=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(category);

    containerIsModel=strcmp(cdict.owner.context,'model');
    if containerIsModel

        cscAttribObj=processcsc('CreateAttributesObject',packageName,className);
    else

        cscAttribObj=createPopulatedCustomAttribObjectForSharedDict(sourceDD,...
        category,packageName,className,instSpValues);
    end


    cscAttribObj.(property)=value;

end
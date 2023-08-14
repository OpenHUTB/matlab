function value=getArgPropertyValue(this,arg,propName,ctxBlockHandle)


















    fullPropName=this.getArgPropFullName(propName);
    propName=fullPropName{1};

    if startsWith(propName,"DataParsedInfo")

        if slreportgen.utils.isModelCompiled(bdroot(ctxBlockHandle))


            value=sf('DataParsedInfo',arg.id,ctxBlockHandle);
        else
            value='';
            return
        end
    else

        value=arg.(propName);
    end



    nPropNames=numel(fullPropName);
    for iPropName=2:nPropNames
        propName=fullPropName{iPropName};
        value=value.(propName);
    end

function propList=atGetPropertyList(this,propsrc,obj,objType)




    if strcmp(this.PropertyListMode,'manual')
        propList=this.PropertyList;
    else
        switch lower(objType)
        case 'model'
            propList={'Description'};
        case 'signal'
            propList={'Description'};
        case 'system'
            propList={'Description'};
        case 'annotation'
            propList={'Text'};
        case 'configset'
            propList={'Name'};
        otherwise

            propList=rptgen_sl.getBlockParams(obj);
        end
    end
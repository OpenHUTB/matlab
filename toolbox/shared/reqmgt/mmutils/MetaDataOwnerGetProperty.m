function value=MetaDataOwnerGetProperty(this,propertyName)

    value='';


    data=this.data;
    if~isempty(data)
        value=getValueByName(data,propertyName);
    end

    if isempty(value)&&~any(strcmp(propertyName,{'keywords','groups'}))




        if~isempty(which('domainadapters.getProperty'))
            switch class(this)
            case{'rmidd.ImmutableRoot','rmidd.ImmutableNode','rmidd.ImmutableLink'}
                value=domainadapters.getProperty(this,propertyName);
            otherwise
                value=['ERROR in MetaDataOwnerGetProperty(): unsupported class "',class(this),'" when looking for "',propertyName,'"'];
            end
        end
    end

end

function value=getValueByName(data,propName)


    value='';
    for n=1:data.names.size
        if strcmp(data.names.at(n),propName)
            if n<=data.values.size
                value=data.values.at(n);
            else

                value=['ERROR in MetaDataOwnerGetProperty(): mismatched name-value sequence length when looking for "',propName,'"'];
            end
            break;
        end
    end
end



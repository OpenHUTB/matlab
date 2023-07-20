function instance=findInstanceFromQualifiedName(this,qualifiedName)

    instance=[];
    connectorNameParts=split(string(qualifiedName),'->');
    if length(connectorNameParts)>1

        source=findInstance(this,connectorNameParts(1));
        dest=findInstance(this,connectorNameParts(2));
        if~(isempty(source)||isempty(dest))
            instance=this.findConnectorInstanceFromEnds(source,dest);
        end
    else
        instance=findInstance(this,connectorNameParts(1));
    end
    assert(~isempty(instance),'systemcomposer:analysis:cantFindInstance',message('SystemArchitecture:Analysis:CantFindInstance').getString);
end
function instance=findInstance(this,qualifiedName)
    nameParts=split(string(qualifiedName),':');
    nameArray=getComponentNames(nameParts(1));
    instance=this.findInstanceFromQualifiedNameArray(nameArray(2:end));
    if~isempty(instance)&&length(nameParts)>1

        instance=instance.ports.getByKey(nameParts(2));
    end
end

function compNames=getComponentNames(namedPath)
    namedPath=char(namedPath);
    compNames=[];
    rawPathElemName=[];
    ignoreNextDelim=false;
    for i=1:length(namedPath)
        curChar=namedPath(i);
        if(curChar~='/')
            rawPathElemName=[rawPathElemName,curChar];
            ignoreNextDelim=false;
        elseif(curChar=='/'&&(ignoreNextDelim||(namedPath(i+1)=='/')))

            rawPathElemName=[rawPathElemName,curChar];
            ignoreNextDelim=~ignoreNextDelim;
        else
            compName=string(strrep(rawPathElemName,'//','/'));
            compNames=[compNames,compName];
            rawPathElemName=[];
            ignoreNextDelim=false;
        end
    end
    compName=string(strrep(rawPathElemName,'//','/'));
    compNames=[compNames,compName];
end


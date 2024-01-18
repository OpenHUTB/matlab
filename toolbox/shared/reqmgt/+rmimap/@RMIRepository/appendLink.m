function appendLink(this,srcRoot,dependentNode,linkData,reuse)

    link=rmidd.Link(this.graph);
    link.dependentNode=dependentNode;
    description=linkData.getValue('description');
    isDescrModified=false;
    destType=linkData.getValue('source');
    if isempty(destType)
        destType='other';
    end
    targetUrl=linkData.getValue('dependeeUrl');
    if isempty(targetUrl)
        targetUrl=['__UNSPECIFIED__',destType];
    end
    if strcmp(destType,'linktype_rmi_simulink')&&strncmp(targetUrl,'$ModelName$',length('$ModelName$'))
        targetUrl=strrep(targetUrl,'$ModelName$',strtok(srcRoot.url,':'));
        if description(1)=='/'
            description=[targetUrl,description];
            isDescrModified=true;
        end
    end
    targetId=linkData.getValue('dependeeId');
    dependeeNode=this.findOrAddNode(targetUrl,targetId,destType);
    link.dependeeNode=dependeeNode;

    srcRoot.links.append(link);

    if reuse

        link.data=linkData;
        if isDescrModified
            link.setProperty('description',description);
        end
    else
        link.setProperty('description',description);
        link.setProperty('linked',linkData.getValue('linked'));
        link.setProperty('keywords',linkData.getValue('keywords'));
    end
end



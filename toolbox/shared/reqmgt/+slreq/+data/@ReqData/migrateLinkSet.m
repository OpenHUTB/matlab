function migrateLinkSet(this,mfLinkSet,asVersion)

    if mfLinkSet.linktypes.Size==0&&contains(asVersion,{'R2018a','R2017b'})


        linkTypeMap=getLinkTypeMap(this,mfLinkSet,asVersion);
        updateLinkTypeOnLinks(this,mfLinkSet,linkTypeMap);
    elseif contains(asVersion,{'R2018b','R2019a','R2019b'})


        linkTypeMap=getLinkTypeMap(this,mfLinkSet,asVersion);
        updateConfirmsLinks(this,mfLinkSet,linkTypeMap);
    end
end

function baseTypeName=recGetBuiltinBaseType(this,typeName)
    mfNewLinkType=this.getLinkType(typeName);
    superTypeName=mfNewLinkType.superType.typeName;
    if slreq.app.LinkTypeManager.isa(superTypeName,'Unset')
        baseTypeName=mfNewLinkType.superType;
    else
        baseTypeName=recGetBuiltinBaseType(this,superTypeName);
    end
end


function updateSelfLink(mfLink,shortName)
    mfLinkDest=mfLink.dest;

    mfLinkDest.reqSetUri=strrep(mfLinkDest.reqSetUri,'_SELF',shortName);
end

function linkTypeMap=getLinkTypeMap(this,mfLinkSet,asVersion)
    linkTypes=enumeration(slreq.custom.LinkType.DefaultValue);
    linkTypeMap=containers.Map('KeyType','char','ValueType','Any');

    for n=1:length(linkTypes)
        linkType=linkTypes(n);
        thisLinkType=slreq.datamodel.LinkType(this.model);
        thisLinkType.typeName=linkType.getTypeName;
        thisLinkType.forwardName=linkType.forwardName;
        thisLinkType.backwardName=linkType.backwardName;
        thisLinkType.isBuiltin=true;
        thisLinkType.rollupType=linkType.getRollupType;
        if contains(asVersion,{'R2018a','R2017b'})
            mfLinkSet.linktypes.add(thisLinkType);
        end
        linkTypeMap(thisLinkType.typeName)=thisLinkType;
    end



    mfLinkSet.linktypes.remove(linkTypeMap('Confirm'));
    linkTypeMap.remove('Confirm');
end

function updateLinkTypeOnLinks(this,mfLinkSet,linkTypeMap)


    mfLinks=mfLinkSet.links.toArray;
    for n=1:length(mfLinks)
        mfLink=mfLinks(n);
        typeName=mfLink.typeName;
        if isKey(linkTypeMap,typeName)
            mfLink.linktype=linkTypeMap(typeName);
        else


            baseTypeName=recGetBuiltinBaseType(this,typeName);
            if isKey(linkTypeMap,baseTypeName)
                mfLink.linktype=linkTypeMap(baseTypeName);
            else



                mfLink.linktype=linkTypeMap('Relate');
            end
        end



        [~,shortUriName]=fileparts(mfLinkSet.artifactUri);
        updateSelfLink(mfLink,shortUriName);
    end
end

function updateConfirmsLinks(this,mfLinkSet,linkTypeMap)


    mfLinks=mfLinkSet.links.toArray;
    for n=1:length(mfLinks)
        mfLink=mfLinks(n);
        if strcmp(mfLink.typeName,'Confirm')
            mfLink.typeName='Verify';

        end
    end
end

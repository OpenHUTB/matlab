function applyStereotypeAndCopyValues(srcArchElem,dstArchElem,dstModel)







    currStereos=srcArchElem.getStereotypes();
    if(isempty(currStereos))
        return;
    end
    srcMfModel=mf.zero.getModel(srcArchElem.getImpl);
    srcModel=systemcomposer.internal.getWrapperForImpl(...
    systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(srcMfModel));
    importProfilesNeededBySrcStereotypes(currStereos,srcModel,dstModel);


    for sIdx=1:length(currStereos)
        s=currStereos{sIdx};
        dstArchElem.applyStereotype(s);
    end


    for sIdx=1:length(currStereos)
        sName=currStereos{sIdx};
        currStereo=systemcomposer.profile.Stereotype.find(sName);
        copyProperties(currStereo,srcArchElem,dstArchElem);
    end
end


function importProfilesNeededBySrcStereotypes(stereos,srcM,dstM)

    profiles=cell(1,length(stereos));
    for idx=1:length(stereos)
        s=stereos{idx};
        profile=strtok(s,'.');
        profiles{idx}=profile;
    end
    profiles=unique(profiles);

    for idx=1:length(profiles)
        profile=profiles{idx};
        dstM.applyProfile(profile);

        srcProfileObject=srcM.getImpl.getProfile(profile);
        for parentProfileName=srcProfileObject.getDependentProfiles
            dstM.applyProfile(parentProfileName{1});
        end
    end

end


function copyProperties(stereo,src,dst)


    props=stereo.OwnedProperties;
    for idx=1:length(props)
        prop=props(idx);
        propFqn=[stereo.FullyQualifiedName,'.',prop.Name];
        if~src.isPropertyValueDefault(propFqn)
            [val,unit]=src.getProperty(propFqn);
            dst.setProperty(propFqn,val,unit);
        end
    end

    if~isempty(stereo.Parent)
        copyProperties(stereo.Parent,src,dst);
    end

end








function cfg=mCodeGenerationConfig(obj)














    cfg=struct();
    cfg.CreationMethod='Accessor';
    cfg.SectionHeader=[];
    cfg.InstanceHeader=[];
    cfg.VarName=[];
    cfg.IncludeParentName=false;


    m=meta.class.fromName(class(obj));
    propList=m.PropertyList;
    propList={propList(strcmpi('public',{propList.SetAccess})&~[propList.Hidden]).Name};



    for f=1:length(propList)
        thisPropName=propList{f};
        thisPropVal=obj.(thisPropName);
        if iscell(obj.(thisPropName))
            for o=1:length(thisPropVal)
                if isobject(thisPropVal{o})
                    cfg.(thisPropName){o}=wirelessWaveformGenerator.internal.mCodeGenerationConfig(thisPropVal{o});
                end
            end
        elseif isobject(thisPropVal)
            cfg.(thisPropName)=wirelessWaveformGenerator.internal.mCodeGenerationConfig(thisPropVal);
        end
    end

end
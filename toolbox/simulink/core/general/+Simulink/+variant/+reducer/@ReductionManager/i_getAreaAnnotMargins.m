





function annotationAreaObjVec=i_getAreaAnnotMargins(optArgs)




    annotationAreaObjVec=Simulink.internal.variantlayout.AnnotationArea.empty;
    areaId=1;
    for mdlId=1:numel(optArgs.ModelRefModelInfoStructsVec)
        mdlName=optArgs.ModelRefModelInfoStructsVec(mdlId).Name;
        populateAreaAnots(mdlName);
    end

    for libId=1:numel(optArgs.LibInfoStructsVec)
        libName=optArgs.LibInfoStructsVec(libId).Name;
        populateAreaAnots(libName);
    end

    function populateAreaAnots(mdlName)

        annotations=find_system(mdlName,'FindAll','on',...
        'MatchFilter',@Simulink.match.allVariants,'Type','annotation');
        for anotId=1:numel(annotations)
            annotationObject=get(annotations(anotId),'Object');
            if strcmp(annotationObject.AnnotationType,'area_annotation')


                blks=find_system(annotationObject.Parent,'SearchDepth','1',...
                'LookUnderMasks','on','MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');
                annotationAreaObjVec(areaId)=...
                Simulink.internal.variantlayout.AnnotationArea(annotationObject,blks(2:end));
                areaId=areaId+1;
            end
        end
    end
end

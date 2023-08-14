





function i_removeAnnotationInVSS(varBlockPath)







    annotationsInVSSQueryByTag=find_system(varBlockPath,...
    'LookUnderMasks','all',...
    'FindAll','On',...
    'SearchDepth',1,...
    'MatchFilter',@Simulink.match.allVariants,...
    'Type','Annotation',...
    'Tag','VSSAddChoiceText');


    delete(annotationsInVSSQueryByTag);



    annotationsInVSSQueryByName=find_system(varBlockPath,...
    'LookUnderMasks','all',...
    'SearchDepth',1,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FindAll','On',...
    'Type','Annotation');




    defaultAnnotationInVSSNames=getVSSDefaultAnnotationName();




    for i=1:numel(annotationsInVSSQueryByName)
        thisAnnotationName=get(annotationsInVSSQueryByName(i),'Name');

        findIndexOfMatch=@(X)(strfind(thisAnnotationName,X));
        indicesOfMatch=cellfun(findIndexOfMatch,defaultAnnotationInVSSNames,'UniformOutput',false);
        isNonEmptyIndices=cellfun(@isempty,indicesOfMatch);


        if~all(isNonEmptyIndices)
            delete(annotationsInVSSQueryByName(i));
        end
    end

end







function defaultAnnotationNames=getVSSDefaultAnnotationName()

    defaultAnnotationNames=cell(1,2);

    defaultAnnotationNames{1}='href="matlab://addvsschoiceddg_cb(gcs,''ModelReference'')';

    defaultAnnotationNames{2}=['1) Only subsystems can be added as variant choices at this level',newline...
    ,'2) Blocks cannot be connected at this level as connectivity is',newline...
    ,'automatically determined at simulation, based on the active variant'];
end



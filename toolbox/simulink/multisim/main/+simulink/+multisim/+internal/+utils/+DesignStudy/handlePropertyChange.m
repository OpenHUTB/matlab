function handlePropertyChange(~,designStudyElement,propertyName,modelHandle)


    if strcmp(propertyName,"SelectedForRun")
        designSuite=designStudyElement.Container;
        designStudies=designSuite.DesignStudies.toArray();

        for designStudyIdx=1:numel(designStudies)
            if designStudies(designStudyIdx)~=designStudyElement
                designStudies(designStudyIdx).SelectedForRun=false;
            end
        end

        simulink.multisim.internal.setRunAllContext(modelHandle);
    end
end
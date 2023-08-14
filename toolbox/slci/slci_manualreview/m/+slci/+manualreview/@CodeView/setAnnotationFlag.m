


function setAnnotationFlag(~,cv,flag)
    if~isempty(cv)
        comp=cv.getComponent;
        if~isempty(comp)
            comp.getSource.toggleAnnotation(flag);
        end
    end
end
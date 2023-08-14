function gr_preCreateAction(this,gm,varargin)






    if strcmp(this.ViewportType,'none')
        stretchRatio=1;

    else

        stretchRatio=mean(this.RuntimeViewportSize./this.RuntimeSize);
    end

    nPointers=length(this.RuntimePointers);
    for i=1:nPointers

        pointer=this.RuntimePointers(i);
        for j=1:length(pointer.Areas)
            areaSpec=addArea(gm,...
            round(pointer.Areas{j}*stretchRatio),...
            pointer.LinkID);
        end

        addCallout(gm,areaSpec,pointer.DisplayText);

    end


function selectionChangedOnCanvas(this,~,selectionEvent)





    sourceObject=selectionEvent.Source;
    if isempty(sourceObject)
        return;
    end


    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if isempty(studios)||(studios(1)~=this.hStudio)
        return;
    end

    if contains(class(sourceObject),'Stateflow.')
        selectionH=sourceObject.Id;
        modelH=this.getSfLibInstanceParentModel();
        if isempty(modelH)
            modelH=get_param(bdroot(sourceObject.Machine.Path),'handle');
        end
    else
        selectionH=sourceObject.Handle;
        if(selectionH<=0)
            return;
        end
        modelH=get_param(bdroot(selectionH),'handle');
    end




    urlStr=this.getContent(modelH,selectionH,false);
    if~isempty(urlStr)





        this.url='';
        this.refresh();
        this.navigate(urlStr);
    end
end

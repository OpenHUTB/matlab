function showLegend(this,mdlName)



    studioTab_cont=find(strcmp(mdlName,this.modelList));
    if(isempty(studioTab_cont))
        addModel(this,mdlName);
        studioTab_cont=find(strcmp(mdlName,this.modelList));
    end
    studioTab_cont=studioTab_cont(1);

    this.modelLegendState{studioTab_cont}='on';
    st=this.studio{studioTab_cont};

    stApp=st.App;
    activeEditor=stApp.getActiveEditor;
    blockDiagramHandle=activeEditor.blockDiagramHandle;
    currentModelName=getfullname(blockDiagramHandle);
    topLevelModel=getfullname(stApp.topLevelDiagram.handle);

    if(~any(strcmp(currentModelName,this.modelList)))
        addModel(this,currentModelName);
    end

    this.studioDiagramMap(num2str(st.App.blockDiagramHandle))=st.App.getActiveEditor.blockDiagramHandle;
    this.launchDDGSpreadSheet(topLevelModel,currentModelName);

    c=st.getService('GLUE2:ActiveEditorChanged');
    registerCallbackId=c.registerServiceCallback(@this.handleEditorChanged);%#ok<NASGU>

end

function handleEditorChanged(this,cbinfo,ev)%#ok<DEFNU>

    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    newModel=false;

    if(~isempty(studios))
        st=studios(1);
        stApp=st.App;
        activeEditor=stApp.getActiveEditor;
        blockDiagramHandle=activeEditor.blockDiagramHandle;
        currentLevelModel=getfullname(blockDiagramHandle);


        if(~any(strcmp(currentLevelModel,this.modelList)))
            addModel(this,currentLevelModel);
            newModel=true;
        end

        topLevelModel=getfullname(stApp.topLevelDiagram.handle);
        studioTab_cont=find(strcmp(topLevelModel,this.modelList),1);

        viewChangeAcrossModelRef=~isequal(st.App.getActiveEditor.blockDiagramHandle,this.studioDiagramMap(num2str(st.App.blockDiagramHandle)));

        if(viewChangeAcrossModelRef)
            this.clearHilite(currentLevelModel);
        end

        if((newModel||viewChangeAcrossModelRef)...
            &&isequal(this.modelLegendState{studioTab_cont},'on'))
            this.studioDiagramMap(num2str(st.App.blockDiagramHandle))=st.App.getActiveEditor.blockDiagramHandle;
            this.launchDDGSpreadSheet(topLevelModel,currentLevelModel);
        end
    end
end

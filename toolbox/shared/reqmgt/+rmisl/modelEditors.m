function out=modelEditors(model,activeEdtrOnly,includeHarness)

    if nargin<2
        activeEdtrOnly=false;
    end

    if nargin<3
        includeHarness=false;
    end

    try
        if ischar(model)
            modelName=model;
        else
            modelName=get_param(model,'Name');
        end
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        modelHandle=get_param(model,'Handle');

        if includeHarness
            if strcmp(get_param(modelHandle,'IsHarness'),'on')
                ownerName=get_param(modelHandle,'OwnerBDName');
                ownerHandle=get_param(ownerName,'Handle');

                harnessHandle=modelHandle;
            else

                ownerHandle=modelHandle;
                try
                    harnessInfo=sltest.harness.find(modelName,'OpenOnly','on');
                catch ex
                    harnessInfo=[];
                end
                if~isempty(harnessInfo)
                    harnessName=harnessInfo.name;
                    harnessHandle=get_param(harnessName,'Handle');
                else

                    harnessHandle=-1;
                end

            end
        else
            ownerHandle=modelHandle;

            harnessHandle=-1;
        end

        allEdtrs=GLUE2.Editor.empty();
        for index=1:length(studios)
            cStudio=studios(index);
            if(cStudio.App.blockDiagramHandle==ownerHandle)||...
                (cStudio.App.blockDiagramHandle==harnessHandle)
                allEdtrs(end+1)=cStudio.App.getActiveEditor;%#ok<AGROW>
            end
        end

        if(isempty(allEdtrs))
            dgm=SLM3I.Util.getDiagram(modelName);
            if~isempty(dgm)
                out=GLUE2.AbstractDomain.findLastActiveEditorForDiagram(dgm.diagram);
            end

            if(isempty(out))
                out=GLUE2.AbstractDomain.findLastActiveEditor();
            end
        elseif(numel(allEdtrs)>1&&activeEdtrOnly)
            edrLastAct=GLUE2.AbstractDomain.findLastActiveEditor();
            if ismember(edrLastAct,allEdtrs)
                out=edrLastAct;
            else
                out=allEdtrs(1);
            end
        else
            out=allEdtrs;
        end

    catch MX
        out=[];
    end
end
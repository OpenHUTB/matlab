classdef PositionManager<handle




    properties(Access=private)
        ModelsToHighlight;
        ModelPositionIDs;
    end


    methods(Access=public,Static)

        function obj=getInstance()
            persistent instance
            if isempty(instance)
                obj=slxmlcomp.internal.highlight.PositionManager();
                instance=obj;
            else
                obj=instance;
            end
        end

    end


    methods(Access=public)

        function obj=PositionManager()
            obj=obj@handle;
            obj.ModelsToHighlight=containers.Map();
            obj.ModelPositionIDs=containers.Map();
        end

        function highlight(obj,type,itemPath,layoutRetriever,positionID,file,report,slEditorStyler)

            layout=eval(layoutRetriever);

            if nargin<6||isempty(file)


                file=obj.getFileFromPath(itemPath);
            end

            if nargin>6&&~isempty(report)
                obj.moveReport(report,layout.getReportPosition());
            end

            if nargin<8
                slEditorStyler=createEditorStyler();
            end

            if isempty(file)
                key=strtok(itemPath,'/');
            else
                key=file;
            end
            obj.addModelToHighlight(key,layout,positionID,slEditorStyler);

            highlighter=obj.getHighlighter(key);
            highlighter.highlightLocation(type,itemPath);

        end

        function hideAndReset(obj,file)

            [~,modelName,~]=fileparts(file);
            if bdIsLoaded(modelName)&&obj.ModelsToHighlight.isKey(file)
                highlighter=obj.ModelsToHighlight(file);
                highlighter.pHide();
            end
            obj.resetFile(file);

        end

        function clear(obj)
            models=obj.ModelsToHighlight.keys();
            for index=1:numel(models)
                obj.resetFile(models{index});
            end
        end

        function files=getFiles(obj)
            files=obj.ModelsToHighlight.keys();
        end

        function highlighter=getHighlighter(obj,file)
            highlighter=obj.ModelsToHighlight(file);
        end

        function bool=hasHighlighter(obj,file)
            bool=any(strcmp(obj.ModelsToHighlight.keys(),file));
        end

        function positionID=getPositionID(obj,file)
            positionID=obj.ModelPositionIDs(file);
        end

    end


    methods(Access=private)

        function addModelToHighlight(obj,filePath,layout,positionID,slEditorStyler)
            if~obj.ModelsToHighlight.isKey(filePath)
                defaultPositions=layout.getDefaultPositions(positionID);

                obj.ModelsToHighlight(filePath)=...
                slxmlcomp.internal.highlight.Highlighter(defaultPositions,slEditorStyler);
                obj.ModelPositionIDs(filePath)=positionID;
            end
        end

        function resetFile(obj,file)
            if(obj.ModelsToHighlight.isKey(file))
                highlighter=obj.ModelsToHighlight(file);
                highlighter.pUnhighlight;
                highlighter.pCloseWindowsUponReset;
                delete(highlighter);
                obj.ModelsToHighlight.remove(file);
                obj.ModelPositionIDs.remove(file);
            end
        end

        function moveReport(~,report,reportPosition)
            slxmlcomp.internal.highlight.setReportWindowPosition(report,reportPosition);
        end

        function file=getFileFromPath(~,path)
            fileName=strtok(path,'/');
            file=get_param(fileName,'FileName');
        end

    end

end

function styler=createEditorStyler()
    styler=slxmlcomp.internal.highlight.SLEditorClassicStyler();
end

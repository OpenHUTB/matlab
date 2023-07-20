classdef UIManager<handle




    properties(GetAccess=private,SetAccess=immutable)
SWSpreadsheetMap
    end

    properties(Constant)
        Instance=swarch.internal.spreadsheet.UIManager;
    end

    methods(Access=private)
        function obj=UIManager()
            obj.SWSpreadsheetMap=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods
        function ss=getSpreadsheet(this,studio)

            ss=[];
            data=this.getSpreadsheetData(studio);
            if~isempty(data)
                ss=data.Spreadsheet;
            end
        end

        function createSpreadsheet(this,studio,domainStr)

            ss=swarch.internal.spreadsheet.SoftwareModelingSpreadSheet(studio,domainStr);

            c=studio.getService('GLUE2:StudioClosed');
            callbackId=c.registerServiceCallback(@(~)handleStudioClosed(studio));
            newData=struct('Spreadsheet',ss,'ID',callbackId);

            modelH=studio.App.blockDiagramHandle;
            if this.SWSpreadsheetMap.isKey(modelH)
                newData=[newData;this.SWSpreadsheetMap(modelH)];
            end
            this.SWSpreadsheetMap(modelH)=newData;
        end

        function destroySpreadsheet(this,studio)

            if~isvalid(studio)
                return;
            end

            data=this.getSpreadsheetData(studio);
            modelH=studio.App.blockDiagramHandle;
            if~isempty(data)
                allSSData=this.SWSpreadsheetMap(modelH);
                newData=allSSData(...
                [allSSData.Spreadsheet.getStudio()]~=data.Spreadsheet.getStudio());
                c=studio.getService('GLUE2:StudioClosed');
                c.unRegisterServiceCallback(data.ID);
                delete(data.Spreadsheet);
                if isempty(newData)
                    this.SWSpreadsheetMap.remove(modelH);
                else
                    this.SWSpreadsheetMap(modelH)=newData;
                end

            end
        end

        function tf=hasSpreadsheets(this,modelH)


            tf=this.SWSpreadsheetMap.isKey(modelH);
        end
    end

    methods(Access=private)
        function data=getSpreadsheetData(this,studio)

            data=[];
            modelH=studio.App.blockDiagramHandle;
            if this.SWSpreadsheetMap.isKey(modelH)
                allSSData=this.SWSpreadsheetMap(modelH);
                for idx=1:numel(allSSData)
                    if allSSData(idx).Spreadsheet.getStudio()==studio
                        data=allSSData(idx);
                        break;
                    end
                end
            end
        end
    end
end

function handleStudioClosed(studio)
    mgr=swarch.internal.spreadsheet.UIManager.Instance;
    mgr.destroySpreadsheet(studio);
end

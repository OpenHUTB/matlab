



classdef ViewerGeneratorSpreadsheet<handle
    properties(SetAccess=private,GetAccess=public)
        mDlg=[];
        mBlockDiagramHandle=[];

        mModelName=[];
        mType=[];
        mCurrentViewerSelection=[];
    end

    methods
        function this=ViewerGeneratorSpreadsheet(dlg,blockDiagramHandle,type)
            this.mDlg=dlg;
            this.mBlockDiagramHandle=blockDiagramHandle;



            this.mModelName=get_param(this.mBlockDiagramHandle,'name');
            this.mType=type;
        end

        function aChildren=getChildren(this)
            aChildren=Simulink.scopes.SigScopeMgrUtil.internal.ViewerGeneratorSpreadsheetRow.empty;



            if strcmpi(this.mType,'viewers')
                objs=sigandscopemgr('GetViewers',this.mBlockDiagramHandle);
            elseif strcmpi(this.mType,'generators')
                objs=sigandscopemgr('GetGenerators',this.mBlockDiagramHandle);
            end



            if(this.mBlockDiagramHandle==this.mDlg.mBlockDiagramHandle)
                if strcmpi(this.mType,'viewers')&&~isempty(this.mDlg.viewerSpreadsheetData)&&(numel(objs)==numel(this.mDlg.viewerSpreadsheetData))
                    aChildren=this.mDlg.viewerSpreadsheetData;
                elseif strcmpi(this.mType,'generators')&&~isempty(this.mDlg.generatorSpreadsheetData)&&(numel(objs)==numel(this.mDlg.generatorSpreadsheetData))
                    aChildren=this.mDlg.generatorSpreadsheetData;
                end
            end

            if isempty(aChildren)
                for objIdx=1:length(objs)
                    obj=objs{objIdx};
                    aChildren(objIdx)=Simulink.scopes.SigScopeMgrUtil.internal.ViewerGeneratorSpreadsheetRow(obj,this.mDlg);
                end




                if strcmpi(this.mType,'viewers')
                    this.mDlg.viewerSpreadsheetData=aChildren;
                elseif strcmpi(this.mType,'generators')
                    this.mDlg.generatorSpreadsheetData=aChildren;
                end
            end
        end
    end
end


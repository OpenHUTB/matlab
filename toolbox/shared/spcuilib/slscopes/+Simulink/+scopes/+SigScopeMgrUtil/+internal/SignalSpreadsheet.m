



classdef SignalSpreadsheet<handle
    properties(SetAccess=private,GetAccess=public)
        mDlg=[];
        mBlockDiagramHandle=[];
    end

    methods
        function this=SignalSpreadsheet(dlg,blockDiagramHandle)
            this.mDlg=dlg;
            this.mBlockDiagramHandle=blockDiagramHandle;
        end

        function aChildren=getChildren(this)

            aChildren=Simulink.scopes.SigScopeMgrUtil.internal.SignalSpreadsheetRow.empty;


            selectedViewGen=this.mDlg.getSelectedViewerGenerator();
            if(~isempty(selectedViewGen)&&ishandle(selectedViewGen))








                [numChannels,selNamesByChan,selHdlsByChan]=sigandscopemgr('GetSelectionData',selectedViewGen);

                rowCount=0;
                for channel=1:numChannels
                    selNames=selNamesByChan{channel};
                    selHdls=selHdlsByChan{channel};

                    if(~isempty('selNames')&&(length(selNames)==length(selHdls)))
                        for selIdx=1:length(selNames)
                            rowCount=rowCount+1;

                            aChildren(rowCount)=Simulink.scopes.SigScopeMgrUtil.internal.SignalSpreadsheetRow(...
                            channel,selNames{selIdx},selHdls(selIdx),selectedViewGen);


                            this.setColumnName(aChildren(rowCount),selectedViewGen);
                        end
                    else
                        rowCount=rowCount+1;
                        aChildren(rowCount)=Simulink.scopes.SigScopeMgrUtil.internal.SignalSpreadsheetRow(channel,DAStudio.message('Simulink:blocks:SSMgrNoSelection'),selectedViewGen);
                        this.setColumnName(aChildren(rowCount),selectedViewGen);
                    end
                end
            end




            this.mDlg.setSignalSpreadsheetChildren(aChildren);
        end

        function setColumnName(this,aChild,selectedViewGen)




            if strcmpi(get_param(selectedViewGen,'IOType'),'siggen')
                aChild.setDisplayColumn(getString(message('Spcuilib:scopes:SSMgrOutput')));
            else
                if strcmp(get_param(this.mDlg.mSelectedViewer,'BlockType'),'Scope')
                    aChild.setDisplayColumn(getString(message('Spcuilib:scopes:SSMgrDisplay')));
                else
                    aChild.setDisplayColumn(getString(message('Spcuilib:scopes:SSMgrInput')));
                end
            end
        end
    end
end


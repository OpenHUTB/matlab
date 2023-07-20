classdef SfReqView<handle






    properties(Constant)

        sourceID='standalone';
        displayComment=true;
        displayChangeInformation=true;
    end

    methods
        function setSelectedObject(~,~)
        end

        function out=getViewSettingID(this)
            out=this.sourceID;
        end

        function tf=isVisible(~)
            tf=true;
        end

        function st=getStudio(~)
            st=[];
        end


        function tf=isReqViewActive(~)
            tf=true;
        end

        function show(~)

        end

        function open(~)

        end

        function close(~)
        end

        function tf=isNotificationVisible(~)
            tf=false;
        end

        function showNotification(~)
        end

        function update(~)
        end

        function refreshUI(~,~)
        end

        function updateToolbar(~)
        end

        function updateToolstrip(~)
        end

        function setUISleep(~,~)
        end

        function obj=getCurrentSelection(~)
            obj=[];
        end

        function stat=getSelectionStatus(~)
            stat=slreq.gui.SelectionStatus.None;
        end
        function r=getRoot(~)
            r=[];
        end
        function clearCurrentObj(~,~,~)
        end

        function toggleOnImplementationStatus(~)
        end

        function toggleOffImplementationStatus(~)
        end

        function toggleOnVerificationStatus(~)
        end

        function toggleOffVerificationStatus(~)
        end

        function toggleOnChangeInformation(~)
        end

        function toggleOffChangeInformation(~)
        end

        function updateColumnOnCustomAttributeNameChange(~,~,~)
        end

        function updateColumnOnCustomAttributeRemoval(~,~)
        end

        function resetViewSettings(~)
        end

        function tf=isSortDisabled(~)
            tf=true;
        end

        function expand(~,~)

        end

        function expandAll(~,~)
        end

        function collapseAll(~,~)
        end

        function restoreViewSettings(~)
        end

        function[reqWidth,linkWidth]=getColumnWidths(~)
            reqWidth=[];
            linkWidth=[];
        end

        function currentWidth=getCurrentColumnWidths(~)
            currentWidth=[];
        end

        function restoreColumnWidth(~,~)
        end

        function dlg=getDialog(~)
            dlg=[];
        end

        function dlg=getBannerDlg(~)
            dlg=[];
        end

        function switchToCurrentView(~)
        end

        function switchView(~)
        end

        function setDisplayComment(~,~)
        end
    end
end

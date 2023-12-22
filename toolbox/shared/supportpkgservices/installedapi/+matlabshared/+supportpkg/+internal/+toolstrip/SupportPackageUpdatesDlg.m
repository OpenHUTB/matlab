classdef SupportPackageUpdatesDlg<handle


    properties(GetAccess=private,SetAccess=immutable)
Figure
Table
Data
PkgStruct
UpdateBtn
CancelBtn
DescriptionText
    end

    properties(Constant)

        FIGURE_POSITION=[100,200,770,270];
        TABLE_POSITION=[20,55,730,150];
        DESC_TEXT_POSITION=[20,210,540,40];
        UPDATE_BTN_POSITION=[540,20,100,30];
        CANCEL_BTN_POSITION=[650,20,100,30];
        FIGURE_TAG='SUPPORTPKG_UPDATE_DLG';
    end

    methods
        function obj=SupportPackageUpdatesDlg(pkgStruct,spPkgType)

            validTypes={'hardware','software'};

            validatestring(spPkgType,validTypes);
            validateattributes(pkgStruct,{'struct'},{'nonempty'});

            if strcmp(spPkgType,'hardware')
                descriptionText=message('supportpkgservices:matlabshared:CheckForUpdateDlgDescriptionHSP').getString;
                nameColumnLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgNameColumnLabelHSP').getString;
            else
                descriptionText=message('supportpkgservices:matlabshared:CheckForUpdateDlgDescriptionAddOnFeature').getString;
                nameColumnLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgNameColumnLabelAddOnFeature').getString;
            end
            installedVersionColLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgInstalledVersionColLabel').getString;
            availableVersionColLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgAvailableVersionColLabel').getString;
            updateButtonLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgUpdateBtnLabel').getString;
            cancelbuttonLabel=message('supportpkgservices:matlabshared:CheckForUpdateDlgCancelBtnLabel').getString;


            obj.PkgStruct=pkgStruct;
            obj.Data=obj.getCellDataFromPkgDataStruct(pkgStruct);
            obj.Figure=uifigure('deletefcn',@(~,~)delete(obj),...
            'Visible','off',...
            'Toolbar','none',...
            'MenuBar','none',...
            'Name',message('supportpkgservices:matlabshared:CheckForUpdateDlgTitle').getString,...
            'NumberTitle','off',...
            'Resize','off',...
            'Position',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.FIGURE_POSITION,...
            'Tag',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.FIGURE_TAG);


            movegui(obj.Figure,'center');
            matlabshared.supportpkg.internal.toolstrip.util.setFigureIconToMembrane(obj.Figure);
            obj.Table=uitable(obj.Figure,'Data',obj.Data,...
            'ColumnWidth',{20,380,150,150},...
            'Position',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.TABLE_POSITION,...
            'ColumnEditable',[true,false,false,false],...
            'ColumnName',{'',nameColumnLabel,installedVersionColLabel,availableVersionColLabel},...
            'CellSelectionCallback',@(widget,evtdata)obj.rowSelectionCallback(widget,evtdata),...
            'CellEditCallback',@(widget,evtdata)obj.rowSelectionCallback(widget,evtdata),...
            'SelectionHighlight','off');
            obj.DescriptionText=uilabel(obj.Figure,'text',descriptionText,...
            'Position',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.DESC_TEXT_POSITION,...
            'HorizontalAlignment','left');


            if isunix
                obj.Figure.Position=obj.Figure.Position+[0,0,0,25];
                obj.DescriptionText.Position=obj.DescriptionText.Position+[0,8,0,25];
            end
            obj.UpdateBtn=uibutton(obj.Figure,'push',...
            'text',updateButtonLabel,...
            'Position',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.UPDATE_BTN_POSITION,...
            'ButtonPushedFcn',@(widget,evtdata)obj.updateBtnCallback(),...
            'Enable','off');
            obj.CancelBtn=uibutton(obj.Figure,'push',...
            'text',cancelbuttonLabel,...
            'Position',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.CANCEL_BTN_POSITION,...
            'ButtonPushedFcn',@(~,~)delete(obj));

            obj.Figure.Visible='on';
        end


        function delete(obj)
            if isvalid(obj.Figure)
                delete(obj.Figure);
            end
        end


        function updateBtnCallback(obj)
            checkedRows=cell2mat(obj.Table.Data(:,1));
            selectedPkgs=obj.PkgStruct(checkedRows);
            baseCodes={selectedPkgs.BaseCode};
            matlabshared.supportpkg.internal.toolstrip.util.launchSSIForUpdate(baseCodes);


            obj.delete();
        end


        function rowSelectionCallback(obj,widget,eventdata)

            if isempty(eventdata.Indices)
                return;
            end

            if eventdata.Indices(2)~=1
                widget.Data{eventdata.Indices(1),1}=~widget.Data{eventdata.Indices(1),1};
            end

            if any(cell2mat(widget.Data(:,1)))
                obj.UpdateBtn.Enable='on';
            else
                obj.UpdateBtn.Enable='off';
            end
        end
    end


    methods(Static)
        function outputCell=getCellDataFromPkgDataStruct(pkgData)

            validateattributes(pkgData,{'struct'},{'nonempty'});
            outputCell=[];
            for i=1:numel(pkgData)

                rowData={false,pkgData(i).Name,pkgData(i).InstalledVersion,pkgData(i).LatestVersion};
                outputCell=[outputCell;rowData];%#ok<AGROW>
            end
        end
    end

end

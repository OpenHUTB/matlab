classdef MemoryMapView<handle




    properties(SetObservable=true)
memoryMapInfo
memPSCtrlBaseAddr
memPSCtrlRange
memPLCtrlBaseAddr
memPLCtrlRange
memText
        mapTblSource=[];
        ipTblSource=[];
        tblRegWidget=[];
        tblMapWidget=[];
        ipCoreRegs={};
        showReservedReg(1,1)logical=true;
        widgetVisible(1,1)logical=true;
        currentMemSel='';
    end
    properties(Constant)
        description=message('soc:memmap:MapperTopDescription').getString();
        boardTitle{matlab.internal.validation.mustBeASCIICharRowVector(boardTitle,'boardTitle')}='Hardware Board: ';
    end
    methods

        function obj=MemoryMapView(memoryMapInfo)
            obj.memoryMapInfo=memoryMapInfo;

            obj.memPSCtrlBaseAddr=obj.memoryMapInfo.controllerInfo.memPSBaseAddr;
            obj.memPSCtrlRange=sprintf('%s %sB',obj.memoryMapInfo.controllerInfo.memPSRange{:});

            obj.memPLCtrlBaseAddr=obj.memoryMapInfo.controllerInfo.memPLBaseAddr;
            obj.memPLCtrlRange=sprintf('%s %sB',obj.memoryMapInfo.controllerInfo.memPLRange{:});

            obj.tblMapWidget.Type='spreadsheet';
            obj.tblMapWidget.Tag='MapTable';
            obj.tblMapWidget.Config='{"enablemultiselect":false}';

            obj.tblMapWidget.Columns={soc.memmap.MemUtil.strDevType,soc.memmap.MemUtil.strDevName,soc.memmap.MemUtil.strDevBase,soc.memmap.MemUtil.strDevRange};
            obj.mapTblSource=soc.memmap.MapSource;
            obj.mapTblSource.initData(obj.memoryMapInfo.mmap.map,obj.memoryMapInfo.mmap.isFixedMemMap);
            obj.tblMapWidget.Source=obj.mapTblSource;
            obj.tblMapWidget.SelectionChangedCallback=@(tag,sels,dlg)SelectionChangedCB(tag,sels,dlg);
            obj.tblMapWidget.ValueChangedCallback=@(tag,sels,propName,propVal,dlg)ValueChangedMemCB(tag,sels,propName,propVal,dlg);


            obj.tblRegWidget.Type='spreadsheet';
            obj.tblRegWidget.Tag='IPTable';
            obj.tblRegWidget.Columns={soc.memmap.MemUtil.strRegType,soc.memmap.MemUtil.strRegName,soc.memmap.MemUtil.strRegOffset,soc.memmap.MemUtil.strRegVL};
            obj.tblRegWidget.ValueChangedCallback=@(tag,sels,propName,propVal,dlg)ValueChangedRegCB(tag,sels,propName,propVal,dlg);

            obj.ipTblSource=soc.memmap.IPSource;
            obj.tblRegWidget.Source=obj.ipTblSource;

        end

        function dlgStruct=getDialogSchema(obj)

            dlgStruct.LayoutGrid=[7,3];
            dlgStruct.ColStretch=[1,0,0];
            currRow=0;

            currRow=currRow+1;
            obj.ipTblSource.initData(obj.ipCoreRegs);
            firstText.Type='text';
            firstText.WordWrap=true;
            firstText.Name=obj.description;
            firstText.Tag='TextOverallDescription';
            firstText.RowSpan=[currRow,currRow];
            firstText.ColSpan=[1,2];



...
...
...
...
...
...
...
...
...
...
...
...

            currRow=currRow+1;
            boardLink.Type='hyperlink';
            boardLink.ObjectMethod='boardLinkClicked';
            boardLink.MethodArgs={'%dialog'};
            boardLink.ArgDataTypes={'handle'};
            boardLink.Name=sprintf('%s %s\n',obj.boardTitle,obj.memoryMapInfo.boardName);
            boardLink.Alignment=5;
            boardLink.Tag='LinkboardLink';
            boardLink.RowSpan=[currRow,currRow];
            boardLink.ColSpan=[1,1];




            if obj.memoryMapInfo.FPGADesign.HasPSMemory&&obj.memoryMapInfo.FPGADesign.IncludeProcessingSystem
                currRow=currRow+1;

                memPSCtrlGroup.Type='group';
                memPSCtrlGroup.Name='PS Memory Controller';
                memPSCtrlGroup.Tag='GroupMemPSCtrl';

                if obj.memoryMapInfo.isFixedMemMap
                    memPSCtrlGroup.Visible=0;
                end

                memPSCtrlGroup.RowSpan=[currRow,currRow];
                memPSCtrlGroup.ColSpan=[1,2];
                memPSCtrlGroup.LayoutGrid=[2,2];

                memBaseAddr.Type='edit';
                memBaseAddr.Name='Base Address';
                memBaseAddr.Tag='EditMemPSBaseAddr';
                memBaseAddr.ObjectProperty='memPSCtrlBaseAddr';
                memBaseAddr.Enabled=0;
                memBaseAddr.RowSpan=[1,1];
                memBaseAddr.ColSpan=[1,2];

                memSize.Type='edit';
                memSize.Name='Range';
                memSize.Tag='EditMemPSRange';
                memSize.ObjectProperty='memPSCtrlRange';
                memSize.Enabled=0;
                memSize.RowSpan=[2,2];
                memSize.ColSpan=[1,2];

                memPSCtrlGroup.Items={memBaseAddr,memSize};
            else
                memPSCtrlGroup.Type='group';
                memPSCtrlGroup.Name='PS Memory Controller';
                memPSCtrlGroup.Tag='GroupController';
                memPSCtrlGroup.Visible=0;
            end


            if obj.memoryMapInfo.FPGADesign.HasPLMemory
                currRow=currRow+1;

                memPLCtrlGroup.Type='group';
                memPLCtrlGroup.Name='PL Memory Controller';
                memPLCtrlGroup.Tag='GroupMemPLCtrl';

                if obj.memoryMapInfo.isFixedMemMap
                    memPLCtrlGroup.Visible=0;
                end

                memPLCtrlGroup.RowSpan=[currRow,currRow];
                memPLCtrlGroup.ColSpan=[1,2];
                memPLCtrlGroup.LayoutGrid=[2,2];

                memBaseAddr.Type='edit';
                memBaseAddr.Name='Base Address';
                memBaseAddr.Tag='EditMemPLBaseAddr';
                memBaseAddr.ObjectProperty='memPLCtrlBaseAddr';
                memBaseAddr.Enabled=0;
                memBaseAddr.RowSpan=[1,1];
                memBaseAddr.ColSpan=[1,2];

                memSize.Type='edit';
                memSize.Name='Range';
                memSize.Tag='EditMemPLRange';
                memSize.ObjectProperty='memPLCtrlRange';
                memSize.Enabled=0;
                memSize.RowSpan=[2,2];
                memSize.ColSpan=[1,2];

                memPLCtrlGroup.Items={memBaseAddr,memSize};
            else
                memPLCtrlGroup.Type='group';
                memPLCtrlGroup.Name='PL Memory Controller';
                memPLCtrlGroup.Tag='GroupController';
                memPLCtrlGroup.Visible=0;
            end


            currRow=currRow+1;regionRow=currRow;
            memmapGroup.Type='group';
            memmapGroup.Name='Memory Map';
            memmapGroup.Tag='GroupMemoryMap';
            memmapGroup.RowSpan=[currRow,currRow];
            memmapGroup.ColSpan=[1,2];

            memmapGroup.LayoutGrid=[2,1];

            obj.memText.Type='text';
            obj.memText.Name=message('soc:memmap:MemMapSectionDescription').getString();
            obj.memText.Tag='TextmemmapDescription';
            obj.memText.WordWrap=true;
            obj.memText.RowSpan=[1,1];
            obj.memText.ColSpan=[1,1];
            obj.memText.MaximumSize=[800,40];
            obj.memText.MinimumSize=[800,40];
            obj.tblMapWidget.RowSpan=[2,2];
            obj.tblMapWidget.ColSpan=[1,1];

            memmapGroup.Items={obj.memText,obj.tblMapWidget};


            currRow=currRow+1;
            regGroup.Type='group';
            regGroup.Name='Registers';
            regGroup.Tag='GroupRegisters';
            regGroup.RowSpan=[currRow,currRow];
            regGroup.ColSpan=[1,2];

            regGroup.LayoutGrid=[1,1];
            obj.tblRegWidget.RowSpan=[1,1];
            obj.tblRegWidget.ColSpan=[1,1];

            regGroup.Items={obj.tblRegWidget};


            btnsPanel.Type='panel';
            btnsPanel.Name='Map Controls';
            btnsPanel.Tag='PanelMapControls';
            btnsPanel.RowSpan=[regionRow,regionRow];
            btnsPanel.ColSpan=[3,3];

            btnsPanel.LayoutGrid=[3,1];


            btnCheck.Name='Check Map';
            btnCheck.Tag='BtnCheckMap';
            btnCheck.Type='pushbutton';
            btnCheck.ToolTip=message('soc:memmap:CheckMapTT').getString();
            btnCheck.ObjectMethod='checkMap';
            btnCheck.RowSpan=[1,1];
            btnCheck.ColSpan=[1,1];

            btnReset.Name='Reset Map';
            btnReset.Tag='BtnResetMap';
            btnReset.Type='pushbutton';
            btnReset.ToolTip=message('soc:memmap:ResetMapTT').getString();
            btnReset.ObjectMethod='resetMap';
            btnReset.MethodArgs={'%dialog'};
            btnReset.ArgDataTypes={'handle'};
            btnReset.RowSpan=[2,2];
            btnReset.ColSpan=[1,1];

            btnReconcile.Name='Reconcile Map';
            btnReconcile.Tag='BtnReconcileMap';
            btnReconcile.Type='pushbutton';
            btnReconcile.ToolTip=message('soc:memmap:ReconcileMapTT').getString();
            btnReconcile.ObjectMethod='reconcileMap';
            btnReconcile.MethodArgs={'%dialog'};
            btnReconcile.ArgDataTypes={'handle'};
            btnReconcile.RowSpan=[3,3];
            btnReconcile.ColSpan=[1,1];

            btnsPanel.Items={btnCheck,btnReset,btnReconcile};

            dlgTitle=message('soc:workflow:ReviewMemoryMap_MemMapAppName',getfullname(obj.memoryMapInfo.mdlH)).getString();

            dlgStruct.Items={firstText,boardLink,memPSCtrlGroup,memPLCtrlGroup,memmapGroup,regGroup,btnsPanel};
            dlgStruct.MinMaxButtons=true;
            dlgStruct.DialogTitle=dlgTitle;
            dlgStruct.DialogTag='MemMapMainDialog';
            dlgStruct.PreApplyMethod='PreApply';
            dlgStruct.PreApplyArgs={'%dialog'};
            dlgStruct.PreApplyArgsDT={'handle'};
            dlgStruct.CloseMethod='closeCallback';
            dlgStruct.CloseMethodArgs={'%dialog'};
            dlgStruct.CloseMethodArgsDT={'handle'};

            if obj.needsReconciliation()





                msgbox(message('soc:memmap:MapNeedsReconciliation').getString(),'Memory Map Needs Reconciliation','modal');
            end
        end

        function[isValid,errStr]=PreApply(obj,dhandle)
            [isValid,errStr]=obj.memoryMapInfo.checkMemoryMap;
            if isValid
                obj.memoryMapInfo.writeToModelWorkspace;
            end
        end

        function boardLinkClicked(~,~)
            configObj=getActiveConfigSet(gcs);
            openDialog(configObj);
        end
        function checkMap(obj)
            [isValid,errStr]=obj.memoryMapInfo.checkMemoryMap();
            if isValid
                msgbox(message('soc:memmap:MemoryMapValid').getString(),'Memory Map Valid','modal');
            else
                errordlg(errStr,'Memory Map Error','modal');
            end
        end

        function resetMap(obj,dhandle)
            obj.ipCoreRegs=[];
            obj.mapTblSource.initData([],false);
            obj.ipTblSource.initData([]);
            obj.memoryMapInfo.resetMap;

            obj.mapTblSource.initData(obj.memoryMapInfo.mmap.map,obj.memoryMapInfo.mmap.isFixedMemMap);

            MapTableH=dhandle.getWidgetInterface('MapTable');
            MapTableH.update;
            IPTableH=dhandle.getWidgetInterface('IPTable');
            IPTableH.setEmptyListMessage('No registers to map.');
            IPTableH.update;

            dhandle.enableApplyButton(true);

        end
        function reconcileMap(obj,dhandle)
            obj.ipCoreRegs=[];
            obj.mapTblSource.initData([],false);
            obj.ipTblSource.initData([]);
            newAutoMap=soc.memmap.genAutoMap(obj.memoryMapInfo.mdlH);
            obj.memoryMapInfo.reconcileMap(newAutoMap);

            obj.mapTblSource.initData(obj.memoryMapInfo.mmap.map,obj.memoryMapInfo.mmap.isFixedMemMap);

            MapTableH=dhandle.getWidgetInterface('MapTable');
            MapTableH.update;
            IPTableH=dhandle.getWidgetInterface('IPTable');
            IPTableH.setEmptyListMessage('No registers to map.');
            IPTableH.update;

            dhandle.enableApplyButton(true);
        end
    end
    methods(Access=private)
        function tf=needsReconciliation(obj)
            tf=obj.memoryMapInfo.needsReconciliation();
        end
    end
end

function r=ValueChangedMemCB(~,selections,~,propval,dhandle)
    formatvalid=soc.memmap.MemoryMap.checkAddressFormat(propval);
    if formatvalid
        selections{1}.source.baseAddr=propval;
        tmp=dhandle.getDialogSource();
        tmpmap=tmp.memoryMapInfo.mmap.map;
        tmpobj=findobj(tmpmap,'name',selections{1}.source.name);
        tmpobj.baseAddr=propval;
        if strcmp(selections{1}.source.name,'VDMA Frame Buffer Write')
            tmpobj=findobj(tmpmap,'name','VDMA Frame Buffer Read');
            tmpobj.baseAddr=l_dec2hexAddr(l_hex2decAddr(propval)+l_str2decRange(tmpobj.range));
        end
        MapTableH=dhandle.getWidgetInterface('MapTable');
        MapTableH.update;
    end
    r=true;
end

function r=ValueChangedRegCB(~,selections,~,propval,dhandle)

    valid=soc.memmap.MemoryMap.checkOffsetFormat(propval);
    if valid
        selections{1}.source.offset=propval;
        IPTableH=dhandle.getWidgetInterface('IPTable');
        IPTableH.update;
    end
    r=true;
end
function r=SelectionChangedCB(tag,selections,dhandle)
    srcObj=dhandle.getDialogSource();
    srcObj.currentMemSel=selections{1}.source.name;
    devType=selections{1}.source.type;
    switch devType
    case soc.memmap.MemUtil.strDevUser
        srcObj.ipCoreRegs=selections{1}.source.regs;
        regEmptyMsg='This user IP does not have any registers to map.';
    case soc.memmap.MemUtil.strDevImplicit
        srcObj.ipCoreRegs={};
        regEmptyMsg='Implicit IP registers cannot be moved.';
    case{soc.memmap.MemUtil.strDevPSMemory,soc.memmap.MemUtil.strDevPLMemory}
        srcObj.ipCoreRegs={};
        regEmptyMsg='Memory regions do not have any registers to map.';
    otherwise
        srcObj.ipCoreRegs={};
        regEmptyMsg='No registers to map.';
    end
    srcObj.ipTblSource.initData(srcObj.ipCoreRegs)

    IPTableH=dhandle.getWidgetInterface('IPTable');
    IPTableH.setEmptyListMessage(regEmptyMsg);
    IPTableH.update;

    r=true;
end

function hexAddr=l_dec2hexAddr(decAddr)
    hexAddr=['0x',dec2hex(decAddr,8)];
end

function decAddr=l_hex2decAddr(hexAddr)
    decAddr=uint64(hex2dec(hexAddr));
end


function decRange=l_str2decRange(strRange)
    switch strRange{2}
    case ''
        mult=uint64(1);
    case 'K'
        mult=uint64(1024);
    case 'M'
        mult=uint64(1024*1024);
    case 'G'
        mult=uint64(1024*1024*1024);
    case 'T'
        mult=uint64(1024*1024*1024*1024);
    otherwise
        mult=uint64(1);
    end
    decRange=uint64(str2double(strRange{1})*mult);
end










classdef DESRuntimeInspectorDialog<handle






    properties(Access=private)
        modelHandle;
        dlgInstance={};
        mBlockPath;
        modelName;
        fRunningListener;
        fPauseListener;
        disableFlag;

    end


    methods

        function desRuntimeDlg=DESRuntimeInspectorDialog(blockPath)
            desRuntimeDlg.mBlockPath=blockPath;
            desRuntimeDlg.modelName=bdroot(blockPath);
            desRuntimeDlg.modelHandle=get_param(desRuntimeDlg.modelName,'handle');
            desRuntimeDlg.disableFlag=false;





            desRuntimeDlg.fRunningListener=Simulink.listener(...
            desRuntimeDlg.modelHandle,'EngineSimStatusRunning',@desRuntimeDlg.simRunningHdler);
            desRuntimeDlg.fPauseListener=Simulink.listener(...
            desRuntimeDlg.modelHandle,'EngineSimStatusPaused',@desRuntimeDlg.simPausedHdler);
        end





        function showDESRuntimeDialog(obj,blockPath)
            obj.mBlockPath=blockPath;
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);
            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end



        function deleteDialog(obj,~)
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance=[];
            end
        end



        function simRunningHdler(obj,~,~)

            obj.disableFlag=true;
            if~isempty(obj.dlgInstance)
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end



        function simPausedHdler(obj,~,~)

            obj.disableFlag=false;
            if~isempty(obj.dlgInstance)
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end




        function dlgstruct=getDialogSchema(obj)

            wBlockLabel.Type='text';
            wBlockLabel.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Block');
            wBlockLabel.RowSpan=[1,1];
            wBlockLabel.ColSpan=[1,1];

            wBlockName.Type='hyperlink';
            wBlockName.Name=obj.mBlockPath;
            wBlockName.Value=obj.mBlockPath;
            wBlockName.ObjectMethod='handleClickBlockHyperlink';
            wBlockName.Source=obj;
            wBlockName.MethodArgs={obj.mBlockPath};
            wBlockName.ArgDataTypes={'char'};
            wBlockName.RowSpan=[1,1];
            wBlockName.ColSpan=[2,2];


            rt=simevents.ModelRoot.get(obj.modelHandle);
            blkHdl=getSimulinkBlockHandle(obj.mBlockPath);

            storageNames={};
            if isMatlabDESSysBlockOrChart(obj.mBlockPath)||...
                isQueueBlockWithMultipleStorages(rt,blkHdl)
                for idx=1:length(rt.getBlock(blkHdl).Storage)
                    storageNames(end+1)={rt.getBlock(blkHdl).Storage(idx).Type};
                end
            end

            numEntities=0;
            wTreeItems={};
            for i=1:length(rt.getBlock(blkHdl).Storage)
                entities=rt.getBlock(blkHdl).Storage(i).Entity;
                storageItems={};
                for idx=1:length(entities)
                    numEntities=numEntities+1;
                    entityId=strcat('Element '," ",num2str(entities(idx).ID));
                    if(isstruct(entities(idx).Attributes))
                        attribTree=buildEntityAttributesTree(entities(idx).Attributes);
                        storageItems(end+1:end+2)={entityId,attribTree};
                    elseif(ischar(entities(idx).Attributes))
                        storageItems(end+1)={strcat(entityId,": ",entities(idx).Attributes)};
                    else
                        storageItems(end+1)={strcat(entityId,": ",...
                        mat2str(round(double(entities(idx).Attributes),4)))};
                    end
                end
                if~isempty(storageNames)
                    if~isempty(storageItems)
                        wTreeItems=[wTreeItems,strcat(storageNames(i),...
                        '  (',num2str(length(entities)),')'),{storageItems}];
                    else
                        wTreeItems=[wTreeItems,strcat(storageNames(i),...
                        '  (',num2str(length(entities)),')')];
                    end
                else
                    wTreeItems=[wTreeItems,storageItems];
                end
            end

            if~isMatlabDESSysBlockOrChart(obj.mBlockPath)
                wTreeItems={strcat('Storage',...
                '  (',num2str(numEntities),')'),wTreeItems};
            end


            showTree=true;
            if numEntities==0
                showTree=false;
            end

            wTree.Type='tree';
            wTree.TreeItems=wTreeItems;
            wTree.TreeMultiSelect=false;
            wTree.Enabled=showTree;
            wTree.RowSpan=[5,10];
            wTree.ColSpan=[1,3];
            wTree.Graphical=true;
            wTree.ExpandTree=true;

            dlgstruct.ShowGrid=0;
            dlgstruct.LayoutGrid=[10,3];
            dlgstruct.RowStretch=[0,0,0,0,1,1,1,1,1,1];
            dlgstruct.ColStretch=[0,1,1];
            dlgstruct.Items={wBlockLabel,wBlockName,wTree};
            dlgstruct.DialogTitle=...
            DAStudio.message('SimulinkDiscreteEvent:dialog:DESRuntimeInspector');
            dlgstruct.SmartApply=0;
            dlgstruct.CloseCallback='slde.ddg.CloseDESRuntimeInspectorDialog';
            dlgstruct.CloseArgs={obj.modelName};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.DisableDialog=obj.disableFlag;
        end


        function handleClickBlockHyperlink(obj,blockpath)

            set_param(obj.modelName,'HiliteAncestors','none');
            hilite_system(blockpath,'find');
        end


    end
end

function attribTree=buildEntityAttributesTree(attrib,attribName,attribTree)

    if nargin<3
        attribTree={};
    end

    if isstruct(attrib)
        flds=fields(attrib);
        for idx=1:length(flds)
            fldName=flds{idx};
            fldVal=attrib.(fldName);
            if isstruct(fldVal)
                for idy=1:length(fldVal)
                    tmpAttribTree={};
                    tmpAttribTree=buildEntityAttributesTree(fldVal(idy),fldName,tmpAttribTree);
                    tmpAttribTree={char(fldName),tmpAttribTree};
                    attribTree=[attribTree,tmpAttribTree];
                end
            else
                tmpAttribTree={};
                tmpAttribTree=buildEntityAttributesTree(fldVal,fldName,tmpAttribTree);
                attribTree=[attribTree,tmpAttribTree];
            end

        end
    elseif(ischar(attrib))
        attribTree(end+1)={strcat(char(attribName),": ",attrib)};
    else
        attribTree(end+1)={strcat(char(attribName),": ",mat2str(round(double(attrib),4)))};
    end
end


function is=isMatlabDESSysBlockOrChart(name)


    is=false;
    bType=get_param(name,'BlockType');
    if strcmp(bType,'MATLABDiscreteEventSystem')
        is=true;
    elseif strcmp(bType,'SubSystem')
        hdl=get_param(name,'handle');
        id=sfprivate('block2chart',hdl);
        is=(id>0);
    end
end



function is=isQueueBlockWithMultipleStorages(modelroot,blkHandle)

    is=false;
    bType=get_param(blkHandle,'BlockType');
    if strcmp(bType,'Queue')
        if length(modelroot.getBlock(blkHandle).Storage)>1
            is=true;
        end
    end
end











function varargout=maskeditor(varargin)

    mlock;
    persistent DIALOG_USERDATA;
    persistent DIALOG_SIZE;

    varargout={};

    narginchk(1,Inf);


    aAction=varargin{1};
    aArgs=varargin(2:end);

    if~isempty(aArgs)
        aSystemHandle=get_param(aArgs{1},'Handle');
        if~ishandle(aSystemHandle)
            return;
        end
    end

    bStateChanged=false;
    aStateChangeType=[];

    debug=false;
    idx=find(cellfun(@(x)strcmpi(x,'Debug'),aArgs)==1);
    if~isempty(idx)
        debug=aArgs{idx+1};
    end


    switch(aAction)
    case 'Create'

        aDialog=maskeditor('Get',aSystemHandle);
        if isempty(aDialog)
            aContext.blockHandle=aSystemHandle;
            aContext.isReadOnly=aArgs{2};
            aContext.isMaskOnMask=aArgs{3};
            aContext.isMaskOnModel=aArgs{4};
            aContext.isMaskOnSystemObject=false;

            aSystemObj=get_param(aSystemHandle,'Object');

            if(isa(aSystemObj,'Simulink.MATLABSystem'))
                maskObj=Simulink.Mask.get(aSystemHandle);
                if(~aContext.isMaskOnMask&&isempty(maskObj.BaseMask))
                    aContext.isMaskOnSystemObject=true;
                end
            end


            [bSuccess,aSystemType]=maskeditor.internal.SystemTypeFactory(aContext);
            if~bSuccess
                return;
            end

            aContext.dialogTitle=get_param(aSystemHandle,'name');

            aContext.systemType=aSystemType;

            aDialog=maskeditor.internal.MaskEditorInstance(aContext,debug);

            DIALOG_USERDATA(end+1).SystemHandle=aSystemHandle;
            DIALOG_USERDATA(end).Dialog=aDialog;
            DIALOG_USERDATA(end).PreviewFile='';


            if~isempty(DIALOG_SIZE)
                aDialog.setWindowState(DIALOG_SIZE);
            end
        end

        aDialog.show();

    case{'Get','GetMaskEditor'}
        aDialog=[];
        if~isempty(DIALOG_USERDATA)
            idx=find([DIALOG_USERDATA.SystemHandle]==aSystemHandle);
            if~isempty(idx)
                aDialog=DIALOG_USERDATA(idx).Dialog;
            end
        end

        if length(aArgs)==2
            waitUntilReady=aArgs{2};
            if waitUntilReady&&~isempty(aDialog)
                iLoopCounter=1;
                while iLoopCounter<=30&&~aDialog.isAppReady()
                    pause(0.2);
                    iLoopCounter=iLoopCounter+1;
                end
            end
        end
        varargout{1}=aDialog;

    case 'GetPreviewFile'
        varargout{1}=[];
        if isempty(DIALOG_USERDATA)
            return;
        end
        idx=find([DIALOG_USERDATA.SystemHandle]==aSystemHandle);
        if isempty(idx)
            return;
        end

        aPreviewFile=DIALOG_USERDATA(idx).PreviewFile;
        if~isempty(aPreviewFile)&&isfile(aPreviewFile)
            delete(aPreviewFile);
        end

        varargout{1}=[tempname,'.png'];
        DIALOG_USERDATA(idx).PreviewFile=varargout{1};

    case{'Delete','Cancel'}

        aDialog=maskeditor('Get',aSystemHandle);
        if isempty(aDialog)
            return;
        end


        [DIALOG_SIZE.Position,DIALOG_SIZE.IsMaximized]=aDialog.getWindowState();

        aDialog.delete();

        iIdx=[DIALOG_USERDATA.SystemHandle]==aSystemHandle;

        aPreviewFile=DIALOG_USERDATA(iIdx).PreviewFile;
        if~isempty(aPreviewFile)&&isfile(aPreviewFile)
            delete(aPreviewFile);
        end

        DIALOG_USERDATA(iIdx)=[];
        slInternal('clearMaskEditorOpenValue',aSystemHandle);





        isSystemBlock=strcmp(get_param(aSystemHandle,'BlockType'),'MATLABSystem');
        if isSystemBlock
            modelName=get_param(aSystemHandle,'Parent');
            if bdIsLoaded(modelName)
                if strcmp(get_param(modelName,'Shown'),'off')
                    close_system(modelName,0);
                end
            end
        end

    case 'DeleteAll'

        if~isempty(DIALOG_USERDATA)
            aSystemHandles=[DIALOG_USERDATA.SystemHandle];
            for i=1:length(aSystemHandles)
                maskeditor('Delete',aSystemHandles(i));
            end

            DIALOG_USERDATA=[];
        end

    case 'Unmask'
        aMaskObj=Simulink.Mask.get(aSystemHandle);
        if~isempty(aMaskObj)
            aMaskObj.delete();
        end
        maskeditor('Delete',aSystemHandle);
        bStateChanged=true;
        aStateChangeType=getStateChangeType(aSystemHandle);

    case 'GetBlockHandle'

        varargout{1}=aSystemHandle;
        aMaskObj=Simulink.Mask.get(aSystemHandle);
        if~isempty(aMaskObj)
            varargout{1}=aMaskObj.getOwner().Handle;
        end

    case 'SendMessage'
        aMsgData=aArgs{2};
        aDialog=maskeditor('Get',aSystemHandle);
        if~isempty(aDialog)
            aDialog.sendMessage(aMsgData);
            aDialog.show();
        end

    case 'RefreshModelMask'
        assert(4==length(aArgs));

        aDialog=maskeditor('Get',aSystemHandle);
        if isempty(aDialog)
            return;
        end

        aRefreshAction=aArgs{2};
        switch(aRefreshAction)
        case 'Rename'
            aMsgData=struct('Action',aRefreshAction,'OldWidgetName',aArgs{3},'NewWidgetName',aArgs{4});
        case 'AddRemoveParameter'
            aMsgData=struct('Action',aRefreshAction,'WidgetName',aArgs{3},'IsArgument',aArgs{4});
        end

        aDialog.refreshModelMaskEditor(aSystemHandle,aMsgData);

    case 'Save'
        varargout{1}=false;
        aDialog=maskeditor('Get',aSystemHandle);
        if~isempty(aDialog)
            bStateChanged=true;
            aStateChangeType=getStateChangeType(aSystemHandle);

            varargout{1}=aDialog.save();
        end

    case 'IsAppReady'
        varargout{1}=false;
        aDialog=maskeditor('Get',aSystemHandle);
        if~isempty(aDialog)
            varargout{1}=aDialog.isAppReady();
        end
    end

    if bStateChanged

        aEventDispatcher=DAStudio.EventDispatcher;
        aEventDispatcher.broadcastEvent('ObjectStateChangedEvent',get_param(aSystemHandle,'object'),aStateChangeType);
    end
end

function aStateChangeType=getStateChangeType(aSystemHandle)
    if(strcmp(get_param(aSystemHandle,'BlockType'),'SubSystem')&&strcmp(get_param(aSystemHandle,'SFBlockType'),'Chart'))
        if isempty(Simulink.Mask.get(aSystemHandle))
            aStateChangeType='ObjectSourceChange';
            return;
        end
    end

    aStateChangeType='MaskChange';
end

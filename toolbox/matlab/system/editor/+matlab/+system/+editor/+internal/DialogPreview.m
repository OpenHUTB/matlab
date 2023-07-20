classdef DialogPreview




    methods(Static)
        function preview=launch(preview,document)

            filePath=document.Filename;
            if document.Modified

                [~,~,ext]=fileparts(filePath);
                if isempty(ext)
                    error(message('MATLAB:system:Editor:DialogPreviewNotFile'));
                end


                if querySave
                    save(document);
                else
                    return;
                end
            end


            update(filePath,preview,true);
            if~isValidDialogPreviewHandle(preview)
                preview=createDialogPreview(filePath);
            else

                preview.restoreFromSchema;
                preview.resetSize;
                preview.show;
            end
        end

        function preview=refresh(preview,filePath)
            try

                update(filePath,preview,false);
                if isValidDialogPreviewHandle(preview)



                    preview.restoreFromSchema;
                    preview.resetSize;
                else

                    preview=[];
                end
            catch e %#ok<NASGU>

                preview=[];
            end
        end

        function cleanup(preview)
            if isValidDialogPreviewHandle(preview)
                delete(preview);
            end
            PreviewModel('close');
        end

        function isError=isDialogPreviewError(id)
            isError=ismember(id,{...
            'MATLAB:system:Editor:DialogPreviewNotConstructable',...
            'MATLAB:system:Editor:DialogPreviewNotFile',...
            'MATLAB:system:Editor:DialogPreviewOvershadowedOnPath',...
            'MATLAB:system:Editor:DialogPreviewOvershadowedByPFile',...
            'MATLAB:system:Editor:DialogPreviewNotOnPath',...
            'MATLAB:system:Editor:DialogPreviewNotSupported',...
            'MATLAB:system:Editor:DialogPreviewDataTypesNotSupported'});
        end
        function aMaskEditorInstance=launchMaskEditor(~,document)
            filePath=document.Filename;
            aBlkHdl=getBlockHandleForSystemObject(filePath,false);
            set_param(aBlkHdl,'selected','on');
            aParent=get_param(aBlkHdl,'Parent');
            aParentHdl=get_param(aParent,'Handle');
            slInternal('createOrEditMask',aParentHdl);

            aMaskEditorInstance=maskeditor('GetMaskEditor',aBlkHdl);

        end
    end
end

function allowSave=querySave

    okStr=message('MATLAB:uistring:popupdialogs:OK').getString;
    cancelStr=message('MATLAB:uistring:popupdialogs:Cancel').getString;
    response=questdlg(message('MATLAB:system:Editor:DialogPreviewCodeModified').getString,...
    message('MATLAB:system:Editor:DialogPreviewCodeModifiedQuestionTitle').getString,...
    okStr,cancelStr,okStr);
    allowSave=strcmp(response,okStr);
end

function update(filePath,preview,deleteExpiredDialog)




    if isValidDialogPreviewHandle(preview)
        oldSysObj=[];
        try
            source=getSource(preview);
            blk=source.getBlock;
            blkName=blk.getFullName;
            oldSysObj=get_param(blkName,'System');

            constructDialogPreviewSystemObjectInstance(filePath,true);
        catch e





            if deleteExpiredDialog||...
                ~isSystemObjectInstanceCurrent(oldSysObj,filePath)
                if ishandle(preview)
                    delete(preview);
                end
                rethrow(e);
            end
        end
    end
end

function PreviewModel(aAction,aModelName)
    persistent sPreviewModel;
    mlock;

    switch aAction
    case 'open'
        PreviewModel('close');
        load_system(new_system(aModelName));
        sPreviewModel=aModelName;
    case 'close'

        if~isempty(sPreviewModel)
            close_system(sPreviewModel,false);
            sPreviewModel=[];
        end
    end
end


function aPreviewDlgHdl=createDialogPreview(aFilePath)
    aBlk=getBlockHandleForSystemObject(aFilePath,true);
    open_system(aBlk,'Mask')
    aMaskObj=Simulink.Mask.get(aBlk);
    aPreviewDlgHdl=aMaskObj.getDialogHandle();
end

function aBlk=getBlockHandleForSystemObject(aFilePath,aShowDialogPreview)

    aSysObj=constructDialogPreviewSystemObjectInstance(aFilePath,aShowDialogPreview);
    aSysObjName=class(aSysObj);


    [~,aPreviewModel]=fileparts(tempname);

    PreviewModel('open',aPreviewModel);
    if aShowDialogPreview
        aBlkName=[aPreviewModel,'/(preview)'];
    else
        aBlkName=[aPreviewModel,'/',aSysObjName];
    end

    aBlk=add_block('built-in/MATLABSystem',aBlkName);
    set_param(aBlk,'System',aSysObjName);
end

function isValidPreview=isValidDialogPreviewHandle(dialogHandle)
    isValidPreview=~isempty(dialogHandle)&&ishandle(dialogHandle);
end

function isCurrent=isSystemObjectInstanceCurrent(sysobj,documentPath)


    isCurrent=true;



    documentPath=which(documentPath);
    sysobjClassName=class(sysobj);
    sysobjPath=which(sysobjClassName);
    if isempty(documentPath)||isempty(sysobjPath)
        isCurrent=false;
        return;
    end



    docClassName=matlab.system.editor.internal.getClassNameFromFile(documentPath);
    if~strcmp(sysobjClassName,docClassName)
        isCurrent=false;
        return;
    end


    if isStalePCodedFile(documentPath,sysobjPath)
        isCurrent=false;
        return;
    end
end

function isPCoded=isPCodedFile(documentPath,sysobjPath)


    isPCoded=false;
    if exist(sysobjPath,'file')==6
        [pFilePath,pFileName]=fileparts(sysobjPath);
        [docFilePath,docFileName]=fileparts(documentPath);
        isPCoded=strcmp(pFilePath,docFilePath)&&strcmp(pFileName,docFileName);
    end
end

function isStalePCode=isStalePCodedFile(documentPath,sysobjPath)

    isStalePCode=false;


    if isPCodedFile(documentPath,sysobjPath)
        docFileInfo=dir(documentPath);
        pFileInfo=dir(sysobjPath);
        isStalePCode=(docFileInfo.datenum>pFileInfo.datenum);
    end
end

function sysobj=constructDialogPreviewSystemObjectInstance(filePath,aShowPreview)



    sysobjName=matlab.system.editor.internal.getClassNameFromFile(filePath);


    sysobjPath=which(sysobjName);
    if aShowPreview
        aFunctionality=getString(message('MATLAB:system:Editor:DialogPreview'));
    else
        aFunctionality=getString(message('MATLAB:system:Editor:LaunchMaskEditor'));
    end
    if isempty(sysobjPath)||~exist(sysobjPath,'file')

        fschange(fileparts(filePath));

        sysobjPath=which(sysobjName);
        if isempty(sysobjPath)||~exist(sysobjPath,'file')
            error(message('MATLAB:system:Editor:DialogPreviewNotOnPath',sysobjName,aFunctionality));
        end
    end


    documentPath=which(filePath);
    if~strcmp(sysobjPath,documentPath)
        if isPCodedFile(documentPath,sysobjPath)

            if isStalePCodedFile(documentPath,sysobjPath)
                error(message('MATLAB:system:Editor:DialogPreviewOvershadowedByPFile',sysobjName,sysobjPath,documentPath));
            end
        else
            error(message('MATLAB:system:Editor:DialogPreviewOvershadowedOnPath',sysobjName,sysobjPath,aFunctionality));
        end
    end


    try
        meta.class.fromName(sysobjName);
    catch e
        cause=stripLinkFromMessage(e.message);
        error(message('MATLAB:system:Editor:DialogPreviewNotConstructable',sysobjName,cause,aFunctionality));
    end


    try
        alternateBlock=feval([sysobjName,'.getAlternateBlock']);
    catch e %#ok<NASGU>

        alternateBlock='';
    end
    if~isempty(alternateBlock)
        error(message('MATLAB:system:Editor:DialogPreviewNotSupported',aFunctionality,sysobjName));
    end


    if aShowPreview
        try
            hasDataTypeProperties=matlab.system.display.internal.DataTypesGroup.hasDataTypes(sysobjName);
        catch e %#ok<NASGU>

            hasDataTypeProperties=false;
        end
        if hasDataTypeProperties
            error(message('MATLAB:system:Editor:DialogPreviewDataTypesNotSupported',sysobjName));
        end
    end



    try
        sysobj=eval(sysobjName);
    catch e
        cause=stripLinkFromMessage(e.message);
        error(message('MATLAB:system:Editor:DialogPreviewNotConstructable',sysobjName,cause,aFunctionality));
    end


    try
        isAllowedInBlock=sysobj.isAllowedInSystemBlock;
    catch e %#ok<NASGU>

        isAllowedInBlock=true;
    end
    if~isAllowedInBlock
        error(message('MATLAB:system:Editor:DialogPreviewNotSupported',aFunctionality,sysobjName));
    end
end

function errMsg=stripLinkFromMessage(errMsg)
    errMsg=regexprep(errMsg,'<a href.*?">(.*?)</a>','$1');
end

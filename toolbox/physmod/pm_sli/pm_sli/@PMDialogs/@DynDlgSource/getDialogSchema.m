function dlgStruct=getDialogSchema(hThis,type)








    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);


    licenseMessage=hThis.internalValidateLicense(hBlk);
    if~isempty(licenseMessage)
        beep;
        dlgStruct=l_MakeErrorDialog(hThis,type,licenseMessage,...
        getString(message('physmod:pm_sli:dialog:LicenseErrorDlgTitle')));
        return;
    end


    dialogMessage=internalValidateDialog(hThis,hBlk);
    if~isempty(dialogMessage)
        dlgStruct=l_MakeErrorDialog(hThis,type,dialogMessage,...
        getString(message('physmod:pm_sli:dialog:ErrorDlgTitle')));
        return;
    end

    try

        hThis.ShowRuntime=true;

        pmsl_rtmcallback(hBlk,'BLK_OPENDLG');





        if~pm.sli.internal.isslim(type)
            dlgStruct=internalGetSlimDialogSchema(hThis,type);


        elseif(isempty(hThis.BuilderObj))

            hThis.BuilderObj=l_GetDlgBuilder(hThis,hBlk,type);
            dlgStruct=l_GetDlgStruct(hThis,hThis.BuilderObj,type);


        else


            editorDomain=[];
            if bitand(slfeature('SelectiveParamUndoRedo'),8)>0


                try
                    ownerSys=get_param(hBlk,'Parent');
                    editors=GLUE2.Util.findAllEditors(ownerSys);
                    if~isempty(editors)

                        numEditors=length(editors);
                        for i=1:numEditors
                            editor=editors(i);
                            if editor.isVisible
                                editorDomain=editors.getStudio.getActiveDomain();
                                break;
                            end
                        end
                    end
                catch
                    editorDomain=[];
                end

                if~isempty(editorDomain)&&editorDomain.paramChangesCommandIsObjectInUndoRedoCtxt(hBlk)
                    hThis.BuilderObj.Realize();
                end

            end


            hThis.BuilderObj.Refresh();
            dlgStruct=l_GetDlgStruct(hThis,hThis.BuilderObj,type);

        end

    catch e


        errmsg2=getString(message(...
        'physmod:pm_sli:dialog:FailToCreateDialogSchema',...
        e.identifier,e.message));
        dlgStruct=l_MakeErrorDialog(hThis,type,errmsg2);

    end

    if~pm.sli.internal.isslim(type)
        dlgStruct.DialogMode='Slim';
    end

end





function dlgStruct=l_GetDlgStruct(hThis,dlgBuilder,type)


    itemsStruct=[];
    [~,itemsStruct]=Render(dlgBuilder,itemsStruct);


    dlgStruct=makeDialogSchema(hThis,itemsStruct,type);


    dlgStruct=dlgBuilder.PreDlgDisplay(dlgStruct);

end


function dlgBuilder=l_GetDlgBuilder(hThis,hBlk,type)



    pmSchema=internalGetPmSchema(hThis,hBlk,type);


    dlgBuilder=PMDialogs.DynDlgBuilder(hBlk);
    dlgBuilder.buildFromPmSchema(pmSchema);
    dlgBuilder.Realize();
    dlgBuilder.Refresh();

end


function stack=l_MakeErrorDialog(src,type,varargin)


    if((nargin>1)&&ischar(varargin{1}))
        errMsg=varargin{1};
    else
        errMsg=getString(message(...
        'physmod:pm_sli:dialog:NotLicensedError'));
    end

    if((nargin>3)&&ischar(varargin{2}))
        errTitle=varargin{2};
    else
        errTitle='';
    end

    iconPath=fullfile(pmsl_dialogresourcedir,'error.png');

    errorIcon=struct(...
    'Name',{''},...
    'Type','image',...
    'FilePath',{iconPath},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,3]},...
    'Tag','InvalidSchemaIcon');

    errorTxt=struct(...
    'Name',errMsg,...
    'Type','text',...
    'Bold',1,...
    'WordWrap',true,...
    'RowSpan',{[1,1]},...
    'ColSpan',{[4,10]},...
    'Tag','InvalidSchemaMessage');

    errgrp=struct(...
    'Name',errTitle,...
    'Type',{'group'},...
    'Items',{{errorIcon,errorTxt}},...
    'LayoutGrid',{[1,10]},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,1]},...
    'Tag','InvalidSchemaPanel');

    panel=struct(...
    'Name',{''},...
    'Type',{'panel'},...
    'Items',{{errgrp}},...
    'Source',{get_param(src.BlockHandle,'Object')},...
    'LayoutGrid',{[1,1]},...
    'RowStretch',{0});

    stack=struct(...
    'DialogTitle',{''},...
    'Items',{{panel}},...
    'SmartApply',true,...
    'CloseMethod',{'closeDialogCB'},...
    'CloseMethodArgs',{{'%dialog'}},...
    'CloseMethodArgsDT',{{'handle'}});

    if~pm.sli.internal.isslim(type)
        stack.StandaloneButtonSet={''};
        stack.EmbeddedButtonSet={''};
        stack.DialogMode='Slim';
    end

end

function dlgStruct=getDialogSchema(hThis,type)










    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);




    [licenseGood,errorMsg]=pm.sli.internal.checklicense(hBlk);
    if~licenseGood
        beep;
        dlgStruct=l_MakeErrorDialog(hThis,errorMsg,'License Error');
        return;
    end

    try
        pmsl_rtmcallback(hBlk,'BLK_OPENDLG');

        dlgStruct=pmsl_superclassmethod(hThis,'PMDialogs.PMDefaultMaskDlg','getDialogSchema',type);
        dlgStruct.ExplicitShow='false';

    catch exception

        msg=exception.message;

        dlgStruct=l_MakeErrorDialog(hThis,msg,'Error');



        beep;
        warning(exception.identifier,msg);

    end

end






function stack=l_MakeErrorDialog(src,errMsg,errorTitle)

    if nargin<3
        errorTitle='License Error';
    end
    if nargin<2
        errMsg='Not licensed to access this block.';
    end

    iconPath=fullfile(pmsl_dialogresourcedir,'error.png');

    errorIcon=struct('Name',{''},...
    'Type','image',...
    'FilePath',{iconPath},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,3]});


    errorTxt=struct('Name',errMsg,...
    'Type','text',...
    'Bold',1,...
    'WordWrap',true,...
    'RowSpan',{[1,1]},...
    'ColSpan',{[4,10]});

    errgrp=struct('Name',{errorTitle},...
    'Type',{'group'},...
    'Items',{{errorIcon,errorTxt}},...
    'LayoutGrid',{[1,10]},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,1]});

    panel=struct('Name',{''},...
    'Type',{'panel'},...
    'Items',{{errgrp}},...
    'Source',{get_param(src.BlockHandle,'Object')},...
    'LayoutGrid',{[1,1]},...
    'RowStretch',{0});

    stack=struct('DialogTitle',{''},...
    'Items',{{panel}},...
    'CloseCallback',{'pmsl_close_cbk'},...
    'CloseArgs',{{src,'%dialog'}}...
    );

end

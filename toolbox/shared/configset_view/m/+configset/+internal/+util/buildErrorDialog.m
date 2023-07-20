function buildErrorDialog(msg,me)










    dlg=msg.dialog;
    paramData=msg.data;
    newVal=msg.error.val;

    hSrc=dlg.getSource;
    adp=hSrc.Source;
    cs=adp.getCS;
    hParentController=cs.getDialogController;

    param=paramData.getParamName;
    if isa(paramData,'configset.internal.data.WidgetStaticData')

        vList=adp.getWidgetValueList(param,paramData.Parameter);

        widgetIdx=find(cellfun(@(x)strcmp(x.Tag,paramData.Tag),...
        paramData.Parameter.WidgetList));

        oldVal=vList{widgetIdx};

        if strcmp(param,'ReplacementTypes')
            prompt=[vList{widgetIdx+1},'/',vList{widgetIdx+2}];
        else
            prompt=paramData.getPrompt(cs);
        end
    else
        if isempty(paramData.WidgetValuesFcn)
            try
                oldVal=num2str(get_param(cs,param));
            catch
                oldVal='';

                if strcmp(paramData.Component,'HDL Coder')
                    hdl=[];
                    if isa(cs,'hdlcoderui.hdlcc')
                        hdl=cs;
                    elseif isa(cs,'Simulink.ConfigSet')
                        hdl=cs.getComponent('HDL Coder');
                    end
                    if~isempty(hdl)
                        oldVal=hdl.get_param(param);
                    end
                end
            end
        else
            fcn=str2func(paramData.WidgetValuesFcn);
            oldVal=fcn(cs,param,0);
            oldVal=oldVal{1};
        end
        prompt=paramData.getPrompt(cs);
    end


    if isfield(msg.error,'row')&&isfield(msg.error,'col')&&iscell(oldVal)
        oldVal=oldVal{msg.error.row+1,msg.error.col+1};
    end

    errtxt=me.message;
    errmsg=loc_buildErrMsg(newVal,oldVal,errtxt,param,prompt);
    hf=errordlg(errmsg);
    hParentController.ErrorDialog=hf;
    set(hf,'tag','ConfigSetDialogCallbackError');
    setappdata(hf,'MException',me);

    function errmsg=loc_buildErrMsg(newval,oldval,errtxt,param,prompt)


        layout=configset.internal.getConfigSetCategoryLayout;
        pagename=layout.getParamDisplayPath(param);

        err_Txt1=getString(message('RTW:targetRegistry:buildErrorMsg1',prompt,pagename));
        err_Txt2=getString(message('RTW:targetRegistry:buildErrorMsg2',num2str(newval)));
        err_Txt3=getString(message('RTW:targetRegistry:buildErrorMsg3',num2str(oldval)));

        errmsg=[err_Txt1,newline,newline,...
        errtxt,newline,newline,...
        err_Txt2,newline,...
        err_Txt3];



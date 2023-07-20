function SelectedSystem=systemselector(StartSystem,varargin)










    persistent fh;
    persistent ssDlgObj;

    SystemSelectorNoWait=false;


    DialogTitle=DAStudio.message('Simulink:tools:MASystemSelector');
    DialogInstruction=DAStudio.message('Simulink:tools:MASelectSystemDialogTitle');
    if nargin>1
        DialogTitle=varargin{1};
        if nargin>2
            DialogInstruction=varargin{2};
        end
    end


    if evalin('base','exist(''MdlAdvQEOpts'',''var'')')
        baseMdlAdvQEOpts=evalin('base','MdlAdvQEOpts');
        if isfield(baseMdlAdvQEOpts,'SystemSelector')
            if~baseMdlAdvQEOpts.SystemSelector

                SelectedSystem=StartSystem;
                return
            end
        end
        if isfield(baseMdlAdvQEOpts,'SystemSelectorNoWait')
            if baseMdlAdvQEOpts.SystemSelectorNoWait


                SystemSelectorNoWait=true;
            end
        end
    end


    if isa(ssDlgObj,'DAStudio.Dialog')
        ssDlgObj.show;
        SelectedSystem='';
        return
    end


    fh=figure('Name',DAStudio.message('Simulink:tools:MASelectSystemDialogTitle'),'toolbar','none','menu','none',...
    'NumberTitle','off','WindowStyle','modal','position',[1,2,3,4],'Visible','off');
    UserData.SelectedSystem=StartSystem;

    ssobj=ModelAdvisor.SystemSelector;
    if(strcmp(StartSystem,'Simulink Root'))
        ssobj.ModelObj=slroot;
        ssobj.SelectedSystem='Simulink Root';
    else
        ssobj.ModelObj=get_param(bdroot(UserData.SelectedSystem),'Object');
        ssobj.SelectedSystem=getfullname(UserData.SelectedSystem);
        Simulink.listener(ssobj.ModelObj,'CloseEvent',@(src,evt)LocalCloseCB(ssobj,src,evt));
    end

    ssobj.DialogTitle=DialogTitle;
    ssobj.DialogInstruction=DialogInstruction;
    ssobj.StartDialog=fh;
    h=waitbar(0.2,DAStudio.message('ModelAdvisor:engine:LoadingSystemHierarchy'));
    ssDlgObj=DAStudio.Dialog(ssobj,'','DLG_STANDALONE');
    if ishandle(h)
        close(h);
    end
    UserData.ssobj=ssobj;
    set(fh,'UserData',UserData);

    if~SystemSelectorNoWait
        waitfor(fh,'Position');
    end
    if ishandle(fh)
        UserData=get(fh,'UserData');

        if isa(UserData.ssobj,'ModelAdvisor.SystemSelector')
            UserData.SelectedSystem=UserData.ssobj.SelectedSystem;
            UserData.ssobj.delete;
        end
        SelectedSystem=UserData.SelectedSystem;
        close(fh);
    else
        SelectedSystem='';
    end
end

function LocalCloseCB(this,event,src)%#ok<INUSD>
    if isa(this,'ModelAdvisor.SystemSelector')
        this.closeCB('close');
    end
end
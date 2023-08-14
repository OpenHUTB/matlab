function schemas=getInterface(whichMenu,callbackInfo)



    im=DAStudio.IconManager;
    if~im.hasIcon('LibraryBrowser2:Open')
        root1=[matlabroot,'/toolbox/shared/dastudio/resources/glue/Toolbars/24px/'];
        root2=[matlabroot,'/toolbox/shared/dastudio/resources/'];
        im.addFileToIcon('LibraryBrowser2:Open',[root1,'Open_24.png']);
        im.addFileToIcon('LibraryBrowser2:StayOnTopOff',[root2,'ToolboxPinBtnLB.PNG']);
        im.addFileToIcon('LibraryBrowser2:StayOnTopOn',[root2,'ToolboxPinBtnOnLB.PNG']);
        im.addFileToIcon('LibraryBrowser2:Help',[root2,'help.png']);
    end

    switch(whichMenu)
    case 'MenuBar'
        schemas=MenuBar(callbackInfo);
    case 'ToolBars'
        schemas=ToolBars(callbackInfo);
    otherwise
        schemas=ContextMenu(callbackInfo);
    end
end




function schemas=MenuBar(callbackInfo)%#ok<*INUSD>

    schemas={@Dummy};
end

function schema=Dummy(callbackInfo)

    schema=DAStudio.ContainerSchema;
    schema.state='hidden';
end

function schemas=ToolBars(callbackInfo)
    schemas={@NewOpenToolBar,@PinHelpToolBar};
end



function schema=NewOpenToolBar(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='LibraryBrowser2:NewOpenToolBar';
    schema.childrenFcns={@NewMenu,@OpenMenu};


    if exist('privhdllibstate')%#ok<EXIST>
        if privhdllibstate('nonce')
            schema.childrenFcns=[schema.childrenFcns,cm_get_custom_schemas('LibraryBrowser:ViewMenu')];
        end
    end
end

function schema=PinHelpToolBar(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='LibraryBrowser2:PinHelpToolBar';
    schema.childrenFcns={@StayOnTop,@Help};
end

function schema=NewMenu(callbackInfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.label=DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_NewToolTip');
    schema.tag='LibraryBrowser2:NewMenu';
    schema.childrenFcns=SLStudio.NewMenu('GetNewMenuChildren',callbackInfo);


    schema.defaultActionFcn=schema.childrenFcns{1};
end

function schema=OpenMenu(callbackInfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.label=DAStudio.message('Simulink:studio:Open');
    schema.tag='LibraryBrowser2:OpenMenu';

    schema.childrenFcns=[...
    {@Open};...
    {'separator'};...
    SLStudio.FileMenu('generateOpenRecentChildren',callbackInfo)
    ];


    schema.defaultActionFcn=schema.childrenFcns{1};
end

function schema=Open(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('Simulink:studio:Open');
    schema.tag='LibraryBrowser2:Open';
    schema.icon='LibraryBrowser2:Open';
    schema.accelerator='Ctrl+O';
    schema.callback=@OpenAction;
end

function OpenAction(callbackInfo)
    if~ispc

        lb=LibraryBrowser.LibraryBrowser2;
        lb.setGUIEnabled(false);
        modalifier=DAS.FakeModalDialog;%#ok<NASGU>
    end

    try
        uiopen('simulink');
    catch ME
        if~ispc
            lb.setGUIEnabled(true);
        end
        rethrow(ME);
    end

    if~ispc
        lb.setGUIEnabled(true);
    end
end

function schema=StayOnTop(callbackInfo)
    schema=DAStudio.ToggleSchema;
    schema.label=DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_StayOnTopToolTip');
    schema.tag='LibraryBrowser2:StayOnTop';
    schema.callback=@StayOnTopAction;

    lb=LibraryBrowser.LibraryBrowser2;
    if lb.IsOnTop
        schema.checked='Checked';
        schema.icon='LibraryBrowser2:StayOnTopOn';
    else
        schema.checked='Unchecked';
        schema.icon='LibraryBrowser2:StayOnTopOff';
    end
end

function StayOnTopAction(callbackInfo)
    lb=LibraryBrowser.LibraryBrowser2;
    lb.IsOnTop=~lb.IsOnTop;
end

function schema=Help(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_HelpToolTip');
    schema.tag='LibraryBrowser2:Help';
    schema.icon='LibraryBrowser2:Help';
    schema.accelerator='F1';
    schema.callback=@HelpAction;
end

function HelpAction(callbackInfo)
    helpview([docroot,'/toolbox/simulink/helptargets.map'],'librarybrowsergui');
end

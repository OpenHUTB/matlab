function schema=HelpMenu(fncname,cbinfo,eventData)

    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];

        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=HelpSimulinkMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:HelpSimulinkMenu';
    schema.label=DAStudio.message('Simulink:studio:HelpSimulinkMenu');

    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.state='Hidden';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    else

        schema.childrenFcns={@SimulinkHelp,...
        'separator',...
        @BlocksHelp,...
        @BlockSupportTableMenuItem,...
        @SFunctions,...
        'separator',...
        @SimulinkDemos,...
        @LearnSimulink
        };
    end

    schema.autoDisableWhen='Never';
end

function schema=SimulinkHelp(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SimulinkHelp';
    schema.label=DAStudio.message('Simulink:studio:SimulinkHelp');
    if cbinfo.isContextMenu
        schema.obsoleteTags={'Simulink:ContextSimulinkHelp'};
    end
    schema.callback=@SimulinkHelpCB;

    schema.autoDisableWhen='Never';
end

function SimulinkHelpCB(~,~)
    doc('simulink');
end

function schema=BlocksHelp(cbinfo)
    schema=sl_action_schema;
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:BlocksAndBlocksetsHelp');
        schema.obsoleteTags={'Simulink:ContextBlocksHelp'};
    else
        schema.label=DAStudio.message('Simulink:studio:BlocksAndBlocksets');
    end
    schema.tag='Simulink:BlocksHelp';
    schema.callback=@BlocksHelpCB;

    schema.autoDisableWhen='Never';
end

function BlocksHelpCB(cbinfo,~)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        slhelp(block.handle);
    else
        file=fullfile(docroot,'simulink','helptargets.map');
        helpview(file,'simulink_editor');
    end
end

function ispresent=loc_FindIfTbxPresent(tbxName)
    persistent vinfo;
    ispresent=false;
    if isempty(vinfo)
        vinfo=ver;
        vinfo=rmfield(vinfo,{'Version','Release','Date'});
    end
    lenvinfo=length(vinfo);
    for ind=1:lenvinfo
        vinfo_cur_tbx_name=getfield(vinfo(ind),'Name');%#ok
        if strcmpi(vinfo_cur_tbx_name,tbxName)
            ispresent=true;
            break;
        end
    end
end

function schema=BlockSupportTableMenuItem(~)
    schema=sl_container_schema;
    schema.tag='Simulink:BlockSupportTableMenuItem';
    schema.label=DAStudio.message('Simulink:studio:BlockSupportTableMenuItem');

    persistent num_menu_items;
    persistent menu_tag;
    persistent menu_label;
    persistent call_me;
    liblist_me=cell(0,0);
    libmdl_me=cell(0,0);

    if isempty(num_menu_items)
        num_menu_items=1;
        infofile=fullfile(matlabroot,'help','toolbox','simulink','SimulinkBlocksetInfo.txt');
        if exist(infofile,'file')
            ffSlBlksInf=fopen(infofile);
            while 1
                tline=fgetl(ffSlBlksInf);
                if~ischar(tline),break,end
                textstrs=textscan(tline,'%s','delimiter','"');
                textparts=textstrs{1};




                if~isempty(textparts{8})
                    cur_label=textparts{2};
                    if loc_FindIfTbxPresent(cur_label)
                        num_menu_items=num_menu_items+1;
                        menu_tag{num_menu_items-1}=textparts{4};
                        menu_label{num_menu_items-1}=cur_label;
                        call_me{num_menu_items-1}=textparts{8};
                        [list,lib]=feval(textparts{8},'GetListandLib');
                        liblist_me{num_menu_items-1}=list;
                        libmdl_me{num_menu_items-1}=lib;

                    end
                end
            end
            fclose(ffSlBlksInf);
        end
    end

    loc_LibListInfo(liblist_me,libmdl_me);






    if num_menu_items==1

        schema.childrenFcns={@BlockSupportTableSLMenuItem};
    else

        schema.childrenFcns{1}=@BlockSupportTableAllMenuItem;
        schema.childrenFcns{2}=@BlockSupportTableSLMenuItem;

        for ind=1:num_menu_items-1



            schema.childrenFcns{2+ind}={@BlockSupportTableMenuOtherBlocksets,{menu_label{ind},menu_tag{ind},call_me{ind}}};
        end

    end

    schema.autoDisableWhen='Never';
end

function[outLibLists,outLibNames]=loc_LibListInfo(inLibLists,inLibNames)
    persistent libLists;
    persistent libNames;

    if isempty(libLists)&&nargin>0
        libLists=inLibLists;
        libNames=inLibNames;
    elseif nargout>0
        outLibLists=libLists;
        outLibNames=libNames;
    end
end

function schema=BlockSupportTableSLMenuItem(~)
    schema=sl_action_schema;
    schema.tag='Simulink:BlockSupportTableSLMenuItem';
    schema.label=DAStudio.message('Simulink:studio:BlockSupportTableSLMenuItem');
    schema.callback=@SLBlockSupportCB;

    schema.autoDisableWhen='Never';
end

function SLBlockSupportCB(~,~)
    showblockdatatypetable;
end

function schema=BlockSupportTableAllMenuItem(~)
    schema=sl_action_schema;
    schema.tag='Simulink:BlockSupportTableAllMenuItem';
    schema.label=DAStudio.message('Simulink:studio:BlockSupportTableAllMenuItem');
    schema.callback=@ShowAllCapsCB;

    schema.autoDisableWhen='Never';
end

function ShowAllCapsCB(~,~)
    msg=message('Simulink:studio:BlockSupportTableAllBlockMsg');
    SLStudio.internal.ScopedStudioBlocker(msg.getString());
    [libLists,libNames]=loc_LibListInfo;
    slshowallcaps('LaunchHTML',libLists,libNames);
end

function schema=BlockSupportTableMenuOtherBlocksets(cbinfo)
    schema=sl_action_schema;
    schema.label=cbinfo.userdata{1};
    schema.tag=['Simulink:BlockSupportTableOtherMenuItem_',cbinfo.userdata{2}];
    schema.callback=cbinfo.userdata{3};

    schema.autoDisableWhen='Never';
end

function schema=SFunctions(~)
    schema=sl_action_schema;
    schema.tag='Simulink:SFunctions';
    schema.label=DAStudio.message('Simulink:studio:SFunctions');
    schema.callback=@SFunctionsHelpCB;

    schema.autoDisableWhen='Never';
end

function SFunctionsHelpCB(~,~)
    helpview([docroot,'/mapfiles/simulink.map'],'sfg');
end

function schema=SimulinkDemos(~)
    schema=sl_action_schema;
    schema.tag='Simulink:Demos';
    schema.label=DAStudio.message('Simulink:studio:Demos');
    schema.callback=@SimulinkDemosCB;

    schema.autoDisableWhen='Never';
end

function SimulinkDemosCB(~,~)
    demo simulink;
end

function schema=LearnSimulink(~)
    schema=sl_action_schema;
    schema.tag='Simulink:Learn';
    schema.label=DAStudio.message('Simulink:studio:LearnSimulink');
    schema.callback=@LearnSimulinkCB;

    schema.autoDisableWhen='Never';
end

function LearnSimulinkCB(~,~)
    learning.simulink.launchOnramp;
end

function schema=HelpWebResourcesMenu(~)
    schema=sl_container_schema;
    schema.tag='Simulink:HelpWebResourcesMenu';
    schema.label=DAStudio.message('Simulink:studio:HelpWebResourcesMenu');


    schema.childrenFcns={@MathWorksWebsite,...
    @ProductsAndServices,...
    @WebSupport,...
    @WebTraining,...
    @MathWorksAccount,...
    'separator',...
    @MATLABCentral,...
    @MATLABFileExchange,...
    @MATLABAnswers,...
    @MATLABNewsLetters
    };

    schema.autoDisableWhen='Never';
end

function schema=MathWorksWebsite(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MathWorksWebsite';
    schema.label=DAStudio.message('Simulink:studio:MathWorksWebsite');
    schema.userdata='https://www.mathworks.com/index.html?s_cid=pl_homepage';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=ProductsAndServices(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ProductsAndServices';
    schema.label=DAStudio.message('Simulink:studio:ProductsAndServices');
    schema.userdata='https://www.mathworks.com/products/index.html?s_cid=pl_prodandservices';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=WebSupport(~)
    schema=sl_action_schema;
    schema.tag='Simulink:WebSupport';
    schema.label=DAStudio.message('Simulink:studio:WebSupport');
    schema.userdata='https://www.mathworks.com/support/index.html?s_cid=pl_support';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=WebTraining(~)
    schema=sl_action_schema;
    schema.tag='Simulink:WebTraining';
    schema.label=DAStudio.message('Simulink:studio:WebTraining');
    schema.userdata='https://www.mathworks.com/services/training/courses/index.html?s_cid=pl_training';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=MathWorksAccount(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MathWorksAccount';
    schema.label=DAStudio.message('Simulink:studio:MathWorksAccount');
    schema.userdata='https://www.mathworks.com/accesslogin/index_new.jsp';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=MATLABCentral(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MATLABCentral';
    schema.label=DAStudio.message('Simulink:studio:MATLABCentral');
    schema.userdata='https://www.mathworks.com/matlabcentral/index.html?s_cid=pl_mlc';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=MATLABFileExchange(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MATLABFileExchange';
    schema.label=DAStudio.message('Simulink:studio:MATLABFileExchange');
    schema.userdata='https://www.mathworks.com/matlabcentral/fileexchange/';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=MATLABAnswers(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MATLABAnswers';
    schema.label=DAStudio.message('Simulink:studio:MATLABAnswers');
    schema.userdata='https://www.mathworks.com/matlabcentral/answers';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function schema=MATLABNewsLetters(~)
    schema=sl_action_schema;
    schema.tag='Simulink:MATLABNewsLetters';
    schema.label=DAStudio.message('Simulink:studio:MATLABNewsLetters');
    schema.userdata='https://www.mathworks.com/company/newsletters/index.html?ref=pl_newsletters';
    schema.callback=@GoToURLCB;

    schema.autoDisableWhen='Never';
end

function GoToURLCB(cbinfo,~)
    url=cbinfo.userdata;
    web(url,'-browser');
end

function schema=SimulinkKeyboardShortcuts(~)
    schema=sl_action_schema;
    schema.tag='Simulink:SimulinkKeyboardShortcuts';
    schema.label=DAStudio.message('Simulink:studio:SimulinkKeyboardShortcuts');
    schema.obsoleteTags={'Simulink:Shortcuts'};
    schema.callback=@SimulinkKeyboardShortcutsCB;

    schema.autoDisableWhen='Never';
end

function SimulinkKeyboardShortcutsCB(~,~)
    helpview([docroot,'/mapfiles/simulink.map'],'shortcuts');
end

function schema=HelpTermsOfUse(~)
    schema=sl_action_schema;
    schema.tag='Simulink:Terms';
    schema.label=DAStudio.message('Simulink:studio:Terms');
    schema.callback=@TermsOfUseCB;

    schema.autoDisableWhen='Never';
end

function TermsOfUseCB(~,~)
    try
        web(matlab.internal.licenseAgreement);
    catch %#ok<CTCH>
        disp(DAStudio.message('Simulink:studio:TermsOfUseError'));
    end
end

function schema=HelpPatents(~)
    schema=sl_action_schema;
    schema.tag='Simulink:Patents';
    schema.label=DAStudio.message('Simulink:studio:Patents');
    schema.callback=@PatentsCB;

    schema.autoDisableWhen='Never';
end

function PatentsCB(~,~)
    try
        web([matlabroot,filesep,'patents.txt']);
    catch %#ok<CTCH>
        disp(DAStudio.message('Simulink:studio:PatentsError'));
    end
end

function schema=HelpAboutSimulink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:About';
    schema.label=DAStudio.message('Simulink:studio:About');
    schema.callback=@AboutCB;

    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.state='Hidden';
    end

    schema.autoDisableWhen='Never';
end

function AboutCB(~,~)
    daabout('simulink');
end



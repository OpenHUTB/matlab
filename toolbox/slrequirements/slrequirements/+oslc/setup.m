function status=setup(option)

    if nargin<1
        option='';
        interactive=true;
    else
        interactive=false;
    end

    while isempty(regexp(option,'^\s*[ynYN]\s*$'))%#ok<RGXP1>
        option=input(getString(message('Slvnv:reqmgt:linktype_mgr:PromptConfigureForDNG')),'s');
    end

    status=~isempty(regexp(option,'^\s*[yY]\s*$'));%#ok<RGXP1>

    if status


        slreq.connector.Oslc.register();

        if interactive



            server=oslc.server([]);

            if~isempty(server)


                ensureOslcTypeRegistration();


                goodMatlabroot=strrep(matlabroot,filesep,'/');
                disp(getString(message('Slvnv:reqmgt:linktype_mgr:DNGWidgetInstruction',...
                'webapps/extensions',...
                [goodMatlabroot,'/toolbox/slrequirements/slrequirements/resources/dngsllink_config'],...
                [server,'/extensions/dngsllink_config/dngsllink_config.xml'])));


                doTestIncomingCall();
            end
        end

    end
end

function ensureOslcTypeRegistration()
    ltype=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
    if isempty(ltype)
        rmi.loadLinktype('oslc.linktype_rmi_oslc');
        rmipref('SelectionLinkDoors',true);
        rmi.menus_selection_links([]);
        rmiml.selectionLink([]);
    end
end

function doTestIncomingCall()


    testUrl='https://127.0.0.1:31515/matlab/oslc/inboundTest';
    disp(getString(message('Slvnv:oslc:SetupTestUrl',testUrl)));


    reply=questdlg({...
    getString(message('Slvnv:oslc:SetupYourSystemBrowser')),...
    getString(message('Slvnv:oslc:SetupWouldLikeToTest')),...
    '',...
    getString(message('Slvnv:oslc:SetupIfYouSeeThenModify','127.0.0.1:31515'))},...
    getString(message('Slvnv:oslc:SetupMatlabConnectionTest')),...
    getString(message('Slvnv:oslc:SetupTestNow')),...
    getString(message('Slvnv:oslc:Skip')),...
    getString(message('Slvnv:oslc:SetupTestNow')));

    if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:oslc:SetupTestNow')))
        web(testUrl,'-browser');
    end
end



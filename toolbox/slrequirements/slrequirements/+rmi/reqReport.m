function reqReport(obj,varargin)



    if~license_checkout_slvnv(~isempty(varargin)&&varargin{1})
        return;
    end


    modelH=rmisl.getmodelh(obj);
    shouldCheckLibLinks=rmi.settings_mgr('get','reportSettings','followLibraryLinks');
    if rmisl.isComponentHarness(modelH)
        [hasLinks,storage,usingDefault]=rmidata.harnessDiagramHasLinks(modelH);

    else
        [hasLinks,storage,usingDefault]=rmisl.modelHasReqLinks(modelH,shouldCheckLibLinks);
    end
    if hasLinks
        origSys=get_param(0,'CurrentSystem');
        set_param(0,'CurrentSystem',modelH);
        RptgenRMI.option('toolsReqReport',1);


        templateFile=RptgenRMI.option('rptFile');
        if isempty(templateFile)
            templateFile='requirements.rpt';
        end
        myRpt=rptgen.loadRpt(templateFile);


        [~,templateName]=fileparts(templateFile);
        outputName=[get_param(modelH,'Name'),'_',templateName];
        myRpt.FilenameType='other';
        myRpt.FilenameName=outputName;





        libOptionOn=RptgenRMI.option('followLibraryLinks');
        rptLibOptionTemp=false;
        mdlLoop=myRpt.find('-isa','rptgen_sl.csl_mdl_loop');
        for i=1:length(mdlLoop)
            libOption=mdlLoop(i).loopList.isLibrary;
            if strcmp(libOption,'off')&&libOptionOn
                mdlLoop(i).loopList.isLibrary='on';
            elseif strcmp(libOption,'on')&&~libOptionOn
                RptgenRMI.option('followLibraryLinks',true);
                rptLibOptionTemp=true;
                break;
            end
        end


        if RptgenRMI.option('navUseMatlab')



            viewCommand=com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.getViewCommand('html');
            if strncmp(viewCommand,'web(',4)||strncmp(viewCommand,'disp(',5)
                rptPostprocessMessage=getString(message('Slvnv:reqmgt:ReportPostProcessMessage'));
                tmpCommand=sprintf('disp(''%s'')',rptPostprocessMessage);
                com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.setViewCommand('html',tmpCommand);
            else
                viewCommand='';
            end
            myRpt.isView=false;
            outputFileName=myRpt.execute();
            rmi.insertMcCheck(outputFileName);
            if~isempty(viewCommand)
                com.mathworks.toolbox.rptgencore.tools.RptgenPrefsPanel.setViewCommand('html',viewCommand);
                if strncmp(viewCommand,'web(',4)
                    web(outputFileName);
                end
            end
        else
            myRpt.execute();
        end


        RptgenRMI.option('toolsReqReport',0);
        if rptLibOptionTemp
            RptgenRMI.option('followLibraryLinks',false);
        end
        set_param(0,'CurrentSystem',origSys);

    else
        rmisl.showNoLinksDlg(modelH,getString(message('Slvnv:reqmgt:reportNoLinks')),storage,usingDefault);
    end
end

function success=license_checkout_slvnv(fromUI)


    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        if fromUI
            rmi.licenseErrorDlg();
        else
            error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
        end
    end

    if(success)
        if~rmi.isInstalled()
            if fromUI
                errordlg(getString(message('Slvnv:reqmgt:installation',rmi.productName())),...
                getString(message('Slvnv:reqmgt:ActionFailed')));
                success=false;
            else
                error(message('Slvnv:reqmgt:installation',rmi.productName()));
            end
        end
    end
end


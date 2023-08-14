function[errMsg,fcnclass]=configFcnProtoSSBuild(block_hdl,mdl_hdl,action,varargin)




    persistent USERDATA

    errMsg='';
    fcnclass=[];

    switch action
    case{'Create','Update','CreateNoUI','Update4MultRunnable','Create4MultRunnable'}

        updateOnly=strcmp(action,'Update')||strcmp(action,'Update4MultRunnable');
        nonUI=strcmp(action,'Update')||strcmp(action,'CreateNoUI')||strcmp(action,'Update4MultRunnable');
        is4MultRunnable=strcmp(action,'Update4MultRunnable')||strcmp(action,'Create4MultRunnable');

        try
            block_hdl=get_param(block_hdl,'Handle');
        catch %#ok<CTCH>
            errMsg=DAStudio.message('RTW:fcnClass:invalidBlock',block_hdl);
            return;
        end

        block_name=getfullname(block_hdl);

        try
            if(strcmpi(get_param(block_hdl,'Type'),'Block')==0)
                errMsg=DAStudio.message('RTW:fcnClass:invalidBlock',block_name);
                return;
            end
        catch %#ok<CTCH>
            errMsg=DAStudio.message('RTW:fcnClass:invalidBlock',block_name);
            return;
        end

        try
            if(strcmpi(get_param(block_hdl,'BlockType'),'SubSystem')==0)
                errMsg=DAStudio.message('RTW:fcnClass:invalidBlock',block_name);
                return;
            end
        catch %#ok<CTCH>
            errMsg=DAStudio.message('RTW:fcnClass:invalidBlock',block_name);
            return;
        end

        if~updateOnly
            udata=LocalRetrieveThisUserData(USERDATA,block_hdl,'BLK_HDL');
            if~isempty(udata)
                entry=udata(1);
                hDlg=entry.HDLG;
                if isa(hDlg,'DAStudio.Dialog')
                    hDlg.show();
                    fcnclass=hDlg.getSource.fcnclass;
                    return;
                end
            end
        end

        ssType=Simulink.SubsystemType(block_hdl);
        isVirtual=ssType.isVirtualSubsystem();
        topMdl=bdroot(block_hdl);
        cs=getActiveConfigSet(topMdl);
        isERT=strcmp(get_param(cs,'IsERTTarget'),'on');

        inCppClassGenMode=strcmpi(get_param(cs,'IsCPPClassGenMode'),'on');

        isMdlStepFcnProtoCompliant=...
        strcmp(get_param(cs,'ModelStepFunctionPrototypeControlCompliant'),'on');

        isAutosarCompliant=...
        strcmp(get_param(cs,'AutosarCompliant'),'on');

        if~inCppClassGenMode
            if~(isMdlStepFcnProtoCompliant||isAutosarCompliant)
                errMsg=DAStudio.message('RTW:fcnClass:nonMdlStepFcnProtoCompliant');
                return;
            end
        end

        isExportFunctions=ssType.isFunctionCallSubsystem();

        if isVirtual&&~isAutosarCompliant

            errMsg=DAStudio.message('RTW:fcnClass:notAtomicSubsys',block_name);
            return;
        end

        if~isERT
            errMsg=DAStudio.message('RTW:fcnClass:nonERT');
            return;
        end





        if strcmpi(get_param(topMdl,'LibraryType'),'BlockLibrary')
            errMsg=DAStudio.message('RTW:fcnClass:subsysInLibrary',block_name);
            return;
        end


        try
            if~inCppClassGenMode
                [tempMdl,~,error_occ,mexc]=coder.internal.ss2mdl(block_hdl,...
                'ConfigureAutosar',isAutosarCompliant,...
                'ExportFunctions',isExportFunctions,...
                'AutosarMultiRunnable',is4MultRunnable);
            else
                [tempMdl,~,error_occ,mexc]=coder.internal.ss2mdl(block_hdl);
            end


            newModelFile=[getfullname(tempMdl),Simulink.ModelReference.Conversion.Utilities.ModelFileExtension];
            if exist(newModelFile,'file')
                delete(newModelFile);
            end

            if~isempty(mexc)
                errMsg=mexc.getReport;
            end
        catch me

            errMsg=me.getReport;
            return;
        end

        if error_occ

            if isempty(errMsg)
                errMsg=DAStudio.message('RTW:fcnClass:ss2mdlFailed',block_name);
            end
            return;
        end

        if~updateOnly
            if~inCppClassGenMode
                fcnclass=get_param(block_hdl,'SSRTWFcnClass');
                if isempty(fcnclass)
                    if strcmp(get_param(tempMdl,'AutosarCompliant'),'off')


                        fcnclass=RTW.FcnDefault('',tempMdl);
                        DAStudio.warning('coderdictionary:mapping:SubsystemFpcNewConfigurationForC',...
                        getfullname(block_hdl));
                    end
                else
                    fcnclass.ModelHandle=tempMdl;
                end
            else
                fcnclass=get_param(block_hdl,'SSRTWCPPFcnClass');
                if isempty(fcnclass)


                    fcnclass=RTW.ModelCPPDefaultClass('',tempMdl);
                    DAStudio.warning('coderdictionary:mapping:SubsystemFpcNewConfigurationForCPP',...
                    getfullname(block_hdl));
                else
                    fcnclass.ModelHandle=tempMdl;
                end
            end
        else
            if~nonUI
                udata=LocalRetrieveThisUserData(USERDATA,block_hdl,'BLK_HDL');
                if~isempty(udata)
                    entry=udata(1);
                    fcnclass=entry.HDLG.getSource.fcnclass;
                else
                    if strcmp(get_param(tempMdl,'AutosarCompliant'),'off')
                        fcnclass=RTW.FcnDefault('',tempMdl);
                    end
                end
            else
                fcnclass=varargin{1};
            end
        end
        fcnclass.RightClickBuild=true;
        fcnclass.SubsysBlockHdl=block_hdl;

        if~isequal(fcnclass.ModelHandle,tempMdl)
            fcnclass.ModelHandle=tempMdl;
            if~isempty(fcnclass.cache)
                fcnclass.cache.ModelHandle=tempMdl;
            end
        end
        if nonUI
            if~updateOnly
                USERDATA=...
                LocalCacheUserData(USERDATA,...
                tempMdl,topMdl,block_hdl,fcnclass.viewWidget);
            else
                USERDATA=...
                LocalUpdateUserData(USERDATA,...
                tempMdl,topMdl,block_hdl,fcnclass.viewWidget);
            end
            return;
        end

        if~isa(fcnclass.viewWidget,'DAStudio.Dialog')
            if~inCppClassGenMode
                fcnclassUI=RTW.FcnCtlUI(fcnclass,[]);
            else
                fcnclassUI=RTW.CPPFcnCtlUI(fcnclass);
            end
            hDlg=DAStudio.Dialog(fcnclassUI);
            fcnclass.viewWidget=hDlg;
        else
            hDlg=fcnclass.viewWidget;
            fcnclassUI=hDlg.getSource;
        end

        if~updateOnly
            USERDATA=LocalCacheUserData(USERDATA,tempMdl,topMdl,block_hdl,hDlg);
        else
            USERDATA=LocalUpdateUserData(USERDATA,tempMdl,topMdl,block_hdl,hDlg);
        end
        sys=get_param(topMdl,'object');
        LocalCheckCloseListener(sys,fcnclassUI);


    case 'Close'
        ind=0;
        for i=1:length(USERDATA)
            thisdata=USERDATA(i);
            if(thisdata.BLK_HDL==block_hdl)
                ind=i;
                try
                    close_system(thisdata.TMP_MDL,0);
                catch me %#ok<NASGU>


                end
                break;
            end
        end
        USERDATA=[USERDATA(1:(ind-1)),USERDATA((ind+1):end)];
        rtwprivate('rtwattic','clean');
    case 'ModelClose'

        udata=[];
        toDelete=[];
        for i=1:length(USERDATA)
            thisdata=USERDATA(i);
            if(thisdata.BLK_MDL~=mdl_hdl)
                udata=[udata,thisdata];%#ok<AGROW>
            else
                try
                    close_system(thisdata.TMP_MDL,0);
                catch me %#ok<NASGU>


                end
                toDelete=[toDelete,thisdata.HDLG];%#ok<AGROW>
            end
        end
        USERDATA=udata;
        for i=1:length(toDelete)
            toDelete(i).delete();
        end
        rtwprivate('rtwattic','clean');
    otherwise
        DAStudio.error('RTW:fcnClass:unknownCaseError');
    end



    function userdata=LocalCacheUserData(userdata,temp_model,blk_model,blk_hdl,hDlg)

        newdata.TMP_MDL=temp_model;
        newdata.BLK_MDL=blk_model;
        newdata.BLK_HDL=blk_hdl;
        newdata.HDLG=hDlg;

        if isempty(userdata)
            userdata=newdata;
        else
            userdata(end+1)=newdata;
        end

        function userdata=LocalUpdateUserData(userdata,temp_model,blk_model,blk_hdl,hDlg)

            for i=1:length(userdata)
                data=userdata(i);
                h=data.BLK_HDL;
                if(h==blk_hdl)
                    if~slfeature('RightClickBuild')

                        try
                            close_system(userdata(i).TMP_MDL,0);
                        catch me %#ok<NASGU>

                        end
                    end

                    userdata(i).TMP_MDL=temp_model;
                    userdata(i).BLK_MDL=blk_model;
                    if isa(hDlg,'DAStudio.Dialog')
                        userdata(i).HDLG=hDlg;
                    end
                    break;
                end
            end


            function udata=LocalRetrieveThisUserData(userdata,hdl,fieldname)
                udata=[];
                for i=1:length(userdata)
                    data=userdata(i);%#ok<NASGU>
                    h=eval(['data.',fieldname]);
                    if(h==hdl)
                        udata=[udata,userdata(i)];%#ok<AGROW>
                        break;
                    end
                end



                function LocalCheckCloseListener(theSys,uddUI)

                    listnerObj=Simulink.listener(theSys,'CloseEvent',@LocalCloseCB);
                    uddUI.closeListener=listnerObj;



                    function LocalCloseCB(eventSrc,eventData)%#ok<INUSD>
                        cs=eventSrc.getActiveConfigSet();
                        hMdl=cs.getModel();
                        coder.internal.configFcnProtoSSBuild(-1,hMdl,'ModelClose');



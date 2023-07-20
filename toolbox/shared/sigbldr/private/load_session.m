function UD=load_session(UD,blockH)







    fromWsH=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','FromWorkspace');

    saveStruct=get_param(fromWsH,'SigBuilderData');


    if~check_save_struct(saveStruct)
        errordlg(getString(message('sigbldr_blk:load_session:CannotDecodeData')));
        return;
    end

    UD=restore_from_saveStruct(UD,saveStruct);





    grpsToUpdate=1:saveStruct.sbobj.NumGroups;

    UD=update_time_range(UD,UD.sbobj,grpsToUpdate,0);

    dsIdx=UD.current.dataSetIdx;
    if isempty(UD.dataSet(dsIdx).activeDispIdx)
        UD.current.channel=0;
    else
        UD.current.channel=UD.dataSet(dsIdx).activeDispIdx(end);
    end

    UD=update_channel_select(UD);
    UD=update_show_menu(UD);






    if~in_a_library(blockH)
        if isfield(saveStruct,'isVerificationVisible')&&...
            ~isempty(saveStruct.isVerificationVisible)&&...
            saveStruct.isVerificationVisible&&vnv_rmi_installed

            UD.simulink.subsysH=blockH;


            modelH=bdroot(blockH);
            vnv_assert_mgr('mdlPostLoad',modelH);

            UD=verifyView(UD);
            set(UD.toolbar.verifyView,'state','on');
        end
    end

    UD=reset_dirty_flag(UD);
end

function isok=check_save_struct(saveStruct)


    isok=0;
    if~isfield(saveStruct,'gridSetting')
        return;
    end
    if~isfield(saveStruct,'channels')
        return;
    end
    if~isfield(saveStruct,'axes')
        return;
    end
    if~isfield(saveStruct,'common')
        return;
    end
    if~isfield(saveStruct,'dataSet')
        return;
    end

    isok=1;
end
function result=in_a_library(blockH)

    modelH=bdroot(blockH);
    if strcmpi(get_param(modelH,'BlockDiagramType'),'library')
        result=1;
    else
        result=0;
    end
end


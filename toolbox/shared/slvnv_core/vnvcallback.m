function vnvcallback(method,modelH,isLib)

    if strcmp(method,'reset')
        rmi_sl_callback('reset',[]);
        slcoverage_callback('reset',[]);
        return;
    end

    if any(strcmp(method,{'postLoad','init','preSave','close','forceClose','resolveLink','open'}))
        rmi_sl_callback(method,modelH);
    end

    if any(strcmp(method,{'init','close','forceClose','postLoad'}))
        exectime_profiling_callback(method,modelH);
    end

    if nargin<3
        isLib=strcmpi(get_param(modelH,'BlockDiagramType'),'library');
    end
    if isLib
        return;
    end

    if any(strcmp(method,{'postLoad','preSave','unhighlight','init','open','close','forceClose'}))
        slcoverage_callback(method,modelH);
    end

    switch(method)

    case 'postLoad'

        vnv_assert_mgr('mdlPostLoad',modelH);

    case 'init'
        vnv_assert_mgr('mdlInit',modelH);

    case 'start'
    case 'stop'
    case 'preSave'

        vnv_assert_mgr('mdlPreSave',modelH);

    case 'vnvForceRefresh'
        vnv_assert_mgr('mdlForceRefresh',modelH);

    case 'vnvDirty'
        vnv_assert_mgr('mdlVnvDirty',modelH);

    case{'close','forceClose'}

    case 'unhighlight'

        dvData=get_param(modelH,'AutoVerifyData');
        if~isempty(dvData)&&isfield(dvData,'modelView')&&dvData.modelView.isvalid
            dvData.modelView.remove_highlight;
        end

    case{'resolveLink','open'}
    case 'unknown'
    otherwise
        error(message('Slvnv:vnvcallback:UnexpectedNotification',method));
    end
end




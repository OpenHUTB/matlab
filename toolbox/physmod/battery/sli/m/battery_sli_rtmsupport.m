function varargout=battery_sli_rtmsupport(event,handle)





    if nargout>0
        pm_assert(isequal(lower(event),'parametereditingmodes'))
    end




    switch lower(event)
    case 'mask'
        pmsl_rtmcallback(handle,'');
    case 'loadfcn'
        pmsl_rtmcallback(handle,'BLK_POSTLOAD');
    case 'copyfcn'
        pmsl_rtmcallback(handle,'BLK_POSTCOPY');
    case 'precopyfcn'
        pmsl_rtmcallback(handle,'BLK_PRECOPY');
    case 'predeletefcn'
        pmsl_rtmcallback(handle,'BLK_PREDELETE');
    case 'deletefcn'
        pmsl_rtmcallback(handle,'BLK_POSTDELETE');
    case 'presavefcn'
        pmsl_rtmcallback(handle,'BLK_PRESAVE');
    case 'postsavefcn'
        pmsl_rtmcallback(handle,'BLK_POSTSAVE');
    case 'openfcn'

        l_get_parameter_editing_modes(get_param(handle,'Handle'),true);

        open_system(handle,'Mask');
    case 'parametereditingmodes'

        varargout{1}=l_get_parameter_editing_modes(get_param(handle,'Handle'),false);
    case 'blockcompile'
        pmsl_rtmcallback(handle,'BLK_PRECOMPILE');
    case 'modelcompile'
        pmsl_rtmcallback(handle,'DOM_INIT');
    case{'closefcn','modelclosefcn'}
        pmsl_rtmcallback(handle,'MODEL_CLOSE');
    otherwise
        pm_abort(getString(message('physmod:battery:library:UnknownCallback')));
    end



    function editModes=l_get_parameter_editing_modes(handle,updateMaskEnables)


        restrictedParameterList=sort([find(cellfun(@any,strfind(get_param(handle,'MaskStyles'),'checkbox')));...
        find(cellfun(@any,strfind(get_param(handle,'MaskStyles'),'popup')))])';


        authoringParams=get_param(handle,'MaskNames');
        editModes=battery_setparammode(authoringParams(abs(restrictedParameterList)));

        modelparams=get_param(bdroot(handle),'ObjectParameters');
        modelInRestrictedMode=false;
        if isfield(modelparams,'EditingMode')&&strcmp(get_param(bdroot(handle),'EditingMode'),'Restricted')
            modelInRestrictedMode=true;
        elseif~pmsl_checklicense('simscape_battery')
            modelInRestrictedMode=true;
        end

        if~strcmp(get_param(bdroot(handle),'BlockDiagramType'),'library')
            if updateMaskEnables&&modelInRestrictedMode
                maskEnables=get_param(handle,'MaskEnables');
                for i=1:length(restrictedParameterList)
                    maskEnables{restrictedParameterList(i)}='off';
                end
                set_param(handle,'MaskEnables',maskEnables);
            end
        end


        function rtmAuthoringParams=battery_setparammode(authoringModeParams)





            rtmAuthoringParams=struct('maskName',{},'editingMode',{});
            authoringEnum=ssc_param('authoring');
            for i=1:length(authoringModeParams)
                rtmAuthoringParams(i).maskName=authoringModeParams{i};
                rtmAuthoringParams(i).editingMode=authoringEnum;
            end

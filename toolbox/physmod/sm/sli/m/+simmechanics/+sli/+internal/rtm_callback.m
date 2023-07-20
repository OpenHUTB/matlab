function varargout=rtm_callback(event,handle)




    switch lower(event)
    case 'mask'
        callback_helper(handle,'');
    case 'loadfcn'
        callback_helper(handle,'BLK_POSTLOAD');
    case 'copyfcn'
        callback_helper(handle,'BLK_POSTCOPY');
    case 'precopyfcn'
        callback_helper(handle,'BLK_PRECOPY');
    case 'predeletefcn'
        callback_helper(handle,'BLK_PREDELETE');
    case 'deletefcn'
        callback_helper(handle,'BLK_POSTDELETE');
    case 'presavefcn'
        callback_helper(handle,'BLK_PRESAVE');
    case 'postsavefcn'
        callback_helper(handle,'BLK_POSTSAVE');
    case 'parametereditingmodes'

        varargout{1}=l_get_authoring_mode_params(handle);
    case 'blockcompile'
        callback_helper(handle,'BLK_PRECOMPILE');
    case 'modelcompile'
        callback_helper(handle,'DOM_INIT');
    case 'modelclosefcn'
        callback_helper(handle,'MODEL_CLOSE');
    otherwise
        pm_abort('Unknown callback');
    end

    function callback_helper(handle,varargin)



        persistent AVAILABLE;
        if isempty(AVAILABLE)
            AVAILABLE=exist('private/ssc_checklicense','file');
            if~AVAILABLE
                disp('ssc_checklicense not available');
            end
        end





        if AVAILABLE
            pmsl_rtmcallback(handle,varargin{:});
        elseif~strcmp(get_param(bdroot(handle),'BlockDiagramType'),'library')
            pm_error('physmod:ne_sli:nesl_callback:SimscapeNotAvailable');
        end

        function amodeParams=l_get_authoring_mode_params(handle)



            persistent EditingModeMap
            blockFunction=get_param(handle,'BlockFunction');

            if isempty(EditingModeMap)
                EditingModeMap=containers.Map('KeyType','char','ValueType','any');
            end
            mlock;

            if EditingModeMap.isKey(blockFunction)
                amodeParams=EditingModeMap(blockFunction);
            else
                blockInfo=eval(blockFunction);

                offIdx=strcmpi({blockInfo.MaskParameters.Evaluate},'off');

                amode=repmat({ssc_param('authoring')},1,sum(offIdx));
                amodeParams=cell2struct({blockInfo.MaskParameters(offIdx).VarName;
                amode{:}},...
                {'maskName','editingMode'},1);

                EditingModeMap(blockFunction)=amodeParams;
            end



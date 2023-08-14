function varargout=sps_rtmsupport(event,handle,varargin)







    if nargout>0
        pm_assert(isequal(lower(event),'parametereditingmodes'))
    end




    if~isempty(varargin)

        RestrictedParameterList=varargin{1};
    else
        RestrictedParameterList=[];
    end

    RestrictedParameterList=sort([find(cellfun(@any,strfind(get_param(handle,'MaskStyles'),'checkbox')));...
    find(cellfun(@any,strfind(get_param(handle,'MaskStyles'),'popup')))])';

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

        set_mask_enables(handle,RestrictedParameterList,true);

        open_system(handle,'Mask');
    case 'openfcnpi'

        set_mask_enables(handle,RestrictedParameterList,true);
    case 'parametereditingmodes'


        if nargout==0
            set_mask_enables(handle,RestrictedParameterList,false);
        else
            varargout{1}=set_mask_enables(handle,RestrictedParameterList,false);
        end
    case 'blockcompile'
        pmsl_rtmcallback(handle,'BLK_PRECOMPILE');
    case 'modelcompile'
        pmsl_rtmcallback(handle,'DOM_INIT');
    case{'closefcn','modelclosefcn'}
        pmsl_rtmcallback(handle,'MODEL_CLOSE');
    otherwise

    end


    function editModes=set_mask_enables(handle,RestrictedParameterList,UpdateMask)

        editModes=[];

        switch sps_Authoring(bdroot(handle))

        case 0




            S='off';



            L=abs(RestrictedParameterList);











            UpdateMask=true;


        case 1




            S='on';





            L=RestrictedParameterList(RestrictedParameterList>0);







        end


        if UpdateMask&&~isempty(RestrictedParameterList)

            MaskEnables=get_param(handle,'MaskEnables');
            for i=1:length(L)
                MaskEnables{L(i)}=S;
            end
            if strcmp(get_param(bdroot(handle),'BlockDiagramType'),'library')

                return
            else
                set_param(handle,'MaskEnables',MaskEnables);
            end
        end



        authoringParams=get_param(handle,'MaskNames');
        editModes=power_setparammode(authoringParams(abs(RestrictedParameterList)));




        function rtmAuthoringParams=power_setparammode(authoringParams)







            rtmAuthoringParams=[];
            authoringEnum=ssc_param('authoring');
            for i=1:length(authoringParams)
                rtmAuthoringParams(i).maskName=authoringParams{i};
                rtmAuthoringParams(i).editingMode=authoringEnum;
            end

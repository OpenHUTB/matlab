function displist=rtwsfunc(rtw_sf_name,block)

    if~strcmpi(get_param(bdroot,'RapidAcceleratorSimStatus'),'inactive')

        [srcCodeExists,~]=...
        sl(...
        'rapid_accel_target_utils',...
        'find_sfcn_source_code',...
rtw_sf_name...
        );

        skipMake=...
        slfeature('RapidAcceleratorSFcnMexFileLoading')==2||...
        (slfeature('RapidAcceleratorSFcnMexFileLoading')==1&&~srcCodeExists);

        if skipMake
            displist=DAStudio.message('Simulink:masks:GenSFuncNone_IC');
            return;
        end

    end

    sfmodules='';sflibs='';usermodules='';
    if exist(rtw_sf_name,'file')==3
        mkpath=which(rtw_sf_name);
        modelname=rtw_sf_name(1:end-3);
        sfcn_sizes=feval(rtw_sf_name,[],[],[],0);
        if sfcn_sizes(31)==1
            mkfile=strrep(mkpath,[rtw_sf_name,'.',mexext],...
            [modelname,'_sfcn_rtw',filesep,modelname,'.mk']);
        else
            mkfile=strrep(mkpath,[rtw_sf_name,'.',mexext],...
            [modelname,'_ert_rtw',filesep,modelname,'.mk']);
        end


        buildInfoName=fullfile(fileparts(mkfile),'buildInfo.mat');
        bi=load(buildInfoName,'buildInfo');
        lMakeArgs=bi.buildInfo.MakeArgs;
        usermodules=coder.make.internal.parsestrforvar(lMakeArgs,'USER_SRCS');
        userobjs=coder.make.internal.parsestrforvar(lMakeArgs,'USER_OBJS');
        usermodules=[usermodules,' ',userobjs];

        sfmodules=coder.internal.getSfcnModules(bi.buildInfo);
        sfmodules=strjoin(sfmodules);
        [sfcnLinkObjs]=coder.make.internal.getLibTypes(bi.buildInfo,{});
        if~isempty(sfcnLinkObjs)
            sflibs=strjoin(get(sfcnLinkObjs,'Name'));
        end
    end

    sflist=strrep(sfmodules,'.cpp','');
    sflist=strrep(sflist,'.c','');
    sflist=strrep(sflist,'.obj','');
    userlist=strrep(usermodules,'.cpp','');
    userlist=strrep(userlist,'.c','');
    userlist=strrep(userlist,'.obj','');
    list=[sflist,' ',userlist,' ',sflibs];


    list=regexprep(list,' ([^ ]*[\\/])[^ ]*','');


    if strcmp(get_param(bdroot(block),'SimulationStatus'),'initializing')&&...
        strcmp(get_param(block,'LinkStatus'),'none')
        set_param(block,'sfunctionmodules',list);
    end

    sflist=strrep(sfmodules,'.c','.c\n');
    sflist=strrep(sflist,'.obj','.c\n');
    userlist=strrep(usermodules,'.c','.c\n');
    userlist=strrep(userlist,'.obj','.c\n');
    sflibs=strrep(sflibs,'.lib','.lib\n');
    sflibs=strrep(sflibs,'.a','.a\n');
    displist=[sflist,userlist,sflibs];

    if isempty(deblank(displist))
        displist=DAStudio.message('Simulink:masks:GenSFuncNone_IC');
    end


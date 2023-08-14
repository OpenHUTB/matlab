function grt_ert_switch_target(model,stf_grt,stf_ert,requested_tgt,reapply_params)
















    narginchk(4,5);

    if nargin<5

        reapply_params={};
    end

    ert_licensed=(builtin('_license_checkout','RTW_Embedded_Coder','quiet')...
    ==0);
    ert_installed=exist('ert_make_rtw_hook.m','file');
    ert_available=ert_licensed&&ert_installed;

    switch lower(requested_tgt)
    case 'ert'
        if ert_available
            newSysTargetFile=stf_ert;
        else
            TargetCommon.ProductInfo.error('common','NoERTLicense');
        end
    case 'grt'
        newSysTargetFile=stf_grt;
    case 'auto'
        if ert_available
            newSysTargetFile=stf_ert;
        else
            newSysTargetFile=stf_grt;
        end
    otherwise
        TargetCommon.ProductInfo.error('common','InvalidTarget',requested_tgt);
    end

    cs=i_getActiveConfigSet(model);

    systemTargetFile=get_param(cs,'SystemTargetFile');


    if strcmp(systemTargetFile,newSysTargetFile)
        if strcmp(requested_tgt,'auto')
            return
        else
            TargetCommon.ProductInfo.warning('common','NoSwitchRequired',cs.name,newSysTargetFile);
            return;
        end
    end


    if~any(strcmp(systemTargetFile,{stf_grt,stf_ert}))
        TargetCommon.ProductInfo.error('common','InvalidSTF',stf_grt,stf_ert);
    end


    origCS=cs.copy;


    settings.TemplateMakefile=strrep(newSysTargetFile,'.tlc','.tmf');
    cs.switchTarget(newSysTargetFile,settings);


    i_restoreSettings(origCS,cs,reapply_params);

    function i_restoreSettings(origCS,cs,reapply_params)

        for i=1:length(reapply_params)
            prop=reapply_params{i};
            try
                i_restoreParamSetting(prop,origCS,cs);
            catch %#ok


            end
        end

        function i_restoreParamSetting(prop,origCS,cs)
            val=get_param(origCS,prop);
            enabledState=origCS.getPropEnabled(prop);
            set_param(cs,prop,val);
            cs.setPropEnabled(prop,enabledState);


            function cs=i_getActiveConfigSet(model)

                switch class(model)
                case 'char'

                    model=strtok(model,'/');

                    cs=getActiveConfigSet(model);
                case 'Simulink.ConfigSet'

                    cs=model;
                otherwise
                    TargetCommon.ProductInfo.error('common','InvalidInputModelOrCS');
                end



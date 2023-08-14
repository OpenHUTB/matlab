
function[params,groups,FC]=get_CCSTargetConfig_HostTargetConfig_data(cs)

    compStatus=0;
    params={};


    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={0,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={2,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,3);

        p_widgets{1}={};

        p_widgets{2}={};

        w_st=configset.internal.custom.showCcsLoadProgram(cs,'CcsLoadProgram');
        p_widgets{3}={{'st',w_st}};
        params{end+1}={3,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end


    groups={};













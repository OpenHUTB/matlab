
function[params,groups,FC]=get_Simulink_CPPComponent_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('Simulink.CPPComponent');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


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



    if compStatus<3
    end


    groups={};

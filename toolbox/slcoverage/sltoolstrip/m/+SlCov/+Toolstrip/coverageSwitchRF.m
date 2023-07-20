function coverageSwitchRF(cbinfo,action)



    try
        covEnabled=strcmp(get_param(cbinfo.model.name,'CovEnable'),'on');
    catch Mex %#ok<NASGU> 
        covEnabled=false;
    end

    if covEnabled
        action.text='Slvnv:simcoverage:toolstrip:DefaultSwitchCovAnalysisActionONText';
        action.icon='coverageSwitchStatusOn';
        action.selected=true;
    else
        action.text='Slvnv:simcoverage:toolstrip:DefaultSwitchCovAnalysisActionOFFText';
        action.icon='coverageSwitchStatusOff';
        action.selected=false;
    end

end

function exportToWebRF(~,action)



    if license('test','MATLAB_Report_Gen')||license('test','SIMULINK_Report_Gen')
        action.enabled=true;
    else
        action.enabled=false;
    end
end


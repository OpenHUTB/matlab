function licStatus=autosharedeval(licType)




    switch licType
    case '1'
        licOrder=1;
    case '2'
        licOrder=2;
    case '3'
        licOrder=3;
    case '4'
        licOrder=2;
    case '5'
        licOrder=[4,1];
    case '6'
        licOrder=5;
    case '-1'
        licOrder=-1;
    otherwise
        licOrder=1:2;
    end
    for idx=1:length(licOrder)
        if licOrder(idx)==0&&builtin('license','test','Aerospace_Toolbox')
            licStatus=builtin('license','checkout','Aerospace_Toolbox');
            break
        elseif licOrder(idx)==1&&builtin('license','test','Powertrain_Blockset')
            licStatus=builtin('license','checkout','Powertrain_Blockset');
            break
        elseif licOrder(idx)==2&&builtin('license','test','Vehicle_Dynamics_Blockset')
            licStatus=builtin('license','checkout','Vehicle_Dynamics_Blockset');
            break
        elseif licOrder(idx)==3&&builtin('license','test','Automated_Driving_Toolbox')
            licStatus=builtin('license','checkout','Automated_Driving_Toolbox');
            break
        elseif licOrder(idx)==4&&builtin('license','test','Motor_Control_Blockset')
            licStatus=builtin('license','checkout','Motor_Control_Blockset');
            break;
        elseif licOrder(idx)==5&&(builtin('license','test','Powertrain_Blockset')||builtin('license','test','Vehicle_Dynamics_Blockset'))
            licStatus=1;
            break;
        elseif licOrder(idx)==-1
            licStatus=-1;
            break
        end
        if idx==length(licOrder)
            error(message('autoblks_shared:autosharederrAutoIcon:invalidLicense'));
        end
    end
end

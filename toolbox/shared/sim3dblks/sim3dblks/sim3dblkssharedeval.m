function licStatus = sim3dblkssharedeval(licType)

    switch licType
    case '0'
        licOrder=0;
    case '2'
        licOrder=2;
    case '3'
        licOrder=3;
    case '4'
        licOrder=4;
    case '5'
        licOrder=5;
    case '-1'
        licOrder=-1;
    otherwise
        licOrder=[0,2:5];
    end

    if length(licOrder)==1
        if licOrder==0
            licStatus=builtin('license','checkout','Aerospace_Toolbox')&&builtin('license','checkout','Aerospace_Blockset');
            ASBDLic=builtin('license','test','Aerospace_Toolbox')&&builtin('license','test','Aerospace_Blockset');
            if licStatus~=1||ASBDLic~=1
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidASBLicense'));
            end
        elseif licOrder==2
            licStatus=builtin('license','checkout','Vehicle_Dynamics_Blockset');
            VDBSLic=builtin('license','test','Vehicle_Dynamics_Blockset');
            if licStatus~=1||VDBSLic~=1
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidVDBSLicense'));
            end
        elseif licOrder==3
            licStatus=builtin('license','checkout','Automated_Driving_Toolbox');
            ADTLic=builtin('license','test','Automated_Driving_Toolbox');
            if licStatus~=1||ADTLic~=1
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidADTLicense'));
            end
        elseif licOrder==4
            licStatus=builtin('license','checkout','UAV_Toolbox');
            UAVLic=builtin('license','test','UAV_Toolbox');
            if licStatus~=1||UAVLic~=1
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidUAVLicense'));
            end
        elseif licOrder==5
            licStatus=builtin('license','checkout','virtual_reality_toolbox');
            SL3DLic=builtin('license','test','virtual_reality_toolbox');
            if licStatus~=1||SL3DLic~=1
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidSL3DLicense'));
            end
        elseif licOrder==-1
            licStatus=-1;
        end

    else
        for idx=1:length(licOrder)
            if licOrder(idx)==0&&builtin('license','test','Aerospace_Toolbox')
                licStatus=builtin('license','checkout','Aerospace_Toolbox');
                break
            elseif licOrder(idx)==2&&builtin('license','test','Vehicle_Dynamics_Blockset')
                licStatus=builtin('license','checkout','Vehicle_Dynamics_Blockset');
                break
            elseif licOrder(idx)==3&&builtin('license','test','Automated_Driving_Toolbox')
                licStatus=builtin('license','checkout','Automated_Driving_Toolbox');
                break
            elseif licOrder(idx)==4&&builtin('license','test','UAV_Toolbox')
                licStatus=builtin('license','checkout','UAV_Toolbox');
                break
            elseif licOrder(idx)==5&&builtin('license','test','virtual_reality_toolbox')
                licStatus=builtin('license','checkout','virtual_reality_toolbox');
                break
            end
            if idx==length(licOrder)
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidLicense'));
            end
        end
    end
end

function aeroshared(licType)






    switch licType
    case '0'
        licOrder=0;
    case '1'
        licOrder=1;
    case '2'
        licOrder=2;
    case '3'
        licOrder=3;
    case '-1'
        licOrder=-1;
    otherwise
        licOrder=0;
    end




    if licOrder==0

        if builtin('license','test','Aerospace_Toolbox')

            builtin('license','checkout','Aerospace_Toolbox');
        end
    elseif licOrder==1&&license('test','Powertrain_Blockset')
        builtin('license','checkout','Powertrain_Blockset');
    elseif licOrder==2&&license('test','Vehicle_Dynamics_Blockset')
        builtin('license','checkout','Vehicle_Dynamics_Blockset');
    elseif licOrder==3&&builtin('license','test','Automated_Driving_Toolbox')
        builtin('license','checkout','Automated_Driving_Toolbox');
    elseif licOrder==-1

    else
        error(message('shared_aeroblks:sharedaeroicon:invalidLicense'));
    end
end
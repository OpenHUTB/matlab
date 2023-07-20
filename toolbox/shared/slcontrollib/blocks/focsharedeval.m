function[licStatus,errMsg]=focsharedeval(licType)




    switch licType
    case '1'
        licOrder=1;
    case '2'
        licOrder=2;
    case '-1'
        licOrder=-1;
    otherwise
        licOrder=1;
    end

    errMsg='';
    licStatus=-2;
    for idx=1:length(licOrder)
        if licOrder(idx)==1&&builtin('license','test','Motor_Control_Blockset')

            [licStatus,errMsg]=builtin('license','checkout','Motor_Control_Blockset');
            if licStatus&&builtin('license','test','Simulink_Control_Design')
                [licStatus,errMsg]=builtin('license','checkout','Simulink_Control_Design');
                break
            end
        elseif licOrder(idx)==2&&builtin('license','test','Simulink_Control_Design')

            [licStatus,errMsg]=builtin('license','checkout','Simulink_Control_Design');
            if licStatus&&builtin('license','test','Motor_Control_Blockset')
                [licStatus,errMsg]=builtin('license','checkout','Motor_Control_Blockset');
                break
            end
        elseif licOrder(idx)==-1
            licStatus=-1;
            break
        end
        if idx==length(licOrder)&&isempty(errMsg)
            error(message('SLControllib:focautotuner:errInvalidLicense'));
        end
    end
    if licStatus==-2
        error(message('SLControllib:focautotuner:errInvalidLicense'));
    end
end

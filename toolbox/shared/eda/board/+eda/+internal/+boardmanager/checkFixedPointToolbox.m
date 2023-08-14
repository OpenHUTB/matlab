function checkFixedPointToolbox



    persistent isFPTAvailable;

    if isempty(isFPTAvailable)
        isFPTAvailable=~isempty(ver('fixedpoint'));
        isFPTAvailable=isFPTAvailable&&license('test','Fixed_Point_Toolbox');
    end

    if~isFPTAvailable
        warning(message('EDALink:boardmanager:FixedPointToolboxNotAvailable'));
    end

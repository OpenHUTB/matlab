function ret=decideToShowTaskingUtilMenu




    mlock;
    persistent state;

    if isempty(state)
        state='Enabled';
        if~linkfoundation.util.isMWSoftwareInstalled('rtw')
            state='Disabled';
        end
    end
    ret=state;
end

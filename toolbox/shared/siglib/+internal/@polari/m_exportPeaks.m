function m_exportPeaks(p)


    assignin('base','peaks',p.PeakMarkers);
    str='Exported <a href="matlab:eval(''peaks'')">peaks</a> variable to the base workspace.';
    disp(str);
    showBannerMessage(p,'Exported ''peaks'' variable to the base workspace.');

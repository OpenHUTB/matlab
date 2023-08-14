function isInstalled=isSLCoverageInstalled()



    isInstalled=~isempty(which('cvsim'))&&license('test','Simulink_Coverage');
end


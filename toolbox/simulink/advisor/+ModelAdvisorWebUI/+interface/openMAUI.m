function openMAUI(modelname,browserMode)



    if nargin==0
        disp('Please enter the valid model name');
        return
    end

    if nargin==1
        browserMode='Chrome';
    end
    if strcmp(browserMode,'Chrome')
        Advisor.AdvisorWindow.debugMode(true);
    end
    Advisor.AdvisorWindow.browserMode(browserMode);
    t=Advisor.AdvisorWindow(modelname);
    t.open;
end
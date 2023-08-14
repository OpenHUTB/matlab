function[statusIcon,altText]=getLinkTestStatus(reqLink)



    icondir=fullfile(matlabroot,'toolbox','shared',...
    'reqmgt','icons');
    resultsManager=slreq.data.ResultManager.getInstance();
    result=resultsManager.getResult(reqLink);

    if isempty(result)
        verifTooltip='Unknown';
        thisImage=fullfile(icondir,'unknown.png');
    elseif result==slreq.verification.ResultStatus.Pass
        verifTooltip='Passed';
        thisImage=fullfile(icondir,'check.png');
    elseif result==slreq.verification.ResultStatus.Fail
        verifTooltip='Failed';
        thisImage=fullfile(icondir,'failed.png');
    else
        verifTooltip='Not Run';
        thisImage=fullfile(icondir,'unknown.png');
    end




    altText=verifTooltip;
    statusIcon=thisImage;
end
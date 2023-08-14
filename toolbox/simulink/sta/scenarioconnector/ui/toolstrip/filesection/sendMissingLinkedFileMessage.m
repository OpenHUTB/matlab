function sendMissingLinkedFileMessage(cellOfFilesNotFound,appID)


    msgTopics=Simulink.sta.ScenarioTopics();


    subChannel='sta/mainui/diagnostic/request';
    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appID,subChannel);


    if length(cellOfFilesNotFound)<=5

        theFileStr=sprintf('<br><br>%s',cellOfFilesNotFound{1});

        for k=2:length(cellOfFilesNotFound)

            theFileStr=sprintf('%s<br>%s',theFileStr,cellOfFilesNotFound{k});

        end

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_sta_general:common:Error',...
        DAStudio.message('sl_sta:scenarioconnector:lessThanFiveNotFound',theFileStr));

    else
        slwebwidgets.errordlgweb(fullChannel,...
        'sl_sta_general:common:Error',...
        DAStudio.message('sl_sta:scenarioconnector:moreThanFiveNotFound'));

    end




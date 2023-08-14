function URL=getURL(clientID)




    URL='/toolbox/shared/drivingvisuals/web/birdseyescope/birdseyescope-simulink';
    postFix=['.html?ClientID=',clientID];
    feature=slfeature('slBirdsEyeScopeApp');

    if feature<2||feature>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);

end


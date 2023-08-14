function refLink=generateHelpViewLink(mapKey,topicID,linkText)
    linkText=strtrim(linkText);
    if linkText(end)==':'
        linkText=linkText(1:end-1);
    end
    refLink=['<a href="matlab:helpview(''mapkey:'...
    ,mapKey,''','''...
    ,topicID,''')">'...
    ,linkText,'</a>'];
end
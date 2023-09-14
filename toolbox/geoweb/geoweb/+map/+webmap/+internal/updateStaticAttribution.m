function config=updateStaticAttribution(config,lineWidthInChars)

    for k=1:length(config)
        url=config(k).ServerURL;
        if contains(url,"/tile/")
            attrib=...
            matlab.graphics.chart.internal.maps.DynamicAttributionReader.readStaticAttributionFromURL(url);
            if strlength(attrib)>0


                attrib=matlab.internal.display.printWrapped(...
                attrib,lineWidthInChars);


                attrib=translateToHTML(attrib);
                config(k).Attribution=char(attrib);
            end
        end
    end
end


function attribution=translateToHTML(attribution)




    ampersand=char(38);
    copyright=char(169);
    registered=char(174);
    trademark=char(8482);

    attribution=replace(attribution,ampersand,'&amp;');
    attribution=replace(attribution,copyright,'&copy;');
    attribution=replace(attribution,registered,'&reg;');
    attribution=replace(attribution,trademark,'&trade;');
    attribution=replace(attribution,newline,'<p>');



    attribution=replace(attribution,...
    'Content may not reflect National Geographic''s current map policy. ',...
    '');


    attribution=char(attribution);
    if length(attribution)>3&&isequal(attribution(end-2:end),'<p>')
        attribution(end-2:end)='';
    end
end

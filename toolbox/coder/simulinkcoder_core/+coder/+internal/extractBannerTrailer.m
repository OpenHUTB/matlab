function[banner,trailer]=extractBannerTrailer(contents)





    contents=strtrim(contents);


    banner=locExtractBanner(contents);
    trailer=locExtractTrailer(contents);

end

function banner=locExtractBanner(contents)





    if startsWith(contents,'/*')

        banner=locExtractCBanner(contents,locDefaultLineEnding(false));
    elseif startsWith(contents,'//')

        banner=locExtractCPPBanner(contents,locDefaultLineEnding(false));
    else

        banner='';
    end
end

function trailer=locExtractTrailer(contents)


    if endsWith(contents,'*/')


        trailer=flip(locExtractCBanner(flip(contents),locDefaultLineEnding(true)));
    else

        trailer=flipLines(locExtractCPPBanner(flipLines(contents),locDefaultLineEnding(false)));
    end
end

function banner=locExtractCBanner(contents,lineEnding)



    banner=regexp(contents,['^/\*(?>.+?\*/)(?=',lineEnding,')'],'match','once');
end

function banner=locExtractCPPBanner(contents,lineEnding)

    banner=regexp(contents,['^//.+?(?=',lineEnding,'[^//])'],'match','once');
end

function str=flipLines(str)

    str=strsplit(str,newline);
    str=flip(str);
    str=strjoin(str,newline);
end

function lineEnding=locDefaultLineEnding(flip)



    if flip
        lineEnding='(\n\r|\n)';
    else
        lineEnding='(\r\n|\n)';
    end
end

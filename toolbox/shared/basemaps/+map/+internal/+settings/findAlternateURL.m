function alternateURL=findAlternateURL(url)

    k=0;
    alternateURL="";
    predefinedInfo=createPredefinedAlternateURLInfo();
    url=convertCharsToStrings(url);
    while all(strlength(alternateURL)==0)&&k<length(predefinedInfo)
        k=k+1;
        alternateURL=checkURLForAlternateURL(url,predefinedInfo(k));
    end
end

function alternateURL=checkURLForAlternateURL(url,predefinedInfo)



    prefix=predefinedInfo.Prefix;
    partialHostname=predefinedInfo.PartialHostname;
    matchTypeIsExact=predefinedInfo.MatchTypeIsExact;

    uri=matlab.net.URI(url);
    if isempty(uri.Scheme)
        url="https://"+url;
        uri=matlab.net.URI(url);
    end
    host=uri.Host;

    alternateURL="";
    if matchTypeIsExact
        alternateURLs=prefix+partialHostname;
        alternateURL=findAndExcludeMatch(alternateURLs,host);

    elseif~isempty(host)&&startsWith(host,prefix)&&endsWith(host,partialHostname)



        url=extractAfter(url,uri.Scheme+"://");





        n=min(strlength(prefix));
        pos=min(n,strlength(url)-1);
        baseURL=extractAfter(url,pos);
        alternateURLs=prefix+baseURL;
        alternateURL=findAndExcludeMatch(alternateURLs,url);
    end

    if any(strlength(alternateURL)>0)
        alternateURL=uri.Scheme+"://"+alternateURL;
    end
end


function alternateURL=findAndExcludeMatch(urls,partialURL)


    index=contains(urls,partialURL);
    if any(index)
        alternateURL=urls(~index);
    else
        alternateURL="";
    end
end

function S=createPredefinedAlternateURLInfo










    S=struct("PartialHostname","","Prefix","","MatchTypeIsExact",true);
    abcHostnames=[...
    "tile.openstreetmap.org",...
    "tile.opentopomap.org"];
    S(length(abcHostnames)+1)=S;


    S(1).PartialHostname="here.com";
    S(1).Prefix=["1.","2.","3.","4."];
    S(1).MatchTypeIsExact=false;


    for k=1:length(abcHostnames)
        S(k+1).PartialHostname=abcHostnames(k);
        S(k+1).Prefix=["a.","b.","c."];
        S(k+1).MatchTypeIsExact=true;
    end
end

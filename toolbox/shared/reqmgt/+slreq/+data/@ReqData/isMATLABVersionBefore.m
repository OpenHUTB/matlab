function tf=isMATLABVersionBefore(thisVersion,compareToVersion)






    [thisYear,thisSeason]=parseVersionNumber(thisVersion);

    [compareToYear,compareToSeason]=parseVersionNumber(compareToVersion);

    if thisYear<compareToYear
        tf=true;
    elseif thisYear>compareToYear
        tf=false;
    else
        tf=thisSeason<compareToSeason;
    end

end

function[year,season]=parseVersionNumber(versionString)






    whereIsR=find(versionString=='R');
    if isempty(whereIsR)
        versionStart=0;
    else
        versionStart=whereIsR(1);
    end
    versionString(1:versionStart)=[];
    versionEnd=find(versionString==')');
    if~isempty(versionEnd)
        versionString(versionEnd(1):end)=[];
    end
    year=str2num(versionString(1:end-1));%#ok<ST2NM>
    if year<100
        year=2000+year;
    end
    season=versionString(end);
end


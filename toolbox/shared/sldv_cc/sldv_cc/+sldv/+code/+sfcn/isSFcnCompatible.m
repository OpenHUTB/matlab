function compatible=isSFcnCompatible(sfunctionName,minMajorVersion,minMinorVersion)





    narginchk(1,3);

    sfunctionName=convertStringsToChars(sfunctionName);

    if nargin<3
        minMinorVersion=[];
    end

    if nargin<2
        minMajorVersion=[];
    end

    try
        compatible=evalin('base',sprintf('%s(''isSldvCompatible'')',sfunctionName));
        if compatible&&~isempty(minMajorVersion)
            versionStr=evalin('base',sprintf('%s(''getSldvSupportVersionStr'')',sfunctionName));
            versionNumbers=str2double(strsplit(versionStr,'.'));
            if numel(versionNumbers)~=3||versionNumbers(1)<minMajorVersion
                compatible=false;
            elseif versionNumbers(1)==minMajorVersion
                if~isempty(minMinorVersion)
                    compatible=versionNumbers(2)>=minMinorVersion;
                end
            end
        end
    catch
        compatible=false;
    end

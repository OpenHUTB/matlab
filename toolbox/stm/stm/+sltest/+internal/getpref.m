function prefValues=getpref(group,pref)




    groupLabel='';
    if(nargin>=1)
        p=inputParser;
        p.addRequired('group',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
        p.parse(group);
        groupLabel=lower(group);
        groupAllowed={'testfiledisplay','testsuitedisplay','testcasedisplay','matlabreleases','showsimulationlogs'};
        groupLabel=validatestring(groupLabel,groupAllowed);
    end

    propertyArray=string([]);
    if(nargin==2)
        propertyArray=unique(string(pref));
    end

    if(isempty(groupLabel)||strcmpi(groupLabel,'MATLABReleases'))...
        &&slfeature('CrossReleaseManagerGUI')



        stm.internal.ReleaseMgrListener.updateReleaseInfo();
    end

    if(isempty(groupLabel))
        prefValues.TestFileDisplay=stm.internal.getGlobalPreference('testfiledisplay',{});
        prefValues.TestSuiteDisplay=stm.internal.getGlobalPreference('testsuitedisplay',{});
        prefValues.TestCaseDisplay=stm.internal.getGlobalPreference('testcasedisplay',{});
        prefValues.MATLABReleases=stm.internal.getGlobalPreference('release',{'releaselist'});
    else
        propertyArray=lower(cellstr(propertyArray));
        if(strcmpi(groupLabel,'MATLABReleases'))
            if(any(strcmp(propertyArray,'releaselist'))||isempty(propertyArray))
                prefValues=stm.internal.getGlobalPreference('release',{'releaselist'});
            else
                prefValues=[];
                for k=1:length(propertyArray)
                    tmpReleaseInfo=stm.internal.getRelease(propertyArray{k});
                    if(~isempty(tmpReleaseInfo))
                        if(isempty(prefValues))
                            prefValues=tmpReleaseInfo;
                        else
                            prefValues(end+1)=tmpReleaseInfo;
                        end
                    end
                end
            end
        else
            prefValues=stm.internal.getGlobalPreference(groupLabel,propertyArray);
        end
    end
end

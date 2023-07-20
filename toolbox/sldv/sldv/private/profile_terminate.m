function profile_terminate(testcomp,varargin)











    if slavteng('feature','Profiler')
        p=inputParser;
        addOptional(p,'goalIdToObjectiveIdMap',false);
        addOptional(p,'profileInfoVar','sldvProfileData');
        parse(p,varargin{:});

        if~ismember('goalIdToObjectiveIdMap',p.UsingDefaults)
            m=p.Results.goalIdToObjectiveIdMap;
            ks=keys(m);
            arr=[cell2mat(ks);cell2mat(values(m,ks))];
            testcomp.profileHalt(arr);
        else
            testcomp.profileHalt(0);
        end


        profileData=testcomp.profileInfo();
        if(slavteng('feature','ProfilerLegacy')&&slavteng('feature','ProfilerThreaded'))
            assignin('base',p.Results.profileInfoVar,profileData.legacy);
            assignin('base',[p.Results.profileInfoVar,'_threaded'],profileData.threaded);
        else
            assignin('base',p.Results.profileInfoVar,profileData);
        end

    else

        testcomp.profileHalt(0);
    end

end

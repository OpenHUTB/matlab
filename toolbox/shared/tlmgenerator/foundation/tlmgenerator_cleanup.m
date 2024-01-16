function tlmgenerator_cleanup

    try

        if isappdata(0,'tlmg_build');
            rmappdata(0,'tlmg_build');
        end

        if isappdata(0,'tlmgSubsystemPath');
            rmappdata(0,'tlmgSubsystemPath');
        end

        if isappdata(0,'tlmgSubsystemName');
            rmappdata(0,'tlmgSubsystemName');
        end

        if isappdata(0,'tlmgLaunchReportPrev');
            rmappdata(0,'tlmgLaunchReportPrev');
        end

        if isappdata(0,'tlmgME')
            rmappdata(0,'tlmgME');
        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG cleanup: %s',ME.message);
        throw(l_me);
    end

end


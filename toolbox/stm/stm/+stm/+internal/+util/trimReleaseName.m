function releaseName=trimReleaseName(releaseName)
    releaseName=strrep(releaseName,' ','');
    releaseName=strrep(releaseName,'(','');
    releaseName=strrep(releaseName,')','');
end


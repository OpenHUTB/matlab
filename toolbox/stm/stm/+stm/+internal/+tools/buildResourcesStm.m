function buildResourcesStm
    disp("Building matlab/resources/stm...");
    tmp=pwd;
    oc=onCleanup(@()cd(tmp));
    cd(fullfile(matlabroot,"resources","stm"));
!mw gmake prebuild
!mw gmake build -j8
    cd(fullfile(matlabroot,"toolbox","stm"));
!mw gmake prebuild
    disp("Done!");
end

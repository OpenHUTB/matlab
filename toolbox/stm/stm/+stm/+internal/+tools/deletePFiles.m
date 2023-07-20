function deletePFiles
    disp("Deleting P-files...");
    tmp=pwd;
    oc=onCleanup(@()cd(tmp));
    for folder=getFolders
        deleteFiles(folder);
    end
    disp(newline+"Rehashing...");
    rehash toolboxcache;
    rehash toolbox;
    clear classes;%#ok<CLCLS>
    disp(newline+"Done!");
end

function deleteFiles(folder)
    cd(folder);
    if ispc
!del /s *.p
    else
!find . -name "*.p" -type f -delete
    end
end

function folders=getFolders
    folders=[...
    fullfile(matlabroot,"toolbox","stm","stm","+stm"),...
    fullfile(matlabroot,"toolbox","stm","stm","+sltest"),...
    fullfile(matlabroot,"toolbox","stm","stm","+matlabshared","+mldatx","+internal","+run_in"),...
    fullfile(matlabroot,"toolbox","simulinktest","core","observer","observer","+Simulink","+observer"),...
    fullfile(matlabroot,"toolbox","simulinktest","simulinktest","+sltest","+internal","+menus"),...
    fullfile(matlabroot,"toolbox","simulinktest","core","observer","observer","+Simulink","+observer","+internal"),...
    ];
end

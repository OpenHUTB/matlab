

function oc=restoreLibraryLock(library)


    oc=onCleanup.empty;
    if isempty(sltest.harness.find(library,'OpenOnly','on'))
        prevLock=get_param(library,'Lock');
        set_param(library,'Lock','off');
        oc=onCleanup(@()set_param(library,'Lock',prevLock));
    end
end

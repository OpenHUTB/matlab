
function result=dontHaveSingleNonGuardPath(system)
    result=false;


    if~bdIsLibrary(bdroot)&&~strcmp(get_param(bdroot(system),'SFNoUnconditionalDefaultTransitionDiag'),'error')
        result=true;
    end
end
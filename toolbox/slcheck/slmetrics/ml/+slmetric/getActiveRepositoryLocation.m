



function loc=getActiveRepositoryLocation()
    arm=slmetric.internal.ActiveRepositoryManager();
    loc=arm.getActiveRepositoryLocation();
end
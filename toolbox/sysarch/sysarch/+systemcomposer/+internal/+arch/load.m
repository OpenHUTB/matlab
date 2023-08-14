function app=load(appName)









    narginchk(1,1);
    assert(isStringScalar(appName)||isa(appName,'char'),'Input argument must be a character array or String scalar');



    systemcomposer.internal.arch.feature('on');

    bdHandle=load_system(appName);


    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdHandle);
end

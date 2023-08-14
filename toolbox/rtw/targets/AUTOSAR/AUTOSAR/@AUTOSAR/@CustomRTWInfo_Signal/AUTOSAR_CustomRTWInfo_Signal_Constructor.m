function h=AUTOSAR_CustomRTWInfo_Signal_Constructor(h,varargin)















    hSuperPackage=findpackage('Simulink');
    hSuperClass=findclass(hSuperPackage,'CustomRTWInfo');
    if((~isempty(hSuperClass.methods))&&...
        (~isempty(find(hSuperClass.methods,'Name','Simulink_CustomRTWInfo_Constructor'))))
        h.Simulink_CustomRTWInfo_Constructor;
    end


    h.CustomStorageClassListener;



    narginchk(1,1);

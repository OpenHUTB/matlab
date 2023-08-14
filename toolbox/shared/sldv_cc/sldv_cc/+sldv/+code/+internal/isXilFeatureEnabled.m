



function out=isXilFeatureEnabled()

    persistent isRequiredProductInstalled;
    if isempty(isRequiredProductInstalled)
        isRequiredProductInstalled=license('test','RTW_Embedded_Coder')&&...
        license('test','Simulink_Design_Verifier')&&...
        exist('slavteng','builtin')==5;
    end

    out=isRequiredProductInstalled&&(slavteng('feature','GeneratedCodeTestGen')==1);

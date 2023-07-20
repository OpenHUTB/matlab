




















classdef Options
    properties
        EnablePolyspace{mustBeBooleanWithLicense(EnablePolyspace)}=false;
        EnableRobustness{mustBeBoolean(EnableRobustness)}=false;
        EnableUsePublishedOnly{mustBeBoolean(EnableUsePublishedOnly)}=false;
        ReportPath{mustBeDir(ReportPath)}=pwd;
        ModelSimTimeOut{mustBeInteger(ModelSimTimeOut)}=10;
    end

    methods
        function obj=Options()
            obj.ReportPath=pwd;
        end

    end
end
function mustBeDir(x)
    if~(exist(x,'dir')==7)
        error(DAStudio.message('Simulink:SFunctions:ComplianceCheckValidDirectory'));
    end
end
function mustBeBoolean(x)
    if~(isequal(x,true)||isequal(x,false))
        error(DAStudio.message('Simulink:SFunctions:ComplianceCheckValidBoolean'));
    end
end
function mustBeBooleanWithLicense(x)
    if~(isequal(x,true)||isequal(x,false))
        error(DAStudio.message('Simulink:SFunctions:ComplianceCheckValidBoolean'));
    end
    if~(exist('polyspace.Options','class')==8)&&isequal(x,true)
        error(DAStudio.message('Simulink:SFunctions:ComplianceCheckPolyspaceLicenseFail'));
    end
end

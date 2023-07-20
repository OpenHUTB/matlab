function out=useSignalColorForBaseline(varargin)









    persistent baselineColor;
    currentBaselineColor=Simulink.sdi.getComparisonColor('baselineColor');
    if nargin==0
        out=isempty(currentBaselineColor);
    else
        if~isempty(currentBaselineColor)
            baselineColor=currentBaselineColor;
        elseif isempty(baselineColor)

            baselineColor=[0/255,114/255,189/255];
        end
        boolValue=varargin{1};
        if boolValue
            out=true;

            Simulink.sdi.setComparisonColor('baselineColor',[-1.0,-1.0,-1.0]);
        else
            out=false;
            Simulink.sdi.setComparisonColor('baselineColor',baselineColor);
        end
    end
end
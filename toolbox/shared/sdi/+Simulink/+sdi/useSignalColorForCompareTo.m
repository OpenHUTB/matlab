function out=useSignalColorForCompareTo(varargin)









    persistent compareToColor;
    currentCompareToColor=Simulink.sdi.getComparisonColor('compareToColor');
    if nargin==0
        out=isempty(currentCompareToColor);
    else
        if~isempty(currentCompareToColor)
            compareToColor=currentCompareToColor;
        elseif isempty(compareToColor)

            compareToColor=[217/255,83/255,25/255];
        end
        boolValue=varargin{1};
        if boolValue
            out=true;

            Simulink.sdi.setComparisonColor('compareToColor',[-1.0,-1.0,-1.0]);
        else
            out=false;
            Simulink.sdi.setComparisonColor('compareToColor',compareToColor);
        end
    end
end
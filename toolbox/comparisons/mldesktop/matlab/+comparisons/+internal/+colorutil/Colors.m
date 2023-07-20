classdef Colors<handle





    methods(Static)
        function color=richLeftColor()
            import comparisons.internal.colorutil.Colors
            color=getRichColor(Colors.leftColor());
        end

        function color=richRightColor()
            import comparisons.internal.colorutil.Colors
            color=getRichColor(Colors.rightColor());
        end

        function color=richModifiedColor()
            import comparisons.internal.colorutil.Colors
            color=getRichColor(Colors.modifiedColor());
        end

        function color=leftColor()
            color=getColor("LeftDifferenceColor");
        end

        function color=rightColor()
            color=getColor("RightDifferenceColor");
        end

        function color=modifiedColor()
            color=getColor("ModifiedLineColor");
        end

    end
end


function richColor=getRichColor(color)
    richColor=getAlphaUnscaledColor(color,0.2);
end

function newColor=getAlphaUnscaledColor(color,alpha)
    newColor=arrayfun(@(x)round(max((x-255*(1-alpha))/alpha,0)),color);
end

function color=getColor(name)
    s=settings;
    profileID=s.comparisons.colors.currentProfile.lastChosen.ActiveValue;
    try





        colorProfile=s.comparisons.colors.(profileID).current;
        color=colorProfile.(name).ActiveValue;
        color=int32(color);
        if comparisons.internal.colorutil.isValidRGB(color)
            return
        end
    catch
    end


    colorProfile=s.comparisons.colors.("DefaultProfileID").current;
    color=colorProfile.(name).ActiveValue;
end
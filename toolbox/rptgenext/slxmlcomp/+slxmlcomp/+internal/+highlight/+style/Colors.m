classdef Colors<handle





    methods(Static)
        function color=richLeftColor()
            import slxmlcomp.internal.highlight.style.Colors
            color=getRichColor(Colors.leftColor());
        end

        function color=richRightColor()
            import slxmlcomp.internal.highlight.style.Colors
            color=getRichColor(Colors.rightColor());
        end

        function color=richModifiedColor()
            import slxmlcomp.internal.highlight.style.Colors
            color=getRichColor(Colors.modifiedLineColor());
        end

        function color=leftColor()
            color=getColor("LeftDifferenceColor");
        end

        function color=rightColor()
            color=getColor("RightDifferenceColor");
        end

        function color=modifiedLineColor()
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
    com.mathworks.comparisons.util.SerializingColorManager.ensureDefaultColorProfileIsInitialized();
    waitForColorSettingInitialization();
    s=settings;
    profileID=s.comparisons.colors.currentProfile.lastChosen.ActiveValue;
    try





        colorProfile=s.comparisons.colors.(profileID).current;
    catch
        colorProfile=s.comparisons.colors.("DefaultProfileID").current;
    end

    color=colorProfile.(name).ActiveValue;
end

function waitForColorSettingInitialization()


    s=settings;
    compGroup=s.comparisons;
    while(~compGroup.hasGroup('colors'))
        pause(0.1);
    end
end

function actualValue=setParentImpl(hObj,proposedValue)



    hAx=hObj.Axes;
    isLayout=isa(proposedValue,'matlab.graphics.layout.Layout');
    isALM=isa(proposedValue,'matlab.graphics.shape.internal.AxesLayoutManager');

    if isempty(hAx)||isempty(hAx.Parent)...
        ||(strcmp(hObj.ParentMode,'auto')&&(isLayout||isALM))...
        ||isempty(proposedValue)










        actualValue=hObj.setParentImpl@matlab.graphics.mixin.UIParentable(proposedValue);

    elseif strcmp(hObj.ParentMode,'manual')&&...
        ~(isequal(proposedValue,hAx.Parent)||isprop(hAx,'LayoutManager')&&proposedValue==hAx.LayoutManager)





        hObj.ParentMode='auto';
        throwAsCaller(MException(message('MATLAB:colorbar:ParentMustBeSameAsAxes')));
    else





        hObj.ParentMode='auto';
        legendcolorbarlayout(hAx,'addToTree',hObj)

        if isa(hAx.Parent,'matlab.graphics.layout.Layout')
            actualValue=hAx.Parent;
        else
            actualValue=hAx.LayoutManager;
        end
    end
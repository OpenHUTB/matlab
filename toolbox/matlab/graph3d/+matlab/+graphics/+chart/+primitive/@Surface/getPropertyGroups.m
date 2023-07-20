function varargout=getPropertyGroups(~)



    varargout{1}=matlab.mixin.util.PropertyGroup(...
    {'EdgeColor','LineStyle','FaceColor','FaceLighting',...
    'FaceAlpha','XData','YData','ZData','CData'});
end
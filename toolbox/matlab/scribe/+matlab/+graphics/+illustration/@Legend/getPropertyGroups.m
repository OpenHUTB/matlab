function varargout=getPropertyGroups(~)



    varargout{1}=matlab.mixin.util.PropertyGroup(...
    {'String','Location','Orientation','FontSize','Position','Units'});
end
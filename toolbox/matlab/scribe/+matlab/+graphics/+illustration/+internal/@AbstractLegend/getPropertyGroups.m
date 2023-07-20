function varargout=getPropertyGroups(~)



    varargout{1}=matlab.mixin.util.PropertyGroup(...
    {'String','Location','Style','FontSize','Position','Units'});
end
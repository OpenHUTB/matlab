function varargout=getPropertyGroups(~)



    varargout{1}=matlab.mixin.util.PropertyGroup(...
    {'Location','Limits','FontSize','Position','Units'});
end
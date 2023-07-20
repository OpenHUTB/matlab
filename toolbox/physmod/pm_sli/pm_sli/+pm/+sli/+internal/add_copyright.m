function h=add_copyright(sys,startYear)






    h=Simulink.Annotation(sprintf('%s/%s',...
    getfullname(sys),...
    pmsl_copyright(startYear)),...
    'Tag','ModelCopyright');

end

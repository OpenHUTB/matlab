function result=isComponentCharacteristicViewerSupported(componentPath)







    result=any(strcmp(componentPath,...
    {'ee.semiconductors.sp_nmos'...
    ,'ee.semiconductors.sp_pmos'}));
end

function lib(libInfo)

    libName=pm_message('sm:library:bodyElements:flexibleBodies:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=sprintf('%s',[libName,' Library']);
    libInfo.DVGIconKey='SMLibrary.flexible_bodies_lib';


    libInfo.OrderofChildren={...
    'reduced_order_flexible_solid',...
    'beams',...
    'plates_shells'};




classdef ComponentConfigLayout<configset.layout.MetaConfigLayout

    methods(Static,Hidden)
        function obj=getInstance(varargin)

            obj=[];
        end



        function componentLayout=buildComponentXml(configLayout,className,componentPath,savePath)
            configLayout.MetaCS.loadComponent(className,componentPath);
            componentLayout=configset.layout.ComponentConfigLayout(className,componentPath);
            componentMatFile=configset.layout.MetaConfigLayout.getMatFile(className,savePath);
            save(componentMatFile,'componentLayout');
            configLayout.addComponentParameters(componentLayout);
        end



        function component=qeBuildComponentXml(configLayout,xmlFile)



            if~startsWith(xmlFile,matlabroot)
                xmlFile=which(xmlFile);
            end
            component=configset.layout.MetaConfigLayout(xmlFile);
            configLayout.addComponentParameters(component);
        end

    end

    methods(Access=?configset.layout.MetaConfigLayout)
        function obj=ComponentConfigLayout(className,componentPath)
            obj@configset.layout.MetaConfigLayout(configset.layout.MetaConfigLayout.getXmlFile(className,componentPath));
        end
    end
end





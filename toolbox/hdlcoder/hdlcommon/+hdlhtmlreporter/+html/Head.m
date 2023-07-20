


classdef Head<hdlhtmlreporter.html.GenericSection
    properties
        title='';
        styles={};
        scripts={};
    end

    methods
        function obj=Head(title,styles,scripts)
            obj=obj@hdlhtmlreporter.html.GenericSection('head','',{});
            obj.title=title;
            obj.styles=styles;
            obj.scripts=scripts;


            obj.buildingTags('head')=true;
            obj.buildingTags('title')=true;
            obj.buildingTags('style')=true;
            obj.buildingTags('link')=true;
            obj.buildingTags('script')=true;
        end
        function commitHead(obj)
            obj.setTitleEmission;
            obj.setStylesEmission;
        end

        function setTitleEmission(obj)
            if~isempty(obj.title)
                obj.addContentStr(sprintf('<title>%s</title>\n',obj.title));
            end
        end

        function setStylesEmission(obj)
            obj.addContentStr(sprintf('<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>\n'));


            if~isempty(obj.styles)

                if~isempty(obj.styles.external)
                    for ii=1:length(obj.styles.external)
                        externalCssStyle=obj.styles.external{ii};
                        obj.addContentStr(externalCssStyle.emitCss);
                    end
                end




                obj.addContentStr(sprintf('<style type="text/css">\n'));

                if~isempty(obj.styles.global)
                    for ii=1:length(obj.styles.global)
                        globalCssStyle=obj.styles.global{ii};
                        obj.addContentStr(globalCssStyle.emitCss);
                    end
                end


                if~isempty(obj.styles.group)
                    for ii=1:length(obj.styles.group)
                        groupCssStyle=obj.styles.group{ii};
                        obj.addContentStr(groupCssStyle.emitCss);
                    end
                end


                if~isempty(obj.styles.local)
                    for ii=1:length(obj.styles.local)
                        localCssStyle=obj.styles.local{ii};
                        obj.addContentStr(localCssStyle.emitCss);
                    end
                end
                obj.addContentStr(sprintf('</style>\n\n'));
            end
        end
    end
end
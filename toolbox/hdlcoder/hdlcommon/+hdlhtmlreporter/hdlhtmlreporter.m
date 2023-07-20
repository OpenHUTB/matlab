


classdef hdlhtmlreporter<hdlhtmlreporter.html.EmissionContainer
    properties
reportFile
reportTitle
externalCssStyles
globalCssStyles
    end
    methods
        function obj=hdlhtmlreporter(reportFile,reportTitle,externalCssStyles,globalCssStyles)
            if nargin<4
                globalCssStyles={};
            end

            if nargin<3
                externalCssStyles={};
            end


            bodySection=hdlhtmlreporter.html.GenericSection('body','',{});
            obj@hdlhtmlreporter.html.EmissionContainer(bodySection);


            obj.reportFile=reportFile;
            obj.reportTitle=reportTitle;
            obj.globalCssStyles=globalCssStyles;
            obj.externalCssStyles=externalCssStyles;


        end
        function commitSection(obj)
            if obj.countPendingSection~=1
                commitSection@hdlhtmlreporter.html.EmissionContainer(obj);
            end
        end

        function emitStr=emitHTML(obj)

            allCssStyles=obj.packCssStyles;
            headSection=hdlhtmlreporter.html.Head(obj.reportTitle,allCssStyles,{});
            headSection.commitHead;
            headStr=headSection.emitHTML;


            bodyStr=emitHTML@hdlhtmlreporter.html.EmissionContainer(obj);

            emitStr=[sprintf('<html>\n'),headStr,bodyStr,sprintf('</html>')];
        end

        function dumpHTML(obj)
            fid=fopen(obj.reportFile,'w','n','utf8');
            if fid==-1
                error(message('hdlcoder:engine:cannotopenfile',obj.reportFile));
            end
            fwrite(fid,obj.emitHTML,'char');
            fclose(fid);
        end

        function cssStyles=packCssStyles(obj)
            cssStyles.external=obj.externalCssStyles;
            cssStyles.global=obj.globalCssStyles;
            cssStyles.group=obj.groupCssStyles;
            cssStyles.local=obj.activeSection.localCssStyles;
        end
    end
end


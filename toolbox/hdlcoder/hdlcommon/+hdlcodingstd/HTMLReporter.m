


classdef HTMLReporter<handle



    methods(Static,Access=public)
        function paths=get_resource_locations()
            unix_style=@(x)strrep(x,'\','/');
            escape_space=@(x)strrep(x,' ','%20');

            paths=struct();

            paths.JS_CSS_PATH=escape_space(unix_style(fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','js_css',filesep)));
            paths.ML_HELP_PATH=escape_space(unix_style(fullfile(matlabroot,'help','matlab')));
            paths.DOCPATH=escape_space(unix_style(fullfile(matlabroot)));
            paths.HDL_CODER_PATH=escape_space(unix_style(fullfile(matlabroot,'toolbox','hdlcoder')));
            paths.ICON_PATH=escape_space(unix_style(fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','icons',filesep)));

            paths.JS_CSS_PATH_AA=unix_style(fullfile(paths.JS_CSS_PATH,'jquery-1.7.1.js'));
            paths.ML_HELP_PATH_AA=unix_style(fullfile(paths.JS_CSS_PATH,'docscripts.js'));

            paths.JS_CSS_PATH_B=unix_style(fullfile(paths.JS_CSS_PATH,'ice_960.css'));
            paths.JS_CSS_PATH_C=unix_style(fullfile(paths.JS_CSS_PATH,'HDLsite5.css'));
            paths.JS_CSS_PATH_D=unix_style(fullfile(paths.JS_CSS_PATH,'ice_doc_center.css'));
            paths.JS_CSS_PATH_E=unix_style(fullfile(paths.JS_CSS_PATH,'ice_doc_center_installed.css'));
            paths.JS_CSS_PATH_F=unix_style(fullfile(paths.JS_CSS_PATH,'ice_doc_center_print.css'));
            paths.JS_CSS_PATH_G=unix_style(fullfile(paths.JS_CSS_PATH,'960.css'));

            paths.MLROOT=escape_space(unix_style(fullfile(matlabroot())));
            paths.DOCROOT=escape_space(unix_style(fullfile(docroot())));
            paths.DOCPATH_B=unix_style(fullfile(paths.MLROOT,'trademarks.txt'));
            paths.DOCPATH_C=unix_style(fullfile(paths.MLROOT,'patents.txt'));
            paths.DOCPATH_D=unix_style(matlab.internal.licenseAgreement);
            paths.JS_CSS_PATH_ACK=unix_style(fullfile(docroot,'acknowledgments.html'));
            return;
        end



        function writeBasicHTMLheader(fid,nname)
            fprintf(fid,'<!DOCTYPE HTML>\n');
            fprintf(fid,'<html xmlns="http://www.w3.org/1999/xhtml">\n');
            fprintf(fid,'<head>\n');
            fprintf(fid,['<title>',message('hdlcommon:IndustryStandard:HTMLtitle').getString,' %s</title>\n'],nname);
            fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
            fprintf(fid,'</head>\n');
            fprintf(fid,'<body bgcolor="#FFFFF0" text="#172457">\n');
            fprintf(fid,'<font face="Arial, Helvetica, sans-serif"> \n');
            fprintf(fid,'<h2><font face="Arial, Helvetica, sans-serif" color="#990000">');
            fprintf(fid,[message('hdlcommon:IndustryStandard:reportTitleFor').getString,char(10)]);
            fprintf(fid,'<a href="matlab:open_system(''%s'');">%s</a><BR>\n',...
            nname,nname);
            fprintf(fid,[message('hdlcommon:IndustryStandard:generatedOn').getString,' %s</font></h2>\n'],datestr(now,31));
        end



        function writeJQueryHTMLheader(fid,nname)
            paths=hdlcodingstd.HTMLReporter.get_resource_locations();

            JS_CSS_PATH=paths.JS_CSS_PATH;
            ML_HELP_PATH=paths.ML_HELP_PATH;
            DOCPATH=paths.DOCPATH;
            HDL_CODER_PATH=paths.HDL_CODER_PATH;
            ICON_PATH=paths.ICON_PATH;

            fprintf(fid,'<!DOCTYPE HTML>\n');
            fprintf(fid,'<html xmlns="http://www.w3.org/1999/xhtml" itemscope itemtype="https://www.mathworks.com/help/schema/MathWorksDocPage">\n');
            fprintf(fid,'<head>\n');
            fprintf(fid,['<title>',message('hdlcommon:IndustryStandard:HTMLtitle').getString,' %s</title>\n'],nname);
            fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');


            fprintf(fid,'\n');

            JS_CSS_PATH_AA=paths.JS_CSS_PATH_AA;
            ML_HELP_PATH_AA=paths.ML_HELP_PATH_AA;
            fprintf(fid,'<script type="text/javascript" src="file://%s"></script>\n<script type="text/javascript" src="file://%s"></script>\n',JS_CSS_PATH_AA,ML_HELP_PATH_AA);

            fprintf(fid,'        \n');
            fprintf(fid,'        \n');
            fprintf(fid,'        \n');

            JS_CSS_PATH_B=paths.JS_CSS_PATH_B;
            JS_CSS_PATH_C=paths.JS_CSS_PATH_C;
            JS_CSS_PATH_D=paths.JS_CSS_PATH_D;
            JS_CSS_PATH_E=paths.JS_CSS_PATH_E;
            JS_CSS_PATH_F=paths.JS_CSS_PATH_F;
            JS_CSS_PATH_G=paths.JS_CSS_PATH_G;

            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_G);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_B);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_C);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_D);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_E);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css" media="print">\n',JS_CSS_PATH_F);

            fprintf(fid,'        <script type="text/javascript">\n');
            fprintf(fid,'            if (navigator.appName != "ICEbrowser") {\n');
            fprintf(fid,'            var cssStyleSheets = $("link").filter(function(){\n');
            fprintf(fid,'            var href = $(this).attr(''href'');\n');
            fprintf(fid,'            return href.indexOf("ice_doc_center_print.css") == -1});\n');
            fprintf(fid,'            var hrefElements = $.map(cssStyleSheets, function(elem) {\n');
            fprintf(fid,'            var href = $(elem).attr(''href'');\n');
            fprintf(fid,'            var hrefArray = href.split("/");\n');
            fprintf(fid,'            hrefArray[hrefArray.length - 1] = hrefArray[hrefArray.length - 1].replace("ice_", "");\n');
            fprintf(fid,'            return {\n');
            fprintf(fid,'            href: hrefArray.join("/"),\n');
            fprintf(fid,'            media: $(elem).attr(''media'')\n');
            fprintf(fid,'            };\n');
            fprintf(fid,'            });\n');
            fprintf(fid,'            cssStyleSheets.remove();\n');
            fprintf(fid,'            for (var i = 0; i < hrefElements.length; i++) {\n');
            fprintf(fid,'            if ($.browser.msie && $.browser.version <= 8) {\n');
            fprintf(fid,'            document.createStyleSheet(hrefElements[i].href);\n');
            fprintf(fid,'            } else {\n');
            fprintf(fid,'            var link = $(''<link rel="stylesheet" href='' + hrefElements[i].href + '' type="text/css" />'');\n');
            fprintf(fid,'            if (hrefElements[i].media) {\n');
            fprintf(fid,'            link.attr(''media'', hrefElements[i].media);\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            $(''head'').append(link);\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'    </script>\n');
            fprintf(fid,'</head>\n');

            fprintf(fid,'<body>\n');
            fprintf(fid,'<div class="container_192">\n<div class="grid_192">\n');
            fprintf(fid,' <div class="page_container"><div class="content_frame">\n');
        end


        function writeJQueryHTMLcloser(fid)
            paths=hdlcodingstd.HTMLReporter.get_resource_locations();

            JS_CSS_PATH=paths.JS_CSS_PATH;
            MLROOT=paths.MLROOT;

            DOCPATH_B=paths.DOCPATH_B;
            DOCPATH_C=paths.DOCPATH_C;
            DOCPATH_D=paths.DOCPATH_D;

            fprintf(fid,' </div></div></div></div>\n');

            fprintf(fid,'                    <div class="grid_192">\n');
            fprintf(fid,'                        <div class="footer_container">\n');
            fprintf(fid,'                            <div class="footer">\n');
            fprintf(fid,'                                <ul class="footernav">\n');

            JS_CSS_PATH_ACK=paths.JS_CSS_PATH_ACK;

            fprintf(fid,'                                    <li class="footernav_trademarks"><a href="%s">Acknowledgments</a></li>\n',JS_CSS_PATH_ACK);
            fprintf(fid,'                                    <li class="footernav_trademarks"><a href="%s">Trademarks</a></li>\n',DOCPATH_B);
            fprintf(fid,'                                    <li class="footernav_patents"><a href="%s">Patents</a></li>\n',DOCPATH_C);
            fprintf(fid,'                                    <li class="footernav_help"><a href="%s">Terms of Use</a></li>\n',DOCPATH_D);
            fprintf(fid,'                                </ul>\n');

            year=date;year=year(end-3:end);

            fprintf(fid,'                                <div class="copyright">&copy; 1994-%s The MathWorks, Inc.</div>\n',year);
            fprintf(fid,'                            </div>\n');
            fprintf(fid,'                        </div>\n');
            fprintf(fid,'                    </div>\n');
            fprintf(fid,'\n');


            fprintf(fid,'        <script type="text/javascript">\n');
            fprintf(fid,'\n');
            fprintf(fid,'$(document).ready( setTimeout( function () {\n');
            fprintf(fid,'                   $(".expandAllLink").trigger(''click'');\n');
            fprintf(fid,'            }, 50 ) );\n');
            fprintf(fid,'\n');

            fprintf(fid,'        </script>\n');
            fprintf(fid,'        \n');

            fprintf(fid,'</body>\n');
            fprintf(fid,'</html>\n');
        end
    end












    methods(Access=public)

        function createHeader(this,fid,fcnName,reportTitle)%#ok<INUSL>





            paths=hdlcodingstd.HTMLReporter.get_resource_locations();
            JS_CSS_PATH=paths.JS_CSS_PATH;
            ML_HELP_PATH=paths.ML_HELP_PATH;
            DOCPATH=paths.DOCPATH;
            HDL_CODER_PATH=paths.HDL_CODER_PATH;
            ICON_PATH=paths.ICON_PATH;

            fprintf(fid,'<!DOCTYPE HTML>\n');
            fprintf(fid,'<html xmlns="http://www.w3.org/1999/xhtml" itemscope itemtype="https://www.mathworks.com/help/schema/MathWorksDocPage">\n');
            fprintf(fid,'<head>\n');

            fprintf(fid,'<title>%s</title>\n',reportTitle);
            fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');


            fprintf(fid,'\n');

            JS_CSS_PATH_AA=paths.JS_CSS_PATH_AA;
            ML_HELP_PATH_AA=paths.ML_HELP_PATH_AA;

            fprintf(fid,'<script type="text/javascript" src="file://%s"></script>\n<script type="text/javascript" src="file://%s"></script>\n',JS_CSS_PATH_AA,ML_HELP_PATH_AA);
            fprintf(fid,'        \n');

            JS_CSS_PATH_B=paths.JS_CSS_PATH_B;
            JS_CSS_PATH_C=paths.JS_CSS_PATH_C;
            JS_CSS_PATH_D=paths.JS_CSS_PATH_D;
            JS_CSS_PATH_E=paths.JS_CSS_PATH_E;
            JS_CSS_PATH_F=paths.JS_CSS_PATH_F;

            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_B);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_C);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_D);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css">\n',JS_CSS_PATH_E);
            fprintf(fid,'        <link href="file://%s" rel="stylesheet" type="text/css" media="print">\n',JS_CSS_PATH_F);

            fprintf(fid,'        <script type="text/javascript">\n');
            fprintf(fid,'            if (navigator.appName != "ICEbrowser") {\n');
            fprintf(fid,'            var cssStyleSheets = $("link").filter(function(){\n');
            fprintf(fid,'            var href = $(this).attr(''href'');\n');
            fprintf(fid,'            return href.indexOf("ice_doc_center_print.css") == -1});\n');
            fprintf(fid,'            var hrefElements = $.map(cssStyleSheets, function(elem) {\n');
            fprintf(fid,'            var href = $(elem).attr(''href'');\n');
            fprintf(fid,'            var hrefArray = href.split("/");\n');
            fprintf(fid,'            hrefArray[hrefArray.length - 1] = hrefArray[hrefArray.length - 1].replace("ice_", "");\n');
            fprintf(fid,'            return {\n');
            fprintf(fid,'            href: hrefArray.join("/"),\n');
            fprintf(fid,'            media: $(elem).attr(''media'')\n');
            fprintf(fid,'            };\n');
            fprintf(fid,'            });\n');
            fprintf(fid,'            cssStyleSheets.remove();\n');
            fprintf(fid,'            for (var i = 0; i < hrefElements.length; i++) {\n');
            fprintf(fid,'            if ($.browser.msie && $.browser.version <= 8) {\n');
            fprintf(fid,'            document.createStyleSheet(hrefElements[i].href);\n');
            fprintf(fid,'            } else {\n');
            fprintf(fid,'            var link = $(''<link rel="stylesheet" href='' + hrefElements[i].href + '' type="text/css" />'');\n');
            fprintf(fid,'            if (hrefElements[i].media) {\n');
            fprintf(fid,'            link.attr(''media'', hrefElements[i].media);\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            $(''head'').append(link);\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'            }\n');
            fprintf(fid,'    </script>\n');
            fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
            fprintf(fid,'</head>\n');
        end

        function beginBody(this,fid,bodyHeading)%#ok<INUSL,*MANU>




            fprintf(fid,'<body>\n');
            fprintf(fid,'<div class="container_192">\n<div class="grid_192">\n');
            fprintf(fid,' <div class="page_container"><div class="content_frame">\n');
            fprintf(fid,' <BR/> <BR/>');
            fprintf(fid,'<DIV ><H1>%s</H1>\n',bodyHeading);
            fprintf(fid,'<BR>');
            fprintf(fid,'<H2>Generated on %s</h2></DIV>\n',datestr(now,31));
        end

        function endBody(this,fid)%#ok<INUSL>



            fprintf(fid,'<BR>');
            fprintf(fid,'<BR>');


            hdlcodingstd.HTMLReporter.writeJQueryHTMLcloser(fid);
        end

    end
end

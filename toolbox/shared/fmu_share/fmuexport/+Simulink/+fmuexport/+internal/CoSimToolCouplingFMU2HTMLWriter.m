

classdef CoSimToolCouplingFMU2HTMLWriter<Simulink.fmuexport.internal.CodeWriter
    properties(Access=private)
ModelInfoUtils

    end


    methods(Access=public)
        function this=CoSimToolCouplingFMU2HTMLWriter(modelInfoUtils,fileName)

            this=this@Simulink.fmuexport.internal.CodeWriter(fileName);
            this.ModelInfoUtils=modelInfoUtils;

        end
    end



    methods(Access=public)
        function info=write_info(this,param_tag,value)

            before_tag='                <div><info_param>';
            tag=DAStudio.message(['FMUBlock:FMU:',param_tag,'']);
            after_tag_before_value='</info_param><info_value>';
            after_value='</info_value></div>';
            if(isempty(value));value='-';end
            info=[before_tag,tag,after_tag_before_value,value,after_value];
        end

        function write(this)

            content={
            '<!DOCTYPE html><html><head>';
            '<meta charset="utf-8"></meta>';
            '<meta name="viewport" content="width=device-width, initial-scale=1.0"></meta> <!-- fits the page to the device screen -->';
            ['<title>',DAStudio.message('FMUBlock:FMU:HelpPageTitle'),'</title>'];
            };
            content=[content;
            '<link href="css/bootstrap.min.css " rel="stylesheet" type="text/css"></link>';
            '<link href="css/site6.css?201507 " rel="stylesheet" type="text/css"></link>';
            '<link href="css/doc_center.css?20150306 " rel="stylesheet" type="text/css"></link>';
            '<style>';
            '.content_container { padding-top: 20px; min-height: 20px; }';
            '#doc_center_content { min-height: 20px; }';
            'info_param { width: 200px; display: block; vertical-align: middle; float:left; clear:left; }';
            'info_value { outline: none; }';
            '</style>';
            '</head><body>';
            '<div class="content_container" id="content_container">';
            '  <div class="container-fluid">';
            '    <div class="row">';
            '      <div class="col-xs-12">';
            '        <section id="doc_center_content">';
            '          <!-- START CONTENT HERE -->';
            '          <div id="pgtype-topic">';
            '            <div itemprop="content">';
            '              <form>';
            this.write_info('HelpPageFMUInfoFMUModelName',this.ModelInfoUtils.ModelIdentifier);
            this.write_info('HelpPageFMUInfoFMIVersion','2.0');
            this.write_info('HelpPageFMUInfoFMUType','Co-Simulation');
            this.write_info('HelpPageFMUInfoBinaries',this.ModelInfoUtils.ModelIdentifier);
            this.write_info('HelpPageFMUInfoDescription',this.ModelInfoUtils.Description);
            this.write_info('HelpPageFMUInfoAuthor',this.ModelInfoUtils.Author);
            this.write_info('HelpPageFMUInfoGenerationDateAndTime',this.ModelInfoUtils.GenerationDateAndTime);
            '              </form>';
            '              <br/>';
            ];
            content=[content;
            ['              <div><p><a href="../modelDescription.xml" target="_blank">',DAStudio.message('FMUBlock:FMU:HelpPageFMUInfoModelDescriptionXMLFileLink'),'</a></p></div>'];
            '            </div>';
            '          </div>';
            '        </section>';
            '      </div>';
            '    </div>';
            '  </div>';
            '</div>';
            '</body></html>';
            ];

            for i=1:length(content)
                this.writeString(content{i});
            end
        end
    end
end

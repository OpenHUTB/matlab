classdef ComponentConverterFactory<handle
















    properties(Access=private,Hidden)
        Converters=[];
    end

    methods

        function this=ComponentConverterFactory()



        end

        function converter=getConverter(this,component,rptFileConverter)





            if isempty(this.Converters)
                this.Converters=getConverterDictionary(this);
            end

            key=class(component);
            if this.Converters.isKey(key)
                converterClass=this.Converters(key);
            else
                converterClass=this.Converters('NullConverter');
            end


            converter=feval(converterClass,component,rptFileConverter);
        end
    end

    methods(Access=protected)
        function converterDictionary=getConverterDictionary(~)




            converterDictionary=dictionary;
            converterDictionary('rpt_xml.db_output')='mlreportgen.rpt2api.SkipConverter';
            converterDictionary('NullConverter')='mlreportgen.rpt2api.NullConverter';
            converterDictionary('RptgenML.CReport')='mlreportgen.rpt2api.RptgenML_CReport';
            converterDictionary('rptgen.cfr_paragraph')='mlreportgen.rpt2api.rptgen_cfr_paragraph';
            converterDictionary('rptgen.cfr_section')='mlreportgen.rpt2api.rptgen_cfr_section';
            converterDictionary('rptgen.cfr_table')='mlreportgen.rpt2api.rptgen_cfr_table';
            converterDictionary('rptgen.cfr_text')='mlreportgen.rpt2api.rptgen_cfr_text';
            converterDictionary('rptgen.cfr_titlepage')='mlreportgen.rpt2api.rptgen_cfr_titlepage';
            converterDictionary('rptgen.cml_eval')='mlreportgen.rpt2api.rptgen_cml_eval';
            converterDictionary('rptgen_lo.clo_for')='mlreportgen.rpt2api.rptgen_lo_clo_for';
            converterDictionary('rptgen_lo.clo_while')='mlreportgen.rpt2api.rptgen_lo_clo_while';
            converterDictionary('rptgen_lo.clo_if')='mlreportgen.rpt2api.rptgen_lo_clo_if';
            converterDictionary('rptgen_lo.clo_then')='mlreportgen.rpt2api.rptgen_lo_clo_then';
            converterDictionary('rptgen_lo.clo_else')='mlreportgen.rpt2api.rptgen_lo_clo_else';
            converterDictionary('rptgen_lo.clo_else_if')='mlreportgen.rpt2api.rptgen_lo_clo_else_if';
            converterDictionary('rptgen.cfr_page_break')='mlreportgen.rpt2api.rptgen_cfr_page_break';
            converterDictionary('rptgen.cfr_line_break')='mlreportgen.rpt2api.rptgen_cfr_line_break';
            converterDictionary('rptgen.cfr_link')='mlreportgen.rpt2api.rptgen_cfr_link';
            converterDictionary('rptgen.cfr_list')='mlreportgen.rpt2api.rptgen_cfr_list';
            converterDictionary('rptgen_hg.chg_fig_loop')='mlreportgen.rpt2api.rptgen_hg_chg_fig_loop';
            converterDictionary('rptgen.cfr_preformatted')='mlreportgen.rpt2api.rptgen_cfr_preformatted';
            converterDictionary('rptgen_hg.chg_fig_snap')='mlreportgen.rpt2api.rptgen_hg_chg_fig_snap';
            converterDictionary('rptgen_hg.chg_ax_loop')='mlreportgen.rpt2api.rptgen_hg_chg_ax_loop';
            converterDictionary('rptgen_hg.chg_ax_snap')='mlreportgen.rpt2api.rptgen_hg_chg_ax_snap';
            converterDictionary('rptgen.cfr_ext_table')='mlreportgen.rpt2api.rptgen_cfr_ext_table';
            converterDictionary('rptgen.cfr_ext_table_colspec')='mlreportgen.rpt2api.SkipConverter';
            converterDictionary('rptgen.cfr_ext_table_body')='mlreportgen.rpt2api.rptgen_cfr_ext_table_body';
            converterDictionary('rptgen.cfr_ext_table_head')='mlreportgen.rpt2api.rptgen_cfr_ext_table_head';
            converterDictionary('rptgen.cfr_ext_table_foot')='mlreportgen.rpt2api.rptgen_cfr_ext_table_foot';
            converterDictionary('rptgen.cfr_ext_table_row')='mlreportgen.rpt2api.rptgen_cfr_ext_table_row';
            converterDictionary('rptgen.cfr_ext_table_entry')='mlreportgen.rpt2api.rptgen_cfr_ext_table_entry';
            converterDictionary('rptgen.cfr_image')='mlreportgen.rpt2api.rptgen_cfr_image';
            converterDictionary('rptgen.cfr_code')='mlreportgen.rpt2api.rptgen_cfr_code';
            converterDictionary('rptgen.cml_whos')='mlreportgen.rpt2api.rptgen_cml_whos';
            converterDictionary('rptgen.cml_variable')='mlreportgen.rpt2api.rptgen_cml_variable';
            converterDictionary('rptgen.cml_prop_table')='mlreportgen.rpt2api.rptgen_cml_prop_table';


            converterDictionary('RptgenML.CForm')='mlreportgen.rpt2api.RptgenML_CForm';
            converterDictionary('rptgen.cform_template_hole')='mlreportgen.rpt2api.rptgen_cform_template_hole';
            converterDictionary('rptgen.cform_subform')='mlreportgen.rpt2api.rptgen_cform_subform';
            converterDictionary('rptgen.cform_docx_page_layout')='mlreportgen.rpt2api.rptgen_cform_docx_page_layout';
            converterDictionary('rptgen.cform_pdf_page_layout')='mlreportgen.rpt2api.rptgen_cform_pdf_page_layout';
            converterDictionary('rptgen.cform_page_header')='mlreportgen.rpt2api.rptgen_cform_page_header';
            converterDictionary('rptgen.cform_page_footer')='mlreportgen.rpt2api.rptgen_cform_page_footer';
        end

    end

end


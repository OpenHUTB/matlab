classdef ComponentConverterFactory<mlreportgen.rpt2api.ComponentConverterFactory














    methods

        function obj=ComponentConverterFactory()



            obj=obj@mlreportgen.rpt2api.ComponentConverterFactory();
        end
    end

    methods(Access=protected)
        function converterDictionary=getConverterDictionary(obj)




            converterDictionary=getConverterDictionary@mlreportgen.rpt2api.ComponentConverterFactory(obj);
            converterDictionary('RptgenML.CReport')='slreportgen.rpt2api.RptgenSL_CReport';
            converterDictionary('RptgenML.CForm')='slreportgen.rpt2api.RptgenML_CForm';
            converterDictionary('rptgen_sl.csl_auto_table')='slreportgen.rpt2api.rptgen_sl_csl_auto_table';
            converterDictionary('rptgen_sl.csl_blk_doc')='slreportgen.rpt2api.rptgen_sl_csl_blk_doc';
            converterDictionary('rptgen_sl.csl_blk_loop')='slreportgen.rpt2api.rptgen_sl_csl_blk_loop';
            converterDictionary('rptgen_sl.csl_mdl_loop')='slreportgen.rpt2api.rptgen_sl_csl_mdl_loop';
            converterDictionary('rptgen_sl.csl_sys_filter')='slreportgen.rpt2api.rptgen_sl_csl_sys_filter';
            converterDictionary('rptgen_sl.csl_sys_loop')='slreportgen.rpt2api.rptgen_sl_csl_sys_loop';
            converterDictionary('rptgen_sl.csl_sys_snap')='slreportgen.rpt2api.rptgen_sl_csl_sys_snap';
            converterDictionary('rptgen_sl.csl_cfgset')='slreportgen.rpt2api.rptgen_sl_csl_cfgset';
            converterDictionary('rptgen_sl.CAnnotationLoop')='slreportgen.rpt2api.rptgen_sl_CAnnotationLoop';
            converterDictionary('rptgen_sl.csl_sig_loop')='slreportgen.rpt2api.rptgen_sl_csl_sig_loop';
            converterDictionary('rptgen_sl.csl_ws_var_loop')='slreportgen.rpt2api.rptgen_sl_csl_ws_var_loop';
            converterDictionary('rptgen_sl.csl_ws_variable')='slreportgen.rpt2api.rptgen_sl_csl_ws_variable';
            converterDictionary('rptgen_sl.csl_emlfcn')='slreportgen.rpt2api.rptgen_sl_csl_emlfcn';
            converterDictionary('rptgen_sl.csl_blk_lookup')='slreportgen.rpt2api.rptgen_sl_csl_blk_lookup';
            converterDictionary('rptgen_sl.csl_blk_sort_list')='slreportgen.rpt2api.rptgen_sl_csl_blk_sort_list';
            converterDictionary('rptgen_sl.csl_blk_bus')='slreportgen.rpt2api.rptgen_sl_csl_blk_bus';
            converterDictionary('rptgen_sl.csl_cfcn')='slreportgen.rpt2api.rptgen_sl_csl_cfcn';
            converterDictionary('rptgen_sl.csl_ccaller')='slreportgen.rpt2api.rptgen_sl_csl_ccaller';
            converterDictionary('rptgen_sl.csl_obj_fun_var')='slreportgen.rpt2api.rptgen_sl_csl_obj_fun_var';
            converterDictionary('rptgen_sl.csl_prop_table')='slreportgen.rpt2api.rptgen_sl_csl_prop_table';


            converterDictionary('rptgen_sf.csf_chart_loop')='slreportgen.rpt2api.rptgen_sf_csf_chart_loop';
            converterDictionary('rptgen_sf.csf_obj_loop')='slreportgen.rpt2api.rptgen_sf_csf_obj_loop';
            converterDictionary('rptgen_sf.csf_obj_snap')='slreportgen.rpt2api.rptgen_sf_csf_obj_snap';
            converterDictionary('rptgen_sf.csf_auto_table')='slreportgen.rpt2api.rptgen_sf_csf_auto_table';
            converterDictionary('rptgen_sf.csf_state_loop')='slreportgen.rpt2api.rptgen_sf_csf_state_loop';
            converterDictionary('rptgen_sf.csf_truthtable')='slreportgen.rpt2api.rptgen_sf_csf_truthtable';
            converterDictionary('rptgen_sf.csf_obj_filter')='slreportgen.rpt2api.rptgen_sf_csf_obj_filter';
        end

        function converter=makeConverter(~,converterClass,component,...
            rptFileConverter)%#ok<INUSD>)
            import slreportgen.rpt2api.*
            import mlreportgen.rpt2api.*
            converter=eval(converterClass+...
            "(component, rptFileConverter)");
        end
    end

end




if isunix

    load_shared_object_workaround('libmwSLSymbolicExpr');
    load_shared_object_workaround('libmwcg_ir');
    load_shared_object_workaround('libmwcgir_construct');
    load_shared_object_workaround('libmwsl_feature');
    load_shared_object_workaround('libmwsl_types');
    load_shared_object_workaround('libmwconfigset_base');
    load_shared_object_workaround('libmwsl_utility');
    load_shared_object_workaround('libmwslcg_identifiers');
    load_shared_object_workaround('libmwslcg_filepackaging');
    load_shared_object_workaround('libmwslcg');
    load_shared_object_workaround('libmwslexec_sto');
    load_shared_object_workaround('libmwdastudio_util');
    load_shared_object_workaround('libmwrtwcg');
    load_shared_object_workaround('libmwsl_units');
    load_shared_object_workaround('libmwsl_data_access');
    load_shared_object_workaround('libmwslpointerutil');
    load_shared_object_workaround('libmwsl_prm_descriptor');
    load_shared_object_workaround('libmwSimulinkBlock');
    load_shared_object_workaround('libmwsl_graphical_classes');
    load_shared_object_workaround('libmwsl_engine_classes');
    load_shared_object_workaround('libmwsl_prm_engine');
    load_shared_object_workaround('libmwsl_compile');
    load_shared_object_workaround('libmwslcg_impl');
    load_shared_object_workaround('libmwsl_link_bd');

    load_simulink;
end

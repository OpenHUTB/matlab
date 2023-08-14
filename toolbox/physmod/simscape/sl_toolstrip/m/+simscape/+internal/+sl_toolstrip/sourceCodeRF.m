function schema=sourceCodeRF(cbinfo,~)




    schema=sl_container_schema;
    schema.tag='Simscape:ViewSource';
    schema.autoDisableWhen='Never';
    schema=simscape.internal.contextMenuViewSource(cbinfo);

    schema.icon='matlabDocument';
    schema.label='physmod:simscape:sl_toolstrip:slToolstrip:SourceCode';
end
function out=convertDDGSchema(schema)



    s=configset.internal.util.removeHandle(schema);
    out=configset.internal.util.formatDDGSchema(s);

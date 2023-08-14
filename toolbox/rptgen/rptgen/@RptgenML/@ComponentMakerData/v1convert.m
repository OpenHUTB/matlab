function v1convert(h,v1info)




    h.PropertyName=v1info.Name;
    h.Description=v1info.String;

    switch v1info.Type
    case 'LOGICAL'
        h.DataTypeString='bool';
        h.FactoryValueString=RptgenML.toStringExe(v1info.Default,v1info.Type);
    case 'ENUM'
        ev={};
        en={};
        for i=length(v1info.enumValues):-1:1
            ev{i}=strrep(rptgen.toString(v1info.enumValues{i},0),'''','''''');
            en{i}=strrep(rptgen.toString(v1info.enumNames{i},0),'''','''''');
        end

        h.EnumValues=ev;
        h.EnumNames=en;

        h.DataTypeString='!ENUMERATION';
        h.FactoryValueString=['''',strrep(rptgen.toString(v1info.Default,0),'''',''''''),''''];
    case 'NUMBER'
        h.DataTypeString='double';
        h.FactoryValueString=RptgenML.toStringExe(v1info.Default,v1info.Type);
    case 'STRING'
        h.DataTypeString='string';
        h.FactoryValueString=RptgenML.toStringExe(v1info.Default,v1info.Type);
    case 'CELL';
        h.DataTypeString='string vector';
        h.FactoryValueString=RptgenML.toStringExe(v1info.Default,v1info.Type);
    otherwise
        warning(message('rptgen:RptgenML_ComponentMakerData:cannotConvertV1Prop',...
        v1info.Name));
        h.DataTypeString='MATLAB array';
        h.FactoryValueString='[]';
    end


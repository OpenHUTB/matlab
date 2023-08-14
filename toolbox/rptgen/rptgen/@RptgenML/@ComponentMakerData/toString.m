function s=toString(h)




    s=sprintf('\n%%------ %s --------\n',h.PropertyName);

    if strcmpi(h.DataTypeString,'!enumeration')
        dType=sprintf(' {\n');
        nameCount=length(h.enumNames);
        for i=1:length(h.enumValues)
            if nameCount>=i
                displayName=strrep(h.enumNames{i},'''','''''');
            else
                displayName=h.enumValues{i};
            end


            dType=sprintf('%s\t''%s'',\t''%s''\n',...
            dType,...
            h.enumValues{i},...
            displayName);
        end
        dType=sprintf('%s}',dType);
    elseif strcmp(h.DataTypeString,rptgen.makeStringType)
        dType='rptgen.makeStringType';
    else
        dType=['''',h.DataTypeString,''''];
    end


    s=sprintf('%sp = rptgen.prop(h,''%s'',%s,%s,...\n\t''%s'');\n',...
    s,...
    h.PropertyName,...
    dType,...
    h.FactoryValueString,...
    strrep(h.Description,'''',''''''));


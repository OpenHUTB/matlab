function disp(obj,varargin)








    col=49;
    indent=5;





    fprintf('  <a href="matlab:helpPopup %s">WorkflowConfig</a> with properties:\n\n',class(obj));
    dispParameter(col,indent,obj,'TargetWorkflow');
    dispParameter(col,indent,obj,'SynthesisTool');
    properties=obj.Properties('TopLevelTasks');
    for j=1:length(properties)
        property=properties{j};
        dispParameter(col,indent,obj,property);
    end
    fprintf('\n');





    for i=1:length(obj.Tasks)
        task=obj.Tasks{i};
        dispParameter(col,indent,obj,task);
    end





    for i=1:length(obj.Tasks)
        task=obj.Tasks{i};
        if(obj.(task)&&isKey(obj.Properties,task))
            dispHeading(col,indent,task);
            properties=obj.Properties(task);
            for j=1:length(properties)
                property=properties{j};
                dispParameter(col,indent,obj,property);
            end
        end
    end

end





function dispHeading(col,indent,name)

    strongBegin='';strongEnd='';
    if matlab.internal.display.isHot()
        strongBegin=getString(message('MATLAB:table:localizedStrings:StrongBegin'));
        strongEnd=getString(message('MATLAB:table:localizedStrings:StrongEnd'));
    end
    fmt=[strongBegin,'%s',strongEnd];

    spaces=repmat(' ',1,col-indent-length(name));
    fprintf('\n%s',spaces);
    fprintf(fmt,name);
    fprintf('\n');

end

function dispParameter(col,indent,obj,property)
    spaces=repmat(' ',1,col-indent-length(property));

    switch(class(obj.(property)))

    case 'logical'
        fmt='%s%s: %s\n';
        if(obj.(property))
            value='true';
        else
            value='false';
        end

    case 'char'
        fmt='%s%s: ''%s''\n';
        value=obj.(property);

    case 'double'
        fmt='%s%s: %0.0f\n';
        value=obj.(property);

    otherwise
        fmt='%s%s: %s\n';
        value=[class(obj.(property)),'.',char(obj.(property))];

    end

    fprintf(fmt,spaces,property,value);
end



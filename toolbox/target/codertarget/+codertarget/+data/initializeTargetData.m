function initializeTargetData(hSrc,varargin)




    resetCoderTargetData=true;
    if nargin>1



        resetCoderTargetData=~isequal(varargin{1},'update');
    end

    hCS=hSrc.getConfigSet();

    parameters={};
    if isValidParam(hCS,'CoderTargetData')
        coderTargetCC=hCS.getComponent('Coder Target');
        if~isempty(coderTargetCC)
            parameters=getDialogCustomizations(coderTargetCC,resetCoderTargetData);
        end

        for i=1:numel(parameters)
            if resetCoderTargetData||~locIsThisExistingParameter(hCS,parameters{i})
                codertarget.data.setParameterValueForWidget(hCS,parameters{i});
            end
        end




        paramNames={{'ConnectionInfo','codertarget.attributes.getConnectionInfo'}};
        for i=1:numel(paramNames)
            if~resetCoderTargetData&&codertarget.data.isValidParameter(hCS,paramNames{i}{1})
                locUpdateParameterValue(hCS,paramNames{i});
            end
        end
    end
end


function ret=locIsThisExistingParameter(hCS,widgetHint)
    ret=false;
    if~isfield(widgetHint,'DoNotStore')||~widgetHint.DoNotStore
        tagprefix='Tag_ConfigSet_CoderTarget_';
        if~isempty(widgetHint.Storage)
            paramName=widgetHint.Storage;
        else
            paramName=strrep(widgetHint.Tag,tagprefix,'');
        end
        data=get_param(hCS,'CoderTargetData');
        pos=strfind(paramName,'.');
        if isempty(pos)
            ret=isfield(data,paramName);
        else
            s1=paramName(1:pos-1);
            s2=paramName(pos+1:end);
            ret=isfield(data,s1)&&isfield(data.(s1),s2);
        end
    end
end


function locUpdateParameterValue(hCS,paramName)


    data=get_param(hCS,'CoderTargetData');
    if isfield(data,paramName{1})
        param=orderfields(feval(paramName{2},hCS));
        savedParam=orderfields(codertarget.data.getParameterValue(hCS,paramName{1}));
        paramFieldNames=fieldnames(param);
        savedParamFieldNames=fieldnames(savedParam);
        if~isequal(paramFieldNames,savedParamFieldNames)
            newFields=setdiff(paramFieldNames,savedParamFieldNames);
            for i=1:numel(newFields)
                codertarget.data.setParameterValue(hCS,[paramName{1},'.',newFields{i}],param.(newFields{i}));
            end
        end
        for i=1:numel(paramFieldNames)
            if any(contains(savedParamFieldNames,paramFieldNames{i}))&&...
                isstruct(data.(paramName{1}).(paramFieldNames{i}))
                field=orderfields(param.(paramFieldNames{i}));
                savedField=orderfields(savedParam.(paramFieldNames{i}));
                if~isequal(fieldnames(field),fieldnames(savedField))
                    newFields=setdiff(fieldnames(field),fieldnames(savedField));
                    for j=1:numel(newFields)
                        savedParam.(paramFieldNames{i}).(newFields{j})=param.(paramFieldNames{i}).(newFields{j});
                    end
                    codertarget.data.setParameterValue(hCS,[paramName{1},'.',paramFieldNames{i}],savedParam.(paramFieldNames{i}));
                end
            end
        end
    end
end
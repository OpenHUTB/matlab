function out=execute(this,d,varargin)%#ok-mlint





    currentModel=get(rptgen_sl.appdata_sl,'CurrentModel');
    rptgen_sl.uncompileModel(currentModel);

    if isempty(currentModel)
        this.status(...
        getString(message('rptgen:fp_cfp_options:noCurrentModel')),...
        2);

    else
        propNames={
'DataTypeOverride'
''
'MinMaxOverflowLogging'
''
'MinMaxOverflowArchiveMode'
''
        };

        for i=1:2:length(propNames)-1
            thisProp=propNames{i};
            propNames{i+1}=get_param(currentModel,thisProp);
            set_param(currentModel,thisProp,this.(thisProp));
        end

        propNames=[propNames;{
'Dirty'
        get_param(currentModel,'Dirty')
        }];
    end

    firstChild=this.down;
    if~isempty(firstChild)
        out=this.runChildren(d,[],firstChild);

        if~isempty(currentModel)

            set_param(currentModel,propNames{:});
        end
    else
        out=createComment(d,...
        'Setting fixed point global options');
    end



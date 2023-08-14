function postConfigs=describeConfig(cfg)



    postConfigs=doDescribeConfig(cfg,0);
end

function postConfigs=doDescribeConfig(cfg,cfgIdx)
    str=evalc('disp(cfg)');

    if~isempty(regexp(str,'^[\s]*(ans = )?\s*.*<a href="matlab.+<\/a>.+[\r\n][\s]*',...
        'once','dotexceptnewline'))

        catNames={''};
        bodies={regexprep(str,'^[\s]*(ans = )?\s*.*<a href="matlab.+<\/a>.+[\r\n][\s]*','',...
        'once','dotexceptnewline')};
    else

        [catNames,bodies]=regexp(str,'^-{5,}[\s]+(.+)[\s]-{5,}$',...
        'tokens','split','lineanchors','dotexceptnewline');
        catNames=[catNames{:}];
        if isempty(catNames)||(numel(bodies)~=numel(catNames)+1)

            postConfigs=[];
            return
        end
        bodies=bodies(2:end);
    end

    groups=cell2struct(cell(numel(catNames),2),{'name','properties'},2);
    childCfgs=cell2struct(cell(0,2),{'configClass','groups'},2);

    try
        defaultCfg=feval(class(cfg));
        validProps=properties(defaultCfg);
    catch
        defaultCfg=[];
        validProps={};
    end

    for i=1:numel(bodies)
        tokens=regexp(strtrim(bodies{i}),'^[\s]*(.+?)[\s]*:[\s]*(.+)[\s]*$',...
        'tokens','lineanchors','dotexceptnewline');
        tokens=[tokens{:}];

        if~isempty(tokens)
            propNames=tokens(1:2:numel(tokens));
            dispVals=tokens(2:2:numel(tokens));
            if~isempty(validProps)


                mask=ismember(propNames,validProps);
                propNames=propNames(mask);
                dispVals=dispVals(mask);
            end
        else
            propNames=cell(1,0);
            dispVals=cell(1,0);
        end

        numProps=numel(dispVals);

        matlabTypes=cell(1,numProps);
        sizes=cell(1,numProps);
        refs=zeros(1,numProps);
        values=cell(1,numProps);
        changed=false(1,numProps);

        for j=1:numel(dispVals)
            value=cfg.(propNames{j});
            matlabTypes{j}=class(value);
            sizes{j}=size(value);

            if~isempty(defaultCfg)
                changed(j)=~isequaln(value,defaultCfg.(propNames{j}));
            end
            if isobject(value)
                childCfg=doDescribeConfig(value,refs(j));
                if~isempty(childCfg)
                    refs(j)=numel(childCfgs)+cfgIdx+1;
                    childCfgs(end+1)=childCfg;%#ok<AGROW>
                end
            elseif~isstruct(value)&&(ischar(value)||isstring(value)||sum(size(value))<10)
                values{j}=value;
            end
        end

        groups(i).name=catNames{i};
        groups(i).properties=cell2struct(vertcat(...
        propNames,values,dispVals,sizes,matlabTypes,num2cell(refs),num2cell(changed)),...
        {'name';'value';'dispValue';'size';'matlabType';'ref';'changed'},1);
    end

    if~isempty(cfg)&&isprop(cfg,'GpuConfig')&&~isempty(cfg.GpuConfig)&&...
        ~ismember('coder.GpuCodeConfig',{childCfgs.configClass})


        childCfgs(end+1)=doDescribeConfig(cfg.GpuConfig,numel(childCfgs)+cfgIdx+1);
    end

    postConfigs.configClass=class(cfg);
    postConfigs.groups=groups;
    postConfigs=[postConfigs,childCfgs];
end

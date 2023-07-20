function findOptionsObject=FindOptions(varargin)


































































































    findOptionsObject=Simulink.internal.FindOptions;

    p=inputParser;
    p.FunctionName='Simulink.FindOptions';

    cellfun(...
    @(opt)addParameter(p,opt,findOptionsObject.(opt)),...
    properties(findOptionsObject),...
    'UniformOutput',false);

    parse(p,varargin{:});

    if slfeature('MatchFilterEnabled')>0&&...
        ~any(strcmp(p.UsingDefaults,'Variants'))&&...
        ~any(strcmp(p.UsingDefaults,'MatchFilter'))



        DAStudio.error('Simulink:Commands:FindSystemMatchFilterUsedWithVariantsOption');
    end

    opts=fieldnames(p.Results);
    for i=1:numel(opts)
        opt=opts{i};

















        if slfeature('FindSystemVariantsRemoval')>=2&&...
            strcmp(opt,'Variants')&&...
            ~any(strcmp(p.UsingDefaults,'Variants'))




            resultOpt=p.Results.(opt);
            switch resultOpt
            case 'AllVariants'
                warnId='Simulink:Commands:FindSystemAllVariantsRemoval';
                warnMsg=message(warnId,resultOpt,'@Simulink.match.allVariants');
                warning(warnId,warnMsg.getString());
            case 'ActiveVariants'
                warnId='Simulink:Commands:FindSystemVariantsOptionRemoval';
                warnMsg=message(warnId,resultOpt,'@Simulink.match.activeVariants');
                warning(warnId,warnMsg.getString());
            case 'ActivePlusCodeVariants'
                warnId='Simulink:Commands:FindSystemVariantsOptionRemoval';
                warnMsg=message(warnId,resultOpt,'@Simulink.match.codeCompileVariants');
                warning(warnId,warnMsg.getString());
            otherwise


            end
        end
        findOptionsObject.(opt)=p.Results.(opt);
    end
end



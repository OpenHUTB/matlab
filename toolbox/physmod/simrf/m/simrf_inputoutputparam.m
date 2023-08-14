function[inputData,outputData]=simrf_inputoutputparam(dae,inputInfo,outputInfo)







    for i=1:length(inputInfo)
        tests={
        @lIsNumeric,{'Frequencies'}
        @lIsNonnegative,{'Frequencies'}
        @lIsNumeric,{'NoiseParameters'}
        };
        lTestBlock(inputInfo(i).src.block,tests);
    end




    for i=1:length(outputInfo)
        oi=outputInfo(i);
        for j=1:length(oi.dst)
            tests={
            @lIsNumeric,{'Frequencies'}
            @lIsNonnegative,{'Frequencies'}
            };
            lTestBlock(oi.dst{j}.block,tests);
        end




        obp=lMaskParams(oi.dst{1}.block);
        for j=2:length(oi.dst)
            obp2=lMaskParams(oi.dst{j}.block);
            if obp2.PseudoPeriodic~=obp.PseudoPeriodic
                pm_error('simrf:create_dae:ConsistentParameters',...
                'PseudoPeriodic',oi.dst{1}.block,oi.dst{j}.block);
            elseif obp.PseudoPeriodic&&~isequal(obp2.Frequencies,obp.Frequencies)
                pm_error('simrf:create_dae:ConsistentParameters',...
                'Frequencies',sprintf('%s',oi.dst{1}.block),oi.dst{j}.block);
            end
        end
    end




    id=struct('PseudoPeriodic',false,...
    'Dimension',0,...
    'Frequencies',[],...
    'NoiseDistribution',int32(1),...
    'NoiseParameters',[]);
    od=struct('PseudoPeriodic',false,'Frequencies',[]);
    inputData=repmat({id},length(dae.Input),1);
    outputData=repmat({od},length(dae.Output),1);




    persistent ndMap;
    if isempty(ndMap)

        choices={'none','white','pwl'};
        for i=1:length(choices)
            ndMap.(choices{i})=i;
        end
    end
    for i=1:length(inputInfo)
        ii=inputInfo(i);
        ibp=lMaskParams(ii.src.block);
        if isfield(ii,'dim')
            dim=ii.dim;
        else
            dim=[1,1];
        end
        if ssc_rf_set_global_parameter('estimatememory')&&...
            isscalar(ibp.NoiseParameters)&&ibp.NoiseParameters==-1
            ud=get_param(ii.src.block,'UserData');
            if~isempty(ud)&&isfield(ud,'NoiseParameters')
                ibp.NoiseParameters=ud.NoiseParameters;
            end
        end
        id=struct('PseudoPeriodic',ibp.PseudoPeriodic,...
        'Dimension',double(dim),...
        'Frequencies',double(ibp.Frequencies),...
        'NoiseDistribution',int32(ndMap.(ibp.NoiseDistribution)),...
        'NoiseParameters',double(ibp.NoiseParameters));
        for j=1:length(ii.dst)
            inputData{ii.dst(j).index}=id;
        end
    end
    for i=1:length(outputInfo)
        oi=outputInfo(i);
        obp=lMaskParams(oi.dst{1}.block);
        od=struct('PseudoPeriodic',obp.PseudoPeriodic,...
        'Frequencies',double(obp.Frequencies));
        for j=1:length(oi.src)
            outputData{oi.src(j).index}=od;
        end
    end
end

function out=lMaskParams(block)
    ws=get_param(block,'MaskWSVariables');
    ca=[{ws.Name};{ws.Value}];
    out=struct(ca{:});
end

function lIsNumeric(block,values,name)
    if~isnumeric(values.(name))
        pm_error('simrf:create_dae:NumericParameter',name,block);
    end
end

function lIsNonnegative(block,values,name)
    if any(values.(name)<0)
        pm_error('simrf:create_dae:NonnegativeParameter',name,block);
    end
end

function lTestBlock(block,tests)
    values=lMaskParams(block);
    for test=tests'
        [pred,names]=test{:};
        feval(pred,block,values,names{:});
    end
end

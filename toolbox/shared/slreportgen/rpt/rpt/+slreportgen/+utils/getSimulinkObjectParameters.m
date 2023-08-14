
function propList=getSimulinkObjectParameters(handle,objType)

    switch lower(objType)
    case 'model'
        propList={'Description'};
    case 'system'
        propList={'Description'};
    case 'annotation'
        propList={'Text'};
    case{'block','modelreference'}

        propList=getBlockParams(handle);
    case{'port'}
        propList=getPortObjectParams(handle);
    case{'line'}
        propList=getLineObjectParams(handle);
    otherwise
        propList=getOtherObjectParams(handle);
    end
end

function bParam=getBlockParams(blk)
    bParam=get_param(blk,'MaskNames');

    if~isempty(bParam)
        maskVisbility=get_param(blk,'MaskVisibilities');
        bParam=bParam(strcmpi(maskVisbility,'on'));

    else
        blkType=get_param(blk,'blocktype');
        switch blkType
        case 'Scope'
            bParam={};
        case 'SubSystem'
            bParam={};
            if slprivate('is_stateflow_based_block',blk)
                chartId=slreportgen.utils.block2chart(blk);
                if isa(chartId,'Stateflow.EMChart')
                    bParam={'Script'};
                else
                    if isa(chartId,'Stateflow.TruthTableChart')
                        bParam={'UpdateMethod (TT)','SampleTime (TT)'};
                    else
                        bParam={'Chart'};
                    end
                end
            end
        case 'Inport'
            bParam={
'Port'
'PortDimensions'
'SampleTime'
'DefinedInBlk'
'OutMin'
'OutMax'
'OutDataTypeStr'
            };
        case 'Lookup_n-D'
            bParam=locGetLookupParams(blk);

        otherwise
            bParam=locGetDialogParams(blk);
        end
    end
end


function bParam=getOtherObjectParams(handle)

    dParam=get(handle);
    if isstruct(dParam)
        bParam=fieldnames(dParam);
        bParam=bParam(:);
    else
        bParam={};
    end
end


function bParam=getPortObjectParams(handle)

    dParam=get_param(handle,'objectparameters');
    if isstruct(dParam)
        bParam=fieldnames(dParam);
        bParam=bParam(:);
        skipParam={'Handle','Type','HiliteAncestors','PropogatedSignals','Line','Position','Rotation',...
        'ShowPropagatedSignals','PerturbationForJacobian','SignalObject','MustResolveToSignalObject',...
        'ConnectionCallback'};
        for ind=1:length(skipParam)
            bParam(strcmp(skipParam{ind},bParam))=[];
        end

    else
        bParam={};
    end
end


function bParam=getLineObjectParams(handle)

    dParam=get_param(handle,'objectparameters');
    if isstruct(dParam)
        bParam=fieldnames(dParam);
        bParam=bParam(:);
        skipParam={'Handle','Type','HiliteAncestors','Points','LineParent','LineChildren','Selected'};
        for ind=1:length(skipParam)
            bParam(strcmp(skipParam{ind},bParam))=[];
        end

    else
        bParam={};
    end
end

function bParam=locGetDialogParams(blk)

    dParam=get_param(blk,'dialogparameters');
    if isstruct(dParam)
        bParam=fieldnames(dParam);
        bParam=bParam(:);
    else
        bParam={};
    end
end


function bParams=locGetLookupParams(blk)

    bParams=locGetDialogParams(blk);


    dim=str2double(get_param(blk,'NumberOfTableDimensions'));
    nParams=length(bParams);
    badIdx=false(nParams,1);
    for i=1:nParams
        tokens=regexp(bParams{i},'Dimension(\d+)','tokens');
        if~isempty(tokens)
            paramDims=str2double(tokens{1}{1});
            if(paramDims>dim)
                badIdx(i)=true;
            end
        end
    end


    bParams(badIdx)=[];
end




function pTree=addToTree(pTree,name,dims,childrenIndex,isDimsZeroBased,dt,sourceType,modelName,isRootNode)




    busObjName='';

    if startsWith(dt,'fixdt(')
        dt='fixdt()';
    elseif startsWith(dt,'Enum:')
        dt='enum';
    elseif startsWith(dt,'Bus:')
        busObjName=dt(6:end);
        dt='struct';
    end

    switch dt
    case 'struct'
        dtNum=-1;
        dt_exp='-';
    case{'double','single','half'}

        dtNum=0;
        dt_exp='fmi2Real';
    case{'int32','int8','uint8','int16','uint16','uint32','int64','uint64'}

        dtNum=1;
        dt_exp='fmi2Integer';
    case{'logical','boolean'}
        dtNum=2;
        dt_exp='fmi2Boolean';
    case{'string','char'}
        dtNum=3;
        dt_exp='fmi2String';
    case 'enum'
        dtNum=4;
        dt_exp='fmi2Integer';
    otherwise





        if~isRootNode

            idx=length(pTree);
            while~pTree(idx).IsRoot
                idx=idx-1;
            end
            rootNodeName=pTree(idx).Name;
            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:FMU2ExpCSParameterElementDataTypeNotSupported',rootNodeName,name,dt),'Warning',modelName);
        else

            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:FMU2ExpCSParameterDataTypeNotSupported',name,dt),'Warning',modelName);
        end
        throw(MException('FMUExport:skipVariable','datatype unsupported in FMI'));
    end
    if~isRootNode
        exportedName='';
    elseif contains(sourceType,'InstArg_')
        blockPath=sourceType(9:end);
        bps=strsplit(blockPath,':');
        exportedName=name;
        for i=length(bps):-1:1
            exportedName=[extractAfter(bps{i},'/'),'_',exportedName];
        end
    else
        exportedName=name;
    end

    exported='on';
    if strcmp(sourceType,'Logged Signal')||strcmp(sourceType,'Test Point')||strcmp(sourceType,'Data Store')
        exported='off';
    end

    p=struct(...
    'Name',name,...
    'Dims',dims,...
    'ChildrenIndex',childrenIndex,...
    'IsDimsZeroBased',isDimsZeroBased,...
    'DataType',dtNum,...
    'SourceType',sourceType,...
    'IsRoot',isRootNode,...
    'exported',exported,...
    'exportedName',exportedName,...
    'dt',dt,...
    'exportedDT',dt_exp,...
    'busObjName',busObjName);
    pTree=[pTree,p];
end

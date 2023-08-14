function initValStruct=constructTSInitValStruct(d,sigInfo,pathToReactiveTest)





    initValStruct=[];

    if strcmp(sigInfo.dataType,'fcn_call')
        initValStruct.name=d.Name;
        initValStruct.class='fcnCall';
        initValStruct.scalar=false;
        initValStruct.size=1;
        if isfield(sigInfo,'modelEventType')
            initValStruct.modelEventType=sigInfo.modelEventType;
        else

            initValStruct.modelEventType='DontCare';
        end
        return;
    end



    dataType=d.DataType;
    bdName=bdroot(pathToReactiveTest);
    resolvedType=parseDataType(dataType,bdName);

    if resolvedType.isAlias
        dObj=slResolve(dataType,bdroot);
        dataType=dObj.BaseType;
    end

    if resolvedType.isBus
        busName=dataType(6:end);
        [dims,nDims]=getDataDims(d);
        try


            dataAccessor=Simulink.data.DataAccessor.create(bdName);
            X=Simulink.Bus.createMATLABStruct(busName,[],[1,1],dataAccessor);
        catch
            if strcmp(get_param(pathToReactiveTest,'SFBlockType'),'Test Sequence')
                ME2=MException('Simulink:Harness:TestSeqSrcOutputNotInitialized','%s',...
                DAStudio.message('Simulink:Harness:TestSeqSrcOutputNotInitialized',...
                d.Name,pathToReactiveTest));
            else
                ME2=MException('Simulink:Harness:StateflowChartSrcOutputNotInitialized','%s',...
                DAStudio.message('Simulink:Harness:StateflowChartSrcOutputNotInitialized',...
                d.Name,pathToReactiveTest));
            end
            Simulink.harness.internal.warn(ME2);
            X=[];
        end
        if~isempty(X)
            if prod(dims)>1
                if sigInfo.isMessage
                    valStruct.name=[d.Name,'.data'];
                else
                    valStruct.name=d.Name;
                end

                if get_param(pathToReactiveTest,'SFBlockType')=="MATLAB Function"






                    valStructStr=valStruct.name;
                else
                    valStructStr=[valStruct.name,'(1)'];
                end
                initValStruct=[initValStruct,getBusInfo(X,valStructStr)];

                valStruct.class=dataType;
                valStruct.scalar=false;
                valStruct.size=d.Props.Array.Size(2:end-1);
                if nDims==1
                    valStruct.size=[valStruct.size,', 1'];
                end
                valStruct.modelEventType='DontCare';
                initValStruct=[initValStruct,valStruct];
            else
                if sigInfo.isMessage
                    dataName=[d.Name,'.data'];
                else
                    dataName=d.Name;
                end
                initValStruct=[initValStruct,getBusInfo(X,dataName)];
            end
        end
    else
        valStruct.name=d.Name;
        if sigInfo.isMessage
            valStruct.name=[valStruct.name,'.data'];
        end
        valStruct.class=dataType;
        [dims,nDims]=getDataDims(d);
        valStruct.scalar=prod(dims)==1;

        if~valStruct.scalar
            valStruct.size=d.Props.Array.Size(2:end-1);
            if nDims==1
                valStruct.size=[valStruct.size,', 1'];
            end
        else
            valStruct.size='1';
        end
        valStruct.modelEventType='DontCare';

        initValStruct=[initValStruct,valStruct];
    end

end


function busInfo=getBusInfo(X,parent)
    busInfo=[];
    for f=fieldnames(X)'
        chName=f{:};
        fullName=[parent,'.',chName];
        child=X(1).(chName);
        isBus=isstruct(child);
        isScalar=numel(child)==1;
        if isBus

            prefix=fullName;
            if~isScalar
                prefix=[prefix,'(1)'];%#ok
            end
            chBusInfo=getBusInfo(child,prefix);
            busInfo=[busInfo,chBusInfo];%#ok
            chClass='Bus: ';
        else
            chClass=class(child);
        end
        if~isBus||~isScalar

            busInfo(end+1).name=fullName;%#ok
            if isenum(child)
                busInfo(end).class=['Enum: ',chClass];
            else
                busInfo(end).class=chClass;
            end
            busInfo(end).scalar=isScalar;

            if~isScalar
                busInfo(end).size=regexprep(num2str(size(child)),'\s+',',');
            else
                busInfo(end).size='1';
            end
            busInfo(end).modelEventType='DontCare';
        end
    end
end

function[dims,nDims]=getDataDims(d)
    dimStr=d.Props.Array.Size(2:end-1);
    dimStr=strrep(dimStr,',',' ');
    dims=sscanf(dimStr,'%f');
    nDims=length(dims);
end



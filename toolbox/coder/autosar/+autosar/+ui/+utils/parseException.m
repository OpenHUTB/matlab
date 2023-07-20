



function[errInports,errOutports,errFuncs,errDataTrans,errCallers]=...
    parseException(mException,msgType,hyperlinkMsg,errInports,...
    errOutports,errFuncs,errDataTrans,errCallers,modelName,...
    diagnosticType)

    assert(strcmp(diagnosticType,'Error')||...
    strcmp(diagnosticType,'Warning'));

    if~isempty(mException.cause)
        for index=1:length(mException.cause)
            [errInports,errOutports,errFuncs,errDataTrans,errCallers]=...
            autosar.ui.utils.parseException(mException.cause{index},...
            msgType,hyperlinkMsg,errInports,errOutports,errFuncs,...
            errDataTrans,errCallers,modelName,diagnosticType);
        end
    else
        quote='''';
        blockNamePositions=strfind(mException.message,quote);

        if~(isempty(blockNamePositions)||length(blockNamePositions)==1)
            srcFullname='';

            for ii=1:length(blockNamePositions)-1
                srcFullname=mException.message(blockNamePositions(ii)+...
                1:blockNamePositions(ii+1)-1);
                try
                    validBlock=Simulink.ID.isValid(Simulink.ID.getSID(srcFullname));
                catch ex %#ok<NASGU>
                    validBlock=false;
                end
                if validBlock
                    break;
                end
                srcFullname='';
            end
            if~isempty(srcFullname)
                sourceName=autosar.ui.utils.convertSLObjectNameToGraphicalName(srcFullname);
                if strcmp(srcFullname,autosar.ui.configuration.PackageString.Initialization)...
                    ||strcmp(srcFullname,autosar.ui.configuration.PackageString.StepNodeName)
                    errFuncs{end+1}=srcFullname;
                elseif any(ismember(mException.identifier,{
                    'RTW:autosar:invalidMappingDataTransfer',...
                    'RTW:autosar:invalidMappingDataTransferIrv',...
                    'RTW:autosar:MultiRunnableUnmappedDataTrans',...
                    'RTW:autosar:MultiRunnableReusedIrvName'}))


                    errDataTrans{end+1}=mException.message(blockNamePositions(1)+...
                    1:blockNamePositions(2)-1);
                elseif~isempty(sourceName)
                    try
                        blockType=get_param(srcFullname,'BlockType');
                        switch blockType
                        case 'Inport'
                            paramValue=get_param(srcFullname,...
                            'OutputFunctionCall');
                            if strcmp(paramValue,'on')
                                errFuncs{end+1}=sourceName;
                            else
                                errInports{end+1}=sourceName;
                            end
                        case 'Outport'
                            errOutports{end+1}=sourceName;
                        case{'SubSystem','From','Goto','S-Function','Merge'}
                            errDataTrans{end+1}=sourceName;
                        case 'FunctionCaller'
                            errCallers{end+1}=autosar.ui.utils.getSlFunctionName([modelName,'/',sourceName]);
                        otherwise

                        end
                    catch ME
                        if~strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')&&...
                            ~strcmp(ME.identifier,'Simulink:LoadSave:InvalidBlockDiagramName')
                            rethrow(ME);
                        end
                    end
                end
            end
        end


        if strcmpi(diagnosticType,'Error')
            sldiagviewer.reportError(mException);
        elseif strcmpi(diagnosticType,'Info')
            sldiagviewer.reportInfo(mException);
        else
            sldiagviewer.reportWarning(mException);
        end
    end


end



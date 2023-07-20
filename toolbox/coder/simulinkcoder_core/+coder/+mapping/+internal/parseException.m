



function[errInports,errOutports,errFuncs,errDataTrans,errCallers]=...
    parseException(mException,errInports,...
    errOutports,errFuncs,errDataTrans,errCallers,modelName,...
    diagnosticType)

    assert(strcmp(diagnosticType,'Error')||...
    strcmp(diagnosticType,'Warning'));

    if~isempty(mException.cause)
        for index=1:length(mException.cause)
            [errInports,errOutports,errFuncs,errDataTrans,errCallers]=...
            coder.mapping.internal.parseException(mException.cause{index},...
            errInports,errOutports,errFuncs,...
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

                pos=strfind(srcFullname,'/');
                sourceName=srcFullname(pos+1:end);
                sourceName=regexprep(sourceName,'//','/');
                if~isempty(sourceName)
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


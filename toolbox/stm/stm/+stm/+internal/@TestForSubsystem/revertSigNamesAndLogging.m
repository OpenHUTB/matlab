function revertSigNamesAndLogging(obj,subModel)



    helperResetSigNames(obj,subModel);
    helperResetPorts(obj,subModel);
end


function helperResetSigNames(obj,model)
    preserve_dirty=arrayfun(@(x)Simulink.PreserveDirtyFlag(get_param(x,'Handle'),'blockDiagram'),model,'UniformOutput',true);%#ok<NASGU>

    cellfun(@(sigHdl)set_param(sigHdl,'Name',obj.outSigNameMap(sigHdl)),obj.outSigNameMap.keys);

    cellfun(@(sigHdl)set_param(sigHdl,'DataLoggingName',obj.customSigNameMap(sigHdl)),obj.customSigNameMap.keys);

    cellfun(@(sigHdl)set_param(sigHdl,'DataLoggingNameMode',obj.customSigNameModeMap(sigHdl)),obj.customSigNameModeMap.keys);

    for sigObj=obj.sigObjToRevert

        if strcmp(sigObj.SourceType,'base workspace')
            wkSpc='base';
        else

            wkSpc=get_param(obj.topModel,'ModelWorkspace');
        end

        evalin(wkSpc,[sigObj.Name,'.LoggingInfo.DataLogging = 0;']);
    end

    for sigObjStruct=obj.sigObjLoggingNameRevert
        sigObj=sigObjStruct.signalObject;
        if sigObj.SourceType=="base workspace"
            wkSpc='base';
        else
            wkSpc=get_param(obj.topModel,'ModelWorkspace');
        end
        evalin(wkSpc,[sigObj.Name,'.LoggingInfo.LoggingName = ''',sigObjStruct.loggingName,''';']);
        evalin(wkSpc,[sigObj.Name,'.LoggingInfo.NameMode = ',num2str(sigObjStruct.loggingNameMode),';']);
    end
end

function helperResetPorts(obj,model)

    preserve_dirty=arrayfun(@(x)Simulink.PreserveDirtyFlag(get_param(x,'Handle'),'blockDiagram'),model,'UniformOutput',true);%#ok<NASGU>
    for i=1:length(obj.portHandlesToRevert)
        set_param(obj.portHandlesToRevert(i),'DataLogging','off');
    end
end

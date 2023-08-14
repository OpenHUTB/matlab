classdef FileType<iofile.File





    methods(Static)


        function isSupported=isFileSupported(fileLocation)
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','isFileSupported');
        end


        function aFileReaderDescription=getFileTypeDescription()
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','getFileTypeDescription');
        end


        function outType=getVariableTypeFromVariable(inVar)

            outType=message('sl_web_widgets:customfiles:unknownType').getString;
            if isSLTimeTable(inVar)||isa(inVar,'timeseries')...
                ||is2dDataArray(inVar)||isDataArray(inVar)
                outType=message('sl_web_widgets:customfiles:signalType').getString;
            elseif isFunctionCallSignal(inVar)
                outType=message('sl_web_widgets:customfiles:functioncallType').getString;
            elseif isGroundSignal(inVar)
                outType=message('sl_web_widgets:customfiles:groundType').getString;
            elseif isBusSignal(inVar,true)
                outType=message('sl_web_widgets:customfiles:busType').getString;
            elseif isa(inVar,'Simulink.SimulationData.Dataset')
                outType=message('sl_web_widgets:customfiles:datasetType').getString;
            elseif Simulink.sdi.internal.Util.isStructureWithTime(inVar)||Simulink.sdi.internal.Util.isStructureWithoutTime(inVar)
                outType=message('sl_web_widgets:customfiles:simStruct').getString;
            elseif isSimulationVariable(inVar)
                outType=message('sl_web_widgets:customfiles:simVariable').getString;
            elseif isSimulationBlockParam(inVar)
                outType=message('sl_web_widgets:customfiles:simBlockParam').getString;
            elseif isSimulationModelParam(inVar)
                outType=message('sl_web_widgets:customfiles:simModelParam').getString;
            elseif isSimulationOperatingPoint(inVar)
                outType=message('sl_web_widgets:customfiles:simOperatingPoint').getString;
            end
        end


        function isSupported=isVariableSupported(inVar)

            isSupported=Simulink.io.FileType.isInput(inVar)...
            ||Simulink.io.FileType.isSimulinkParameter(inVar);
        end


        function isSupported=isInput(inVar)

            isSupported=(isSimulinkSignalFormat(inVar)&&~isTimeExpression(inVar));
        end


        function isSupported=isSimulinkParameter(inVar)

            isSupported=isSimulationBlockParam(inVar)||isSimulationModelParam(inVar)...
            ||isSimulationVariable(inVar)||isSimulationOperatingPoint(inVar);
        end

    end


    methods


        function aList=whos(aFile)

            aList=whosImpl(aFile);

            if isempty(aList)
                return;
            end


            if~isstruct(aList)
                DAStudio.error('sl_web_widgets:customfiles:invalidWhosImplReturn');
            end


            if~isfield(aList,'name')||~iscellstr({aList(:).name})
                DAStudio.error('sl_web_widgets:customfiles:invalidWhosImplReturn');
            end


            if isfield(aList,'type')&&~iscellstr({aList(:).type})
                DAStudio.error('sl_web_widgets:customfiles:invalidWhosImplReturnType');
            end


            if~isfield(aList,'type')
                for k=1:length(aList)
                    aList(k).type=message('sl_web_widgets:customfiles:datasetType').getString;
                end
            end
        end


        function varOut=loadAVariable(theMatFile,varName)
            varOut=loadAVariableImpl(theMatFile,varName);

            if~isempty(varOut)&&~isstruct(varOut)
                DAStudio.error('sl_web_widgets:customfiles:invalidReturnLoadAVariableImpl');
            end
        end


        function matFileData=load(aFile)
            matFileData=loadImpl(aFile);

            if~isempty(matFileData)&&~isstruct(matFileData)
                DAStudio.error('sl_web_widgets:customfiles:invalidReturnLoadImpl');
            end
        end


        function validateFileName(aFile,str)
            validateFileNameImpl(aFile,str);
        end


        function[didWrite,errMsg]=export(aFile,fileName,cellOfVarNames,cellOfVarValues,isAppend)

            if isStringScalar(fileName)
                fileName=char(fileName);
            end

            if isempty(fileName)||~ischar(fileName)
                DAStudio.error('sl_web_widgets:customfiles:fileNameNotChar');
            end

            if isstring(cellOfVarNames)
                cellOfVarNames=cellstr(cellOfVarNames);
            end

            if~iscellstr(cellOfVarNames)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNames');
            end

            if length(cellOfVarNames)~=length(cellOfVarValues)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNamesAndVals');
            end

            if~islogical(isAppend)&&~isnumeric(isAppend)
                DAStudio.error('sl_web_widgets:customfiles:isAppendLogical');
            end

            [didWrite,errMsg]=exportImpl(aFile,fileName,cellOfVarNames,cellOfVarValues,isAppend);
        end
    end


    methods(Hidden)


        function aList=whosImpl(aFile)%#ok<*MANU>
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','whosImpl');
        end


        function varOut=loadAVariableImpl(theMatFile,varName)%#ok<*INUSD,*STOUT>
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','loadAVariableImpl');
        end


        function matFileData=loadImpl(aFile)
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','loadImpl');
        end


        function validateFileNameImpl(aFile,str)
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','validateFileNameImpl');
        end


        function[didWrite,errMsg]=exportImpl(~,fileName,cellOfVarNames,cellOfVarValues,isAppend)
            DAStudio.error('sl_web_widgets:customfiles:methodNotOverridden','exportImpl');
        end


        function isSupported=isVarSupported(~,inVar)

            isSupported=Simulink.io.FileType.isVariableSupported(inVar);

        end
    end


    methods


        function[importedData,warnStr]=import(theFile)




            narginchk(1,1);


            importedData.Data=[];
            importedData.Names=[];%#ok<STRNU>
            theFile.fileMetrics.SLDVVarNames={};
            theFile.fileMetrics.SLDVTransformedNames={};
            try
                [importedData,warnStr]=theFile.loadAndValidateData();
            catch ME
                throwAsCaller(ME);
            end
        end

    end

end

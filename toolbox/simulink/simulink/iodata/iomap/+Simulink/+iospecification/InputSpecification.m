classdef InputSpecification<handle
































    properties
        Mode='Index'
        MappingDiagnostic='None'
InputMap
        CustomSpecFile=[]
        Verify=1
        AllowPartial=1
    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version
    end


    properties(Hidden)
        LastModeUsed=[]
        LastVariableNamesUsed=[]
        LastModelUsed=[]
        LastCustomFileUsed=[]
        InputString=[]

    end


    properties(Constant,Hidden)
        ValidModes=Simulink.iospecification.BuiltInMapModes.getBuiltInModes;
        ValidDiagnostics={'None','Warning','Error'};
    end


    properties(Access=private)
        IsComposite=false
    end


    methods


        function inSpec=InputSpecification(varargin)

            numArg=nargin;

            if numArg==0
                inSpec.Mode='Index';
                inSpec.MappingDiagnostic='None';
            end

            if numArg>0
                inSpec.Mode=varargin{1};
                inSpec.MappingDiagnostic='None';
            end

            if numArg>1
                inSpec.MappingDiagnostic=varargin{2};
            end

            if numArg>2
                inSpec.CustomSpecFile=varargin{3};
            end

            if numArg>3
                inSpec.InputMap=varargin{4};
            end

            inSpec.Version=1.1;

        end


        function set.Mode(inSpec,modeStr)

            if isStringScalar(modeStr)
                modeStr=convertStringsToChars(modeStr);
            end

            if ischar(modeStr)&&any(strcmpi(inSpec.ValidModes,modeStr))
                inSpec.Mode=inSpec.ValidModes{strcmpi(inSpec.ValidModes,modeStr)};
            else
                DAStudio.error('sl_iospecification:iostrategy:errorInSpecMode');
            end
        end


        function set.MappingDiagnostic(inSpec,mapDiag)

            if isStringScalar(mapDiag)
                mapDiag=convertStringsToChars(mapDiag);
            end

            if ischar(mapDiag)&&any(strcmpi(inSpec.ValidDiagnostics,mapDiag))
                inSpec.MappingDiagnostic=inSpec.ValidDiagnostics{strcmpi(inSpec.ValidDiagnostics,mapDiag)};
            else
                DAStudio.error('sl_iospecification:iostrategy:errorInSpecDiagnostic');
            end
        end


        function InputMappings=getMap(inSpec,modelName,varNames,vars)













            if isStringScalar(modelName)
                modelName=convertStringsToChars(modelName);
            end

            if isstring(varNames)
                varNames=varNames.cellstr;
            end


            [signalNames,...
            signals]=inSpec.prequalifyInputs(varNames,vars,modelName);

            switch inSpec.Mode
            case inSpec.ValidModes{1}

                Strategy=Simulink.iospecification.iostrategy.Index;
            case inSpec.ValidModes{2}

                Strategy=Simulink.iospecification.iostrategy.SignalName;
            case inSpec.ValidModes{3}

                Strategy=Simulink.iospecification.iostrategy.BlockName;
            case inSpec.ValidModes{4}

                Strategy=Simulink.iospecification.iostrategy.BlockPath;
            case inSpec.ValidModes{5}

                if~isempty(inSpec.CustomSpecFile)
                    Strategy=Simulink.iospecification.iostrategy.Custom(inSpec.CustomSpecFile);
                else
                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecNoCustomFile');
                end
            case inSpec.ValidModes{6}

                Strategy=Simulink.iospecification.iostrategy.Index;
            end


            try
                inSpec.InputMap=Strategy.createMap(modelName,signalNames,signals);
            catch ME
                throw(ME);
            end

            InputMappings=inSpec.InputMap;


            inSpec.LastModeUsed=inSpec.Mode;
            inSpec.LastVariableNamesUsed=varNames;
            inSpec.LastModelUsed=modelName;
            inSpec.LastCustomFileUsed=inSpec.CustomSpecFile;

            if~isempty(InputMappings)


                if inSpec.IsComposite



                    if isa(vars{1},'Simulink.SimulationData.Dataset')
                        inSpec.buildInputStringDataSet(modelName,varNames{1},vars{1});
                    else
                        inSpec.buidInputStringComposite(varNames{1});
                    end
                else



                    inSpec.buildInputString(modelName);
                end
            end



        end


        function[Inports,Enable,Trigger]=getInports(inSpec)


            if~isempty(inSpec.InputMap)



                inportIdx=strcmp({inSpec.InputMap(:).Type},'Inport');
                if~isempty(inportIdx)
                    Inports=inSpec.InputMap(inportIdx);
                end


                enableIdx=strcmp({inSpec.InputMap(:).Type},'EnablePort');
                if~isempty(enableIdx)
                    Enable=inSpec.InputMap(enableIdx);
                end


                triggerIdx=strcmp({inSpec.InputMap(:).Type},'TriggerPort');
                if~isempty(triggerIdx)
                    Trigger=inSpec.InputMap(triggerIdx);
                end

            else


                Inports=[];
                Enable=[];
                Trigger=[];

            end
        end


        function aSpec=getCustomMapping(inSpec)


            aSpec=Simulink.iospecification.InputSpecification('Custom');

            aSpec.InputMap=inSpec.InputMap;
        end


        function[inputID,inputMap]=getInput(inSpec,destinationProperty,destValue)
            inputID=[];

            validDestinationProperties={'BlockName','BlockPath',...
            'SignalName','PortNumber','SSID'};

            if~any(strcmpi(destinationProperty,validDestinationProperties))
                DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestProperty');
            end


            if isStringScalar(destValue)
                destValue=convertStringsToChars(destValue);
            end


            switch destinationProperty
            case validDestinationProperties{1}

                if~ischar(destValue)
                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestValBlockName');
                end

                for kInput=1:length(inSpec.InputMap)
                    if strcmp(...
                        inSpec.InputMap(kInput).Destination.BlockName,...
                        destValue)
                        inputID=inSpec.InputMap(kInput).DataSourceName;
                        inputMap=inSpec.InputMap(kInput);
                    end
                end
            case validDestinationProperties{2}

                if~ischar(destValue)

                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestValBlockPath');
                end

                for kInput=1:length(inSpec.InputMap)
                    if strcmp(...
                        inSpec.InputMap(kInput).Destination.BlockPath,destValue)
                        inputID=inSpec.InputMap(kInput).DataSourceName;
                        inputMap=inSpec.InputMap(kInput);
                    end
                end

            case validDestinationProperties{3}

                if~ischar(destValue)
                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestValSignalName');
                end

                for kInput=1:length(inSpec.InputMap)
                    if strcmp(...
                        inSpec.InputMap(kInput).Destination.SignalName,destValue)
                        inputID=inSpec.InputMap(kInput).DataSourceName;
                        inputMap=inSpec.InputMap(kInput);
                    end
                end

            case validDestinationProperties{4}

                if~isnumeric(destValue)
                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestValPortNum');
                end

                for kInput=1:length(inSpec.InputMap)
                    if inSpec.InputMap(kInput).Destination.PortNumber==destValue
                        inputID=inSpec.InputMap(kInput).DataSourceName;
                        inputMap=inSpec.InputMap(kInput);
                    end
                end
            case validDestinationProperties{5}

                if~ischar(destValue)
                    DAStudio.error('sl_iospecification:iostrategy:errorInSpecDestValSSID');
                end

                for kInput=1:length(inSpec.InputMap)
                    if strcmp(...
                        inSpec.InputMap(kInput).Destination.SSID,destValue)
                        inputID=inSpec.InputMap(kInput).DataSourceName;
                        inputMap=inSpec.InputMap(kInput);
                    end
                end
            end
        end


        function set.InputMap(inSpec,inMap)
            if~isa(inMap,'Simulink.iospecification.InputMap')&&~isempty(inMap)
                DAStudio.error('sl_iospecification:iostrategy:errorInSpecBadInputMap');
            end
            inSpec.InputMap=inMap;

        end


        function set.Verify(inSpec,toVerify)


            if isscalar(toVerify)&&(any(toVerify==[0,1,2])||islogical(toVerify))
                inSpec.Verify=toVerify;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorInSpecVerify');
            end
        end


        function set.AllowPartial(inSpec,toAllow)

            if isscalar(toAllow)&&(any(toAllow==[0,1])||islogical(toAllow))
                inSpec.AllowPartial=toAllow;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorAllow');
            end

        end


        function unMappedinputMaps=getUnmappedInportMaps(inSpec)

            unMappedinputMaps=[];
            NUM_MAP=length(inSpec.InputMap);

            cellUmapped=cell(1,NUM_MAP);

            FOUND_UNMAPPED=false;
            for kMap=1:NUM_MAP

                if isempty(inSpec.InputMap(kMap).DataSourceName)&&...
                    isnumeric(inSpec.InputMap(kMap).DataSourceName)

                    FOUND_UNMAPPED=true;
                    cellUmapped{kMap}=inSpec.InputMap(kMap);
                end

            end

            if FOUND_UNMAPPED
                cellUmapped(cellfun(@isempty,cellUmapped))=[];

                unMappedinputMaps=[cellUmapped{:}];
            end
        end
    end


    methods(Access=private)


        function[signalNames,signals]=prequalifyInputs(inSpec,varNames,vars,modelName)


            if length(vars)==1
                if isa(vars{1},'Simulink.SimulationData.Dataset')
                    inSpec.IsComposite=true;
                    el{vars{1}.getLength()}=[];
                    elName{vars{1}.getLength()}=[];
                    for k=1:vars{1}.getLength()
                        [el{k},elName{k}]=vars{1}.getElement(k);
                    end

                    signalNames=elName;
                    signals=el;
                elseif Simulink.sdi.internal.Util.isStructureWithTime(...
                    vars{1})||...
                    Simulink.sdi.internal.Util.isStructureWithoutTime(...
                    vars{1})
                    inSpec.IsComposite=true;
                    signals=vars;
                    signalNames{length(vars{1}.signals)}=[];
                    for kSig=1:length(vars{1}.signals)
                        signalNames{kSig}=varNames{1};
                    end




                    if~strcmp(inSpec.Mode,{'Index','PortOrder'})
                        DAStudio.error('sl_iospecification:iostrategy:errorInSpecMustBeIndex');
                    end
                elseif isDataArray(vars{1})&&~is2dDataArray(vars{1})


                    inportNames=Simulink.iospecification.InportProperty.getInportNames(modelName,false);
                    enableNames=Simulink.iospecification.InportProperty.getEnableNames(modelName);
                    triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(modelName);
                    portNames=[inportNames',enableNames',triggerNames'];


                    numPorts=length(portNames);


                    [~,N]=size(vars{1});
                    if N-1==numPorts
                        inSpec.IsComposite=true;

                        signals=vars;

                        signalNames{N-1}=[];
                        for kSig=2:N
                            signalNames{kSig-1}=...
                            [varNames{1},'(:,',num2str(kSig),')'];
                        end


                        if~strcmp(inSpec.Mode,{'Index','PortOrder'})
                            DAStudio.error('sl_iospecification:iostrategy:errorInSpecMustBeIndex');
                        end
                    else


                        signalNames=varNames;
                        signals=vars;

                    end
                elseif isTimeExpression(vars{1})
                    inSpec.IsComposite=true;
                    commaIndexes=strfind(vars{1},',');
                    signals=vars;
                    signalNames{length(commaIndexes)+1}=[];
                    for kSig=1:(length(commaIndexes)+1)
                        signalNames{kSig}=...
                        varNames{1};
                    end


                    if~strcmp(inSpec.Mode,'Index')
                        DAStudio.error('sl_iospecification:iostrategy:errorInSpecMustBeIndex');
                    end
                else
                    signalNames=varNames;
                    signals=vars;
                end
            else
                signalNames=varNames;
                signals=vars;
            end
        end


        function buildInputString(inSpec,modelName)

            [portH,portBlkPath,inportNames,portSigName,inportNumber]=...
            Simulink.iospecification.InportProperty.getInportProperties(modelName,false);
            inportNumber=cell2mat(inportNumber);


            [~,idx]=sort(inportNumber);

            inportNames=inportNames(idx);

            inSpec.InputString=[];

            for kInport=1:length(inportNames)


                [inputName,inMap]=inSpec.getInput('BlockName',inportNames{kInport});


                if~isempty(inputName)
                    appendStr=inputName;
                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;


                if kInport~=length(inportNames)
                    inSpec.InputString=[inSpec.InputString,appendStr,','];
                else

                    inSpec.InputString=[inSpec.InputString,appendStr];
                end
            end


            enableNames=Simulink.iospecification.InportProperty.getEnableNames(modelName);

            if~isempty(enableNames)
                [inputName,inMap]=inSpec.getInput('BlockName',enableNames{1});


                if~isempty(inputName)
                    appendStr=inputName;
                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;




                inSpec.InputString=...
                appendInputStr(inSpec,inSpec.InputString,appendStr);
            end

            triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(modelName);

            if~isempty(triggerNames)
                [inputName,inMap]=inSpec.getInput('BlockName',triggerNames{1});


                if~isempty(inputName)
                    appendStr=inputName;
                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;




                inSpec.InputString=...
                appendInputStr(inSpec,inSpec.InputString,appendStr);
            end

        end


        function buildInputStringDataSet(inSpec,modelName,containerName,theContainer)%#ok<INUSD>

            [portH,portBlkPath,inportNames,portSigName,inportNumber]=...
            Simulink.iospecification.InportProperty.getInportProperties(modelName,false);
            inportNumber=cell2mat(inportNumber);


            [~,idx]=sort(inportNumber);

            inportNames=inportNames(idx);

            inSpec.InputString=[];

            for kInport=1:length(inportNames)


                [inputName,inMap]=inSpec.getInput('BlockName',inportNames{kInport});

                [ACCESS_THRU_NAME,idxIntoDS]=getAccessThruElement(inSpec,...
                inputName,kInport,theContainer);


                if~isempty(inputName)||(isempty(inputName)&&ischar(inputName))

                    if strcmpi(inSpec.Mode,'index')||strcmpi(inSpec.Mode,'portorder')||~ACCESS_THRU_NAME
                        appendStr=[containerName,'.getElement(',num2str(idxIntoDS),')'];
                    else
                        appendStr=[containerName,'.getElement(''',inputName,''')'];
                    end

                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;


                if kInport~=length(inportNames)
                    inSpec.InputString=[inSpec.InputString,appendStr,','];
                else

                    inSpec.InputString=[inSpec.InputString,appendStr];
                end
            end

            enableNames=Simulink.iospecification.InportProperty.getEnableNames(modelName);

            if~isempty(enableNames)
                [inputName,inMap]=inSpec.getInput('BlockName',enableNames{1});
                [ACCESS_THRU_NAME,idxIntoDS]=getAccessThruElement(inSpec,...
                inputName,length(inportNames)+1,theContainer);


                if~isempty(inputName)||(isempty(inputName)&&ischar(inputName))
                    if strcmpi(inSpec.Mode,'index')||strcmpi(inSpec.Mode,'portorder')||~ACCESS_THRU_NAME
                        appendStr=[containerName,'.getElement(',num2str(idxIntoDS),')'];
                    else
                        appendStr=[containerName,'.getElement(''',inputName,''')'];
                    end
                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;



                inSpec.InputString=...
                appendInputStr(inSpec,inSpec.InputString,appendStr);
            end

            triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(modelName);

            if~isempty(triggerNames)
                [inputName,inMap]=inSpec.getInput('BlockName',triggerNames{1});
                [ACCESS_THRU_NAME,idxIntoDS]=getAccessThruElement(inSpec,...
                inputName,length(inportNames)+length(enableNames)+1,theContainer);


                if~isempty(inputName)||(isempty(inputName)&&ischar(inputName))
                    if strcmpi(inSpec.Mode,'index')||strcmpi(inSpec.Mode,'portorder')||~ACCESS_THRU_NAME
                        appendStr=[containerName,'.getElement(',num2str(idxIntoDS),')'];
                    else
                        appendStr=[containerName,'.getElement(''',inputName,''')'];
                    end
                else

                    appendStr='[]';
                end

                inMap.InputString=appendStr;




                inSpec.InputString=...
                appendInputStr(inSpec,inSpec.InputString,appendStr);

            end

        end


        function[ACCESS_THRU_NAME,idxIntoDS]=getAccessThruElement(inSpec,inputName,inportNumber,theContainer)
            idxIntoDS=inportNumber;
            ACCESS_THRU_NAME=true;

            if isStringScalar(inputName)
                inputName=convertStringsToChars(inputName);
            end

            if~isempty(inputName)||(isempty(inputName)&&ischar(inputName))
                try



                    x=eval(['theContainer','.getElement(''',inputName,''')']);

                    if isa(x,'Simulink.SimulationData.Dataset')
                        ACCESS_THRU_NAME=false;


                        if strcmpi(inSpec.Mode,'index')||strcmpi(inSpec.Mode,'portorder')
                            idxIntoDS=inportNumber;
                        elseif strcmpi(inSpec.Mode,'blockpath')

                            cellOfBlockPaths=cell(1,theContainer.numElements);


                            for kCell=1:theContainer.numElements

                                kEl=theContainer.get(kCell);


                                if ischar(kEl.BlockPath)
                                    cellOfBlockPaths{kCell}=kEl.BlockPath;
                                else

                                    if kEl.BlockPath.getLength>0

                                        blkPathCell=kEl.BlockPath.getBlock(1);

                                        if iscell(blkPathCell)
                                            blkPath=blkPathCell{1};
                                        else
                                            blkPath=blkPathCell;
                                        end
                                    else
                                        blkPath='';
                                    end

                                    cellOfBlockPaths{kCell}=blkPath;
                                end
                            end
                            theBlkName=[inSpec.LastModelUsed,'/',inputName];


                            DOES_MATCH=strcmp(cellOfBlockPaths,theBlkName);
                            idxIntoDS=find(DOES_MATCH==1,1,'first');


                        else



                            DOES_MATCH=strcmp(theContainer.getElementNames,inputName);
                            idxIntoDS=find(DOES_MATCH==1,1,'first');
                        end

                    end
                catch
                    ACCESS_THRU_NAME=false;
                    idxIntoDS=inportNumber;
                end
            end
        end


        function buidInputStringComposite(inSpec,containerName)
            inSpec.InputString=containerName;

            for kMap=1:length(inSpec.InputMap)
                inSpec.InputMap(kMap).InputString=containerName;
            end
        end


        function outStr=appendInputStr(~,strToAppend,appendThisStr)

            if~isempty(strToAppend)
                outStr=[strToAppend,',',appendThisStr];
            else
                outStr=[strToAppend,appendThisStr];
            end

        end
    end
end

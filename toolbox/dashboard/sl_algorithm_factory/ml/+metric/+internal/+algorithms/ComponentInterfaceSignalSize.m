classdef ComponentInterfaceSignalSize<metric.GraphMetric



    methods
        function obj=ComponentInterfaceSignalSize()
            obj.AlgorithmID='slcomp.ComponentInterfaceSignals';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64Vector);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,queryResult)
            sequences=queryResult.getSequences();
            firstSequence=sequences(1);
            almArtifact=firstSequence{1};

            inportSigSize=0;
            outportSigSize=0;

            warnForDataType=false;
            portsToWarn={};
            if~isempty(almArtifact{1}.Address)
                blkDiagram=almArtifact{1}.Address;
                ports=find_system(blkDiagram,'regexp','on','MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
                'SearchDepth',1,'BlockType','Inport|Outport');

                for i=1:numel(ports)
                    portBlkType=get_param(ports{i},'BlockType');
                    str=get_param(ports{i},'OutDataTypeStr');
                    if startsWith(str,'Bus:')
                        numberOfBuses=0;
                        try

                            numberOfBuses=getTotalBuses(str,ports{i});
                        catch

                            warnForDataType=true;
                            portsToWarn{end+1}=ports{i};
                            continue;
                        end
                        [inportSigSize,outportSigSize]=addToResult(inportSigSize,outportSigSize,portBlkType,numberOfBuses);
                    elseif startsWith(str,'Inherit: ')


                        obj=get_param(ports{i},'object');
                        ot=[];
                        if strcmp(get_param(ports{i},'BlockType'),'Inport')
                            ot=get_param(obj.PortHandles.Outport,'object');
                        else
                            ot=get_param(obj.PortHandles.Inport,'object');
                        end

                        if~isempty(ot)&&~isempty(ot.Line)&&ot.Line~=-1
                            lineObj=get_param(ot.Line,'object');
                            if lineObj.MustResolveToSignalObject
                                try
                                    r=slResolve(lineObj.Name,get_param(ports{i},'handle'));
                                    if~isempty(r)
                                        if startsWith(r.DataType,'Bus: ')
                                            numberOfBuses=0;
                                            try
                                                numberOfBuses=getTotalBuses(r.DataType,ports{i});
                                            catch

                                                warnForDataType=true;
                                                portsToWarn{end+1}=ports{i};
                                                continue;
                                            end
                                            [inportSigSize,outportSigSize]=addToResult(inportSigSize,outportSigSize,portBlkType,numberOfBuses);
                                        elseif startsWith(r.DataType,'Inherit: ')
                                            warnForDataType=true;
                                            portsToWarn{end+1}=ports{i};
                                            continue;
                                        else
                                            [inportSigSize,outportSigSize]=addToResult(inportSigSize,outportSigSize,portBlkType,1);
                                        end
                                    else
                                        warnForDataType=true;
                                        portsToWarn{end+1}=ports{i};
                                        continue;
                                    end
                                catch
                                    warnForDataType=true;
                                    portsToWarn{end+1}=ports{i};
                                    continue;
                                end
                            else
                                warnForDataType=true;
                                portsToWarn{end+1}=ports{i};
                                continue;
                            end
                        else
                            warnForDataType=true;
                            portsToWarn{end+1}=ports{i};
                            continue;
                        end
                    else

                        [inportSigSize,outportSigSize]=addToResult(inportSigSize,outportSigSize,portBlkType,1);
                    end
                end
            end

            res=resultFactory.createResult(this.ID,almArtifact{1});

            warnForAccessToBaseWorkspace=false;



            if numel(sequences)>1

                if strcmp(get_param(almArtifact{1}.Address,'HasAccessToBaseWorkspace'),'on')
                    this.notifyUserWarning(message('dashboard:maintainability:HasAccessToBaseWorkspace',...
                    almArtifact{1}.Address));
                    res.Value=[];
                    warnForAccessToBaseWorkspace=true;
                end


                for idx=2:numel(sequences)
                    if~isempty(sequences{idx}{1})
                        dictObj=Simulink.data.dictionary.open(sequences{idx}{1}.Address);
                        if dictObj.HasAccessToBaseWorkspace
                            this.notifyUserWarning(message('dashboard:maintainability:HasAccessToBaseWorkspaceForDict',...
                            sequences{idx}{1}.Address,almArtifact{1}.Address));
                            res.Value=[];
                            warnForAccessToBaseWorkspace=true;
                        end
                        close(dictObj);
                    end
                end
            end

            if warnForDataType
                for i=1:numel(portsToWarn)
                    this.notifyUserWarning(message('dashboard:maintainability:InheritDataType',...
                    portsToWarn{i},almArtifact{1}.Address));
                end
                res.Value=[];
            end

            if~warnForAccessToBaseWorkspace&&~warnForDataType
                resVal=[uint64(inportSigSize),uint64(outportSigSize)];
                res.Value=resVal;
            end
        end
    end
end

function busSize=getTotalBuses(str,port)
    busSize=0;
    dataType=extractAfter(str,"Bus: ");



    busObj=slResolve(dataType,get_param(port,'handle'));

    if isempty(busObj)||~isa(busObj,'Simulink.Bus')
        ME=MException('Maintainability:ComponentInterfaceSignalSize','bus object is empty');
        throw(ME);
    end

    for j=1:numel(busObj.Elements)

        if startsWith(busObj.Elements(j).DataType,'Bus: ')
            busSize=busSize+getTotalBuses(busObj.Elements(j).DataType,port);
        else
            busSize=busSize+1;
        end
    end
end

function[inportSigSize,outportSigSize]=addToResult(inportSigSize,outportSigSize,portBlkType,val)
    if strcmp(portBlkType,'Inport')
        inportSigSize=inportSigSize+val;
    else
        outportSigSize=outportSigSize+val;
    end
end

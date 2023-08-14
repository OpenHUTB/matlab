function coderDictionaryPortEmbeddedSignal(obj)





    if isR2015bOrEarlier(obj.ver)

        builtinSCs={'ExportedGlobal','ImportedExtern','ImportedExternPointer'};

        if slfeature('AddContextToDataObject')>0

            [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(obj.modelName);
            if isempty(mapping)||...
                ~any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))

                return;
            end



            for i=1:length(mapping.Inports)
                block=mapping.Inports(i).Block;
                if~ismember(mapping.Inports(i).getStorageClassName,builtinSCs)
                    continue;
                end

                blkSID=get_param(block,'SID');
                if~isempty(mapping.Inports(i).getIdentifier)

                    obj.appendRule(sprintf(...
                    '<Block<SID|%s><Port<PortNumber|1><RTWStorageClass:remove>>>',...
                    blkSID));
                    continue;
                end

                obj.appendRule(sprintf(...
                '<Block<SID|%s><Port<PortNumber|1><Object:remove>>>',...
                blkSID));
            end



            for i=1:length(mapping.Signals)
                ph=mapping.Signals(i).PortHandle;
                if~ismember(mapping.Signals(i).getStorageClassName,builtinSCs)
                    continue;
                end

                port=get_param(ph,'Object');
                assert(~isempty(port));

                blkSID=get_param(port.Parent,'SID');
                portNumber=port.PortNumber;

                if~isempty(mapping.Signals(i).getIdentifier)

                    obj.appendRule(sprintf(...
                    '<Block<SID|%s><Port<PortNumber|%d><RTWStorageClass:remove>>>',...
                    blkSID,portNumber));
                    continue;
                end

                obj.appendRule(sprintf(...
                '<Block<SID|%s><Port<PortNumber|%d><Object:remove>>>',...
                blkSID,portNumber));
            end
        else


            lines=find_system(obj.modelName,...
            'MatchFilter',@Simulink.match.allVariants,...
            'FindAll','on',...
            'LookUnderMasks','on',...
            'type','Line');

            if(isempty(lines))
                return;
            end

            for i=1:numel(lines)
                line=get_param(lines(i),'Object');
                port=line.getSourcePort;
                if isempty(port)
                    continue;
                end


                if(isempty(port.SignalObject)||~ismember(port.StorageClass,builtinSCs))
                    continue;
                end

                blkName=port.Parent;
                blkSID=get_param(blkName,'SID');
                portNumber=port.PortNumber;


                coderInfo=port.SignalObject.CoderInfo;
                if(~isempty(coderInfo.Alias)||coderInfo.Alignment~=-1)

                    obj.appendRule(sprintf(...
                    '<Block<SID|%s><Port<PortNumber|%d><RTWStorageClass:remove>>>',...
                    blkSID,portNumber));
                    continue;
                end


                obj.appendRule(sprintf(...
                '<Block<SID|%s><Port<PortNumber|%d><Object:remove>>>',...
                blkSID,portNumber));
            end
        end
    end
end



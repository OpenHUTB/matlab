function hList=loop_getLoopObjects(c)







    switch lower(getContextType(rptgen_sl.appdata_sl,c,false))
    case 'system'
        sigList=locSystemSignals(c.isSystemInternal,...
        c.isSystemOutgoing,...
        c.isSystemIncoming);
    case 'signal'
        sigList=get(rptgen_sl.appdata_sl,'CurrentSignal');
        if isequal(sigList,-1)
            sigList=[];
        end
    case 'block'
        sigList=locBlockSignals(c.isBlockOutgoing,...
        c.isBlockIncoming);
    case 'model'
        sigList=get(rptgen_sl.appdata_sl,'ReportedSignalList');
    case{'annotation','configset'}
        sigList=[];
    otherwise
        mList=find_system('SearchDepth',1,...
        'BlockDiagramType','model');
        mList=setdiff(mList,'temp_rptgen_model');



        sigList=find_system(mList,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'findall','on',...
        'type','port',...
        'porttype','outport');
    end

    hList=locSort(sigList,c.SortBy);



    function sigList=locSystemSignals(isInternal,isOutgoing,isIncoming)

        currSys=get(rptgen_sl.appdata_sl,'CurrentSystem');


        if isInternal
            internalList=find_system(currSys,...
            'findall','on',...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'LookUnderMasks','all',...
            'type','port',...
            'porttype','outport');

            if strcmp(get_param(currSys,'Type'),'block')
                sysPorts=get_param(currSys,'PortHandles');
                externalPorts=sysPorts.Outport(:);
            else
                externalPorts=[];
            end

            if isOutgoing&&isIncoming
                badList=externalPorts;
            elseif isOutgoing
                badList=[externalPorts;...
                LocPortSearch(currSys,'Inport')];
            elseif isIncoming
                badList=[externalPorts;...
                LocPortSearch(currSys,'Outport')];
            else
                badList=[externalPorts;...
                LocPortSearch(currSys,'Outport');...
                LocPortSearch(currSys,'Inport')];
            end
            sigList=setdiff(internalList,badList);
            sigList=sigList(:);
        else
            if isOutgoing
                outList=LocPortSearch(currSys,'Outport');
            else
                outList=[];
            end
            if isIncoming
                inList=LocPortSearch(currSys,'Inport');
            else
                inList=[];
            end
            sigList=[outList;inList];
        end


        function sigList=locBlockSignals(isOutgoing,isIncoming)

            currBlk=get(rptgen_sl.appdata_sl,'CurrentBlock');
            if isempty(currBlk)
                sigList=[];
                return;
            end

            try
                allPorts=get_param(currBlk,'PortHandles');
            catch ME %#ok
                allPorts=struct('Outport',[],'Inport',[]);
            end

            if isOutgoing
                sigList=allPorts.Outport(:);
            else
                sigList=[];
            end

            if isIncoming
                sigList=[sigList;LocInport2Outport(allPorts.Inport)];
            end



            function outP=LocInport2Outport(inP)

                if isempty(inP)
                    outP=[];
                    return;
                end


                inLine=rptgen.safeGet(inP,'Line','get_param');
                okIndex=find(cellfun('isclass',inLine,'double'));
                inLine=[inLine{okIndex}];

                outP=rptgen.safeGet(inLine,'SrcPortHandle','get_param');
                okIndex=find(cellfun('isclass',outP,'double'));
                outP=[outP{okIndex}]';



                function pList=LocPortSearch(currSys,blkType)

                    blkList=rptgen_sl.rgFindBlocks(currSys,1,{'BlockType',['\<',blkType,'\>']});

                    pList=[];

                    isOutport=strcmp(blkType,'Outport');

                    for i=1:length(blkList)
                        try
                            blkPorts=get_param(blkList{i},'PortHandles');
                        catch ME %#ok
                            blkPorts=struct('Outport',[],'Inport',[]);
                        end
                        if isOutport
                            ports=blkPorts.Inport;
                            for j=1:length(ports)
                                port=ports(j);




                                pList=[pList;LocInport2Outport(port)];%#ok
                            end
                        else
                            pList=[pList;blkPorts.Outport(:)];%#ok
                        end
                    end


                    function sigList=locSort(sigList,sortBy)

                        if isempty(sigList)
                            return;
                        end


                        switch sortBy
                        case 'systemalpha'
                            blkList=rptgen.safeGet(sigList,'Parent','get_param');
                            sysList=rptgen.safeGet(blkList,'Parent','get_param');
                            sysName=rptgen.safeGet(sysList,'Name','get_param');

                            okIdx=find(~strcmp(sysName,'N/A'));
                            sysName=sysName(okIdx);
                            sigList=sigList(okIdx);

                            [sysList,sysIndex]=sort(lower(sysName));
                            sigList=sigList(sysIndex);

                        case 'alphabetical-exclude-empty'
                            nameList=rptgen.safeGet(sigList,'Name','get_param');

                            okIdx=find(~strcmp(nameList,'N/A')&...
                            ~cellfun('isempty',nameList));
                            nameList=nameList(okIdx);
                            sigList=sigList(okIdx);

                            [nameList,nameIndex]=sort(lower(nameList));
                            sigList=sigList(nameIndex);
                        case 'alphabetical'
                            nameList=rptgen.safeGet(sigList,'Name','get_param');

                            okIdx=find(~strcmp(nameList,'N/A'));
                            nameList=nameList(okIdx);
                            sigList=sigList(okIdx);

                            [nameList,nameIndex]=sort(lower(nameList));
                            sigList=sigList(nameIndex);

                        case 'depth'
                            depthList=getPropValue(rptgen_sl.propsrc_sl_sig,...
                            sigList,...
                            'Depth');

                            okEntries=find(cellfun('isclass',depthList,'double'));
                            depthList=[depthList{okEntries}]';
                            sigList=sigList(okEntries);

                            [depthList,depthIndex]=sort(depthList);
                            sigList=sigList(depthIndex);
                        otherwise

                        end


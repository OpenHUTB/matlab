classdef(Hidden)Finder<handle




    methods(Static)

        function foundSysH=find(searchSysH,category,varargin)


            import autosar.composition.sl2mm.ConnectorBuilder


            p=inputParser;
            p.addRequired('searchSysH',@(x)autosar.arch.Utils.isBlockDiagram(x)||...
            autosar.arch.Utils.isSubSystem(x)||...
            autosar.arch.Utils.isModelBlock(x));
            p.addRequired('category',@(x)any(strcmp(x,{'Component',...
            'Composition','Port',...
            'Connector','Adapter'})));
            p.addParameter('AllLevels',false,...
            @(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.addParameter('Name','',@(x)ischar(x)||isStringScalar(x));
            p.parse(searchSysH,category,varargin{:});

            findSysArgs={};
            if~p.Results.AllLevels
                findSysArgs={'SearchDepth',1};
            end

            searchSysH=get_param(searchSysH,'Handle');

            foundSysH=[];
            switch(category)
            case 'Component'
                compBlkH=find_system(searchSysH,findSysArgs{:},...
                'RegExp','on','BlockType','SubSystem|ModelReference');
                if~p.Results.AllLevels

                    compBlkH=setdiff(compBlkH,searchSysH);
                end
                foundSysH=compBlkH(arrayfun(@(x)autosar.composition.Utils.isComponentBlock(x),compBlkH));
            case 'Composition'
                compBlkH=find_system(searchSysH,findSysArgs{:},'BlockType','SubSystem');
                if~p.Results.AllLevels

                    compBlkH=setdiff(compBlkH,searchSysH);
                end
                foundSysH=compBlkH(arrayfun(@(x)autosar.composition.Utils.isCompositionBlock(x),compBlkH));
            case 'Adapter'
                foundSysH=find_system(searchSysH,findSysArgs{:},'BlockType','SubSystem','SimulinkSubDomain','ArchitectureAdapter');
                if~p.Results.AllLevels

                    foundSysH=setdiff(foundSysH,searchSysH);
                end
            case 'Port'
                if p.Results.AllLevels



                    searchAllSysH=autosar.arch.Finder.findAllSystemsToSearch(searchSysH);


                    args=varargin;
                    allLevelsIdx=find(strcmpi(args,'AllLevels'));
                    args(allLevelsIdx:allLevelsIdx+1)=[];

                    foundSysH=[];
                    for sysIdx=1:length(searchAllSysH)
                        foundSysH=[foundSysH;autosar.arch.Finder.find(...
                        searchAllSysH(sysIdx),category,args{:})];%#ok<AGROW>
                    end
                else
                    if autosar.arch.Utils.isBlock(searchSysH)
                        ph=get_param(searchSysH,'PortHandles');
                        inportHandles=autosar.arch.Utils.getSLInportHandles(searchSysH);
                        foundSysH=[inportHandles,ph.Outport];
                    else

                        assert(autosar.arch.Utils.isBlockDiagram(searchSysH),'unexpected system type passed to find');
                        foundSysH=[autosar.composition.Utils.findCompositeInports(searchSysH);...
                        autosar.composition.Utils.findCompositeOutports(searchSysH)];

                        if length(foundSysH)>1




                            portNames=get_param(foundSysH,'PortName');
                            [~,uniqueIdx]=unique(portNames,'stable');
                            foundSysH=foundSysH(uniqueIdx);
                        end
                    end
                end
            case 'Connector'
                if p.Results.AllLevels



                    searchAllSysH=autosar.arch.Finder.findAllSystemsToSearch(searchSysH);


                    args=varargin;
                    allLevelsIdx=find(strcmpi(args,'AllLevels'));
                    args(allLevelsIdx:allLevelsIdx+1)=[];

                    foundSysH=[];
                    for sysIdx=1:length(searchAllSysH)
                        foundSysH=[foundSysH;autosar.arch.Finder.find(...
                        searchAllSysH(sysIdx),category,args{:})];%#ok<AGROW>
                    end
                else


                    compBlocks=autosar.composition.Utils.findCompBlocks(getfullname(searchSysH));
                    compositeInports=autosar.composition.Utils.findCompositeInports(getfullname(searchSysH));
                    adapterBlocks=autosar.composition.Utils.findAdapterBlocks(getfullname(searchSysH));

                    slSignalLines=[];
                    for blkIdx=1:length(compBlocks)
                        slSignalLines=[slSignalLines
                        ConnectorBuilder.findCompositionSignalLinesFromSrcBlock(compBlocks{blkIdx},...
                        TraverseThroughAdapterBlocks=false)];%#ok<AGROW>
                    end


                    for blkIdx=1:length(compositeInports)
                        slSignalLines=[slSignalLines
                        ConnectorBuilder.findCompositionSignalLinesFromSrcBlock(compositeInports{blkIdx},...
                        TraverseThroughAdapterBlocks=false)];%#ok<AGROW>
                    end

                    for blkIdx=1:length(adapterBlocks)
                        slSignalLines=[slSignalLines
                        ConnectorBuilder.findCompositionSignalLinesFromSrcBlock(adapterBlocks{blkIdx},...
                        TraverseThroughAdapterBlocks=false)];%#ok<AGROW>
                    end

                    for i=1:length(slSignalLines)
                        lineH=slSignalLines(i).getLineHandle();

                        if autosar.arch.Connector.isLineValidConnector(lineH)
                            foundSysH=[foundSysH,lineH];%#ok<AGROW>
                        end
                    end
                end
            end



            foundSysH=unique(foundSysH,'stable');



            if~isempty(p.Results.Name)
                if strcmp(category,'Connector')



                    DAStudio.error('autosarstandard:api:ConstraintNameNotSupportedForConnector');
                else
                    foundSysH=autosar.arch.Finder.filterBasedOnName(foundSysH,...
                    p.Results.Name,category);
                end
            end


            foundSysH=reshape(foundSysH,[length(foundSysH),1]);
        end
    end

    methods(Static,Access=private)
        function searchAllSysH=findAllSystemsToSearch(searchSysH)
            searchAllSysH=[...
            autosar.arch.Finder.find(searchSysH,'Component','AllLevels',true);...
            autosar.arch.Finder.find(searchSysH,'Composition','AllLevels',true)];


            searchAllSysH=[searchAllSysH;searchSysH];

            searchAllSysH=unique(searchAllSysH,'stable');
        end

        function vectorSysH_filtered=filterBasedOnName(vectorSysH,matchName,category)
            vectorSysH_filtered=[];
            for i=1:length(vectorSysH)
                item=vectorSysH(i);
                if strcmp(category,'Port')
                    if autosar.arch.Utils.isPort(item)
                        slBlk=autosar.arch.Utils.findSLPortBlock(item);
                        slBlk=slBlk{1};
                        itemName=get_param(slBlk,'PortName');
                    else
                        itemName=get_param(item,'PortName');
                    end
                else
                    itemName=get_param(item,'Name');
                end
                if strcmp(itemName,matchName)
                    vectorSysH_filtered=[vectorSysH_filtered;item];%#ok<AGROW>
                end
            end
        end
    end
end



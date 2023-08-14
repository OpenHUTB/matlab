function[fromBlkMap,filterInfo]=utilRouteSPSInputs(hinterfaceSystem,stateSpaceInputMap,networkNum,...
    initialInputs,HDLAlgorithmDataType,solverType,isLinearize)










    fromBlkMap=containers.Map();
    interfaceSystem=getfullname(hinterfaceSystem);


    fromBlkPos=[100,100,150,125];


    hspsBlks={};
    spsBlks={};
    if(~isempty(stateSpaceInputMap))
        spsBlks=stateSpaceInputMap(:,1);
        hspsBlks=stateSpaceInputMap(:,3);
    end

    topModel=bdroot(interfaceSystem);


    filterInfo.hdlSubSystemBlocks=[];
    for ii=1:numel(spsBlks)

        spsBlkii=spsBlks{ii};
        spsBlkiiNew=hspsBlks{ii};


        if(~solverType&&~isLinearize)
            filterDerivative=get_param(spsBlkiiNew,'FilteringAndDerivatives');

            if(strcmp(filterDerivative,'filter'))
                filterInfo=utilInputFilterDraw(spsBlkiiNew,interfaceSystem,...
                HDLAlgorithmDataType,initialInputs(ii),filterInfo,ii);
            else
                filterInfo.block(ii).hasInputFilter=0;
            end
        end


        [~,remain]=strtok(spsBlkii,'/');


        spsBlkii_1=[topModel,remain];


        spsBlkii_1Pos=get_param(spsBlkii_1,'Position');

        gotoBlkPos=[spsBlkii_1Pos(1),spsBlkii_1Pos(4),spsBlkii_1Pos(3),spsBlkii_1Pos(4)+20];


        mapVal=stateSpaceInputMap{ii,2};
        inputIdx=num2str(mapVal{1});
        gotoBlkTag=strcat('gotoSSIn',inputIdx,'_rsvd','_',num2str(networkNum));
        hgotoBlk=add_block('hdlsllib/Signal Routing/Goto',strcat(spsBlkii_1,'_SSIn',inputIdx),...
        'MakeNameUnique','on',...
        'Position',gotoBlkPos,...
        'GotoTag',gotoBlkTag,...
        'ShowName','off',...
        'TagVisibility','global');


        hspsBlkii_1Line=get_param(spsBlkii_1,'LineHandles');
        hspsBlkii_1Inport=hspsBlkii_1Line.Inport;

        assert(numel(hspsBlkii_1Inport)==1);

        hspsBlkii_1SrcPort=get_param(hspsBlkii_1Inport,'SrcPortHandle');

        hgotoBlkInport=get_param(hgotoBlk,'PortHandles');
        hgotoBlkInport=hgotoBlkInport.Inport;


        add_line(get_param(hgotoBlk,'Parent'),...
        hspsBlkii_1SrcPort,hgotoBlkInport,...
        'autorouting','on');


        hfromBlk=add_block('hdlsllib/Signal Routing/From',strcat(interfaceSystem,'/',get_param(spsBlkii_1,'Name')),...
        'MakeNameUnique','on',...
        'Position',fromBlkPos,...
        'GotoTag',gotoBlkTag,...
        'ShowName','off');

        fromBlkPos=fromBlkPos+[0,40,0,40];

        fromBlkMap(getfullname(hfromBlk))=inputIdx;
    end
end



function[frominMap,filterInfo]=utilRouteSPSInputsV2(hinterfaceSystem,stateSpaceInputMap,...
    origSubsystem,initialInputs,HDLAlgorithmDataType,solverType,isLinearize)









    frominMap=containers.Map();

    interfaceSystem=getfullname(hinterfaceSystem);


    inPortPos=[100,100,130,114];


    hspsBlks={};
    if~isempty(stateSpaceInputMap)
        hspsBlks=stateSpaceInputMap(:,3);
    end

    origInport=get_param(origSubsystem,'PortHandles').Inport;





    filterInfo.hdlSubSystemBlocks=[];
    for ii=1:numel(hspsBlks)
        spsBlkii=hspsBlks{ii};




        if(~solverType&&~isLinearize)
            filterDerivative=get_param(spsBlkii,'FilteringAndDerivatives');

            if(strcmp(filterDerivative,'filter'))
                filterInfo=utilInputFilterDraw(spsBlkii,interfaceSystem,...
                HDLAlgorithmDataType,initialInputs(ii),filterInfo,ii);
            else
                filterInfo.block(ii).hasInputFilter=0;
            end
        end


        mapVal=stateSpaceInputMap{ii,2};
        inputIdx=num2str(mapVal{1});


        hinBlk=add_block('simulink/Sources/In1',strcat(interfaceSystem,'/',get_param(spsBlkii,'Name')),...
        'MakeNameUnique','on',...
        'Position',inPortPos);


        inPortPos=inPortPos+[0,40,0,40];


        frominMap(getfullname(hinBlk))=inputIdx;







        hspsBlkii_1Line=get_param(spsBlkii,'LineHandles');
        hspsBlkii_1Inport=hspsBlkii_1Line.Inport;


        assert(numel(hspsBlkii_1Inport)==1);



        hspsBlkii_1BlockPort=get_param(hspsBlkii_1Inport,'SrcBlockHandle');


        portNum=get_param(hspsBlkii_1BlockPort,'Port');


        origSubsysToSrcLine=get_param(origInport(str2double(portNum)),'Line');
        origSrc=get_param(origSubsysToSrcLine,'SrcPortHandle');



        add_line(get_param(hinterfaceSystem,'Parent'),...
        origSrc,get_param(hinterfaceSystem,'PortHandles').Inport(ii),...
        'autorouting','on');

    end


end



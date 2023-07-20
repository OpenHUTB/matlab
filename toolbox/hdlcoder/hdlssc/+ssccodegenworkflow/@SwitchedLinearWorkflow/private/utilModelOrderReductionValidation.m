function utilModelOrderReductionValidation(obj)





    linearModelvld=utilGetValidIdentifier(strcat('vln',obj.linearModelPrefix,obj.SimscapeModel));
    utilSaveAsModel(obj.SimscapeModel,linearModelvld);
    obj.linearModelVldn=linearModelvld;

    hlinVldModel=get_param(linearModelvld,'Handle');
    hlinVldBlks=find_system(hlinVldModel,'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'IncludeCommented','on');

    hlinVldAnnotations=find_system(hlinVldModel,'SearchDepth',1,...
    'FindAll','on',...
    'Type','Annotation');

    hlinVldBlks=setdiff(hlinVldBlks,hlinVldModel);
    hlinVldBlks=union(hlinVldBlks,hlinVldAnnotations);





    Simulink.BlockDiagram.createSubsystem(hlinVldBlks);
    sscSystem=find_system(linearModelvld,'SearchDepth',1,'Selected','on');
    sscSystem=sscSystem{1};
    sscSystemPos=get_param(sscSystem,'Position');
    linSystemPos=[sscSystemPos(1),sscSystemPos(4)+50,sscSystemPos(3),2*sscSystemPos(4)-sscSystemPos(2)+50];
    vldSystemPos=[sscSystemPos(3)+50,sscSystemPos(2),2*sscSystemPos(3)-sscSystemPos(1)+50,sscSystemPos(4)];

    hLinearizedSubystem=add_block(sscSystem,strcat(linearModelvld,'/Linearized_Model'),'Position',linSystemPos);



    protectGlobalGotoTags(sscSystem)




    hVldSubsystem=utilAddSubsystem(linearModelvld,'Validation Subsystem',vldSystemPos,'w');
    validationSystem=getfullname(hVldSubsystem);

    validationTolerance=obj.modelOrderReductionValTol;

    pssConverters={};
    for i=1:numel(obj.SpsPssConverterBlks)
        pssConverters=[pssConverters,setdiff(obj.SpsPssConverterBlks{i},obj.spsBlks{i})];%#okgrow
    end
    subsystemPrefix={get_param(hLinearizedSubystem,'Name'),get_param(sscSystem,'Name')};
    hfromBlk=cell(1,2);
    fromBlkPos=[100,100,150,125];
    fromBlkPosMod=[0,50];
    for i=1:size(pssConverters,2)
        [~,remain]=strtok(pssConverters{i},'/');


        for j=1:2
            pssBlkii_1=[linearModelvld,'/',subsystemPrefix{j},remain];



            pssBlkii_1Pos=get_param(pssBlkii_1,'Position');

            gotoBlkPos=[pssBlkii_1Pos(1),pssBlkii_1Pos(4),pssBlkii_1Pos(3),pssBlkii_1Pos(4)+20];


            gotoBlkTag=strcat('Vld',subsystemPrefix{j},int2str(i));
            hgotoBlk=add_block('hdlsllib/Signal Routing/Goto',strcat(pssBlkii_1,gotoBlkTag),...
            'MakeNameUnique','on',...
            'Position',gotoBlkPos,...
            'GotoTag',gotoBlkTag,...
            'ShowName','off',...
            'TagVisibility','global');


            hpssBlkii_1Line=get_param(pssBlkii_1,'LineHandles');
            hspsBlkii_1Outport=hpssBlkii_1Line.Outport;

            hpssBlkii_1SrcPort=get_param(hspsBlkii_1Outport,'SrcPortHandle');

            hgotoBlkInport=get_param(hgotoBlk,'PortHandles');
            hgotoBlkInport=hgotoBlkInport.Inport;


            add_line(get_param(hgotoBlk,'Parent'),...
            hpssBlkii_1SrcPort,hgotoBlkInport,...
            'autorouting','on');


            blkName=strrep(get_param(pssBlkii_1,'Name'),'/','//');


            hfromBlk{j}=add_block('hdlsllib/Signal Routing/From',strcat(validationSystem,'/',blkName),...
            'MakeNameUnique','on',...
            'Position',fromBlkPos+[0,fromBlkPosMod(j),0,fromBlkPosMod(j)],...
            'GotoTag',gotoBlkTag,...
            'ShowName','off');
        end


        fromBlkName1=strrep(get_param(hfromBlk{1},'Name'),'/','//');
        fromBlkName2=strrep(get_param(hfromBlk{2},'Name'),'/','//');
        hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(validationSystem,'/Add',num2str(i)),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+200,fromBlkPos(2),fromBlkPos(3)+200,fromBlkPos(4)+25],...
        'Inputs','-+',...
        'ShowName','off');
        add_line(validationSystem,strcat(fromBlkName1,'/1'),strcat(get_param(hsumBlk,'Name'),'/1'),...
        'autorouting','on');
        add_line(validationSystem,strcat(fromBlkName2,'/1'),strcat(get_param(hsumBlk,'Name'),'/2'),...
        'autorouting','on');



        hstaticRangeCheckBlk=add_block(sprintf('hdlsllib/Model Verification/Check \nStatic Range'),strcat(validationSystem,'/Check Static Range',num2str(i)),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+400,fromBlkPos(2),fromBlkPos(3)+400,fromBlkPos(4)],...
        'ShowName','off',...
        'max',num2str(validationTolerance),...
        'min',num2str(-validationTolerance),...
        'stopWhenAssertionFail','off');


        add_line(validationSystem,strcat(get_param(hsumBlk,'Name'),'/1'),strcat(get_param(hstaticRangeCheckBlk,'Name'),'/1'),...
        'autorouting','on');

        fromBlkPos=fromBlkPos+[0,100,0,100];
    end
    Simulink.BlockDiagram.expandSubsystem(hLinearizedSubystem)


end
function protectGlobalGotoTags(sscSystem)



    gotoBlks=find_system(sscSystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Goto');
    fromBlks=find_system(sscSystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','From');


    tagFromMap=containers.Map;
    for i=1:numel(fromBlks)
        gotoTag=get_param(fromBlks{i},'gototag');
        if~isKey(tagFromMap,gotoTag)
            tagFromMap(gotoTag)=fromBlks(i);
        else
            tagFromMap(gotoTag)=[tagFromMap(gotoTag),fromBlks(i)];
        end
    end


    for i=1:numel(gotoBlks)
        if strcmp(get_param(gotoBlks{i},'TagVisibility'),'global')
            gotoTag=get_param(gotoBlks{i},'GotoTag');
            newGotoTag=strcat(gotoTag,'_vldLineariztion');
            set_param(gotoBlks{i},'GotoTag',newGotoTag);
            corespondingFromBlks=[];
            if isKey(tagFromMap,gotoTag)
                corespondingFromBlks=tagFromMap(gotoTag);
            end
            for ii=1:numel(corespondingFromBlks)
                set_param(corespondingFromBlks{ii},'GotoTag',newGotoTag);
            end
        end

    end
end


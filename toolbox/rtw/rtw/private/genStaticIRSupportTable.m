function result=genStaticIRSupportTable(libName,searchDepth,fileName)











    open_system(libName);
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok<NASGU>


    blks=[];%#ok  
    if searchDepth==-1
        blks=find_system(libName,'FollowLinks','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','functional');
    else
        blks=find_system(libName,'FollowLinks','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','functional','SearchDepth',searchDepth);
    end
    result=[];
    for i=1:length(blks)
        blk=blks{i};
        if strcmp(get_param(blk,'Type'),'block_diagram')
            continue;
        end
        blkType=get_param(blk,'BlockType');
        maskType=get_param(blk,'MaskType');
        skipBlk=(strcmp(blkType,'SubSystem')==1)&&(isempty(maskType));
        if~skipBlk
            result(end+1).Type=locGetBlkType(blk);%#ok
            [result(end).IRSupport,result(end).ContributingBlk]=...
            locGetIRSupportInfo(blk,blkType);%#ok
            result(end).fullPath=getfullname(blk);%#ok
        end
    end
    result=locReorgData(result);
    locWriteToFile(fileName,result);

    function locWriteToFile(fileName,result)
        fId=fopen(fileName,'w');
        fprintf(fId,'%s\t%s\t%s\t%s\t%s\t%s\n',...
        'Group',...
        'Block Type',...
        'Block Name',...
        'IRSupport',...
        'First Gating Block for Mask SS',...
        'Type of Gating Block');
        for i=1:length(result)
            blks=result(i).block;
            for j=1:length(blks)
                fprintf(fId,'%s\t%s\t%s\t%s\t%s\t%s\n',...
                locSanitize(result(i).Category),...
                blks(j).Type,...
                locSanitize(locGetName(blks(j).fullPath)),...
                blks(j).IRSupport,...
                locSanitize(blks(j).ContributingBlk.Name),...
                locSanitize(blks(j).ContributingBlk.Type));
            end
        end
        fclose(fId);

        function name=locGetName(fullpath)
            seps=findstr(fullpath,'/');
            name=fullpath(seps(end)+1:end);

            function strout=locSanitize(strin)
                strout=strrep(strin,sprintf('\n'),' ');

                function output=locReorgData(data)

                    output=[];
                    for i=1:length(data)
                        output=locCategorizeData(output,data(i));
                    end


                    function ioData=locCategorizeData(ioData,data)
                        if isempty(ioData)
                            ioData.Category=locGetCategory(data.fullPath);
                            ioData.block=data;
                        else
                            category=locGetCategory(data.fullPath);
                            index=find(strcmp(category,{ioData(:).Category}));
                            if~isempty(index)
                                ioData(index).block(end+1)=data;
                            else
                                ioData(end+1).Category=category;
                                ioData(end).block=data;
                            end
                        end

                        function category=locGetCategory(path)
                            seps=findstr(path,'/');
                            category=path(seps(1)+1:seps(end)-1);

                            function[irsupport,contributingBlk]=locGetIRSupportInfo(blk,blkType)
                                contributingBlk.Name='';
                                contributingBlk.Type='';
                                if strcmp(blkType,'SubSystem')==1
                                    [irsupport,contributingBlk]=locGetSSIRSupportInfo(blk);
                                else
                                    irsupport=locGetBlockIRSupport(blk);
                                end

                                function[irsupport,contributingBlk]=locGetSSIRSupportInfo(blk)
                                    irsupport='Always';
                                    contributingBlk.Name='';
                                    contributingBlk.Type='';


                                    blks=find_system(blk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all');
                                    for i=1:length(blks)
                                        locBlk=blks{i};
                                        newIrsupport=locIRSupportLogic(irsupport,locGetBlockIRSupport(locBlk));
                                        if strcmp(newIrsupport,irsupport)==0
                                            irsupport=newIrsupport;
                                            contributingBlk.Name=strrep(getfullname(locBlk),getfullname(blk),'.');
                                            contributingBlk.Type=locGetBlkType(locBlk);
                                        end
                                    end

                                    function bType=locGetBlkType(blk)
                                        bType=get_param(blk,'BlockType');
                                        switch bType
                                        case 'SubSystem'
                                            maskType=get_param(blk,'MaskType');
                                            if~isempty(maskType)
                                                bType=maskType;
                                            end

                                        case 'S-Function'
                                            maskType=get_param(blk,'MaskType');
                                            if~isempty(maskType)
                                                bType=maskType;
                                            else
                                                bType=[bType,'/',get_param(blk,'FunctionName')];
                                            end
                                        end

                                        function irsupport=locGetBlockIRSupport(blk)
                                            root=get_param(0,'Object');
                                            bType=get_param(blk,'BlockType');
                                            irsupport=root.getBlkTypeCGIRSupportLevel(bType);
                                            if strcmp(bType,'S-Function')
                                                sfcn=get_param(blk,'FunctionName');
                                                if strcmp(sfcn,'sfix_dtprop')
                                                    irsupport='Always';
                                                else
                                                    tmpsys=new_system('','Model');
                                                    try
                                                        tmpsysName=get_param(tmpsys,'Name');
                                                        tmpBName=[tmpsysName,'/b'];
                                                        add_block(getfullname(blk),tmpBName);
                                                        bObj=get_param(tmpBName,'Object');
                                                        irsupport=bObj.getSfcnTypeCGIRSupportLevel();
                                                        close_system(tmpsys,0);
                                                    catch
                                                        close_system(tmpsys,0);
                                                    end
                                                end
                                            end

                                            function irsupport=locIRSupportLogic(input1,input2)
                                                if strcmp(input1,'Never')==1||strcmp(input2,'Never')==1
                                                    irsupport='Never';
                                                elseif strcmp(input1,'Conditional')==1||strcmp(input2,'Conditional')==1
                                                    irsupport='Conditional';
                                                elseif strcmp(input1,'Always_Except_GenericRestriction')==1||...
                                                    strcmp(input2,'Always_Except_GenericRestriction')==1
                                                    irsupport='Always_Except_GenericRestriction';
                                                else
                                                    irsupport='Always';
                                                end






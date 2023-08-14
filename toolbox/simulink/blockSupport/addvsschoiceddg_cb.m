function newBlk=addvsschoiceddg_cb(blk,choiceType,nameHint)








    try
        choiceIsSubsystem=strcmp(choiceType,'SubSystem');



        if nargin<3
            newBlkName='Subsystem';
            if~choiceIsSubsystem
                assert(strcmp(choiceType,'ModelReference'));
                newBlkName='Model';
            end
        else
            newBlkName=nameHint;
        end

        choice_subsys=find_system(blk,'SearchDepth',1,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem');
        choice_mdlref=find_system(blk,'SearchDepth',1,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.allVariants,'BlockType','ModelReference');

        choices=[choice_subsys(2:end);choice_mdlref];
        num=length(choices);
        ins=find_system(blk,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','on','BlockType','Inport');
        outs=find_system(blk,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','on','BlockType','Outport');
        pmios=find_system(blk,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','on','BlockType','PMIOPort');










        ymax=0;
        for ii=1:num
            temp=get_param(choices(ii),'Position');
            if iscell(temp)
                temp=temp{1};
            end
            if temp(4)>ymax
                ymax=temp(4);
                x=temp(1);
            end
        end

        xinr=80;
        y=ymax+70;
        xoutl=0;



        if(num==0)
            if~isempty(ins)&&~isempty(outs)
                posin=get_param(ins(end),'Position');
                posout=get_param(outs(end),'Position');
                if iscell(posin)
                    posin=posin{1};
                end
                if iscell(posout)
                    posout=posout{1};
                end
                xinr=posin(3);
                xoutl=posout(1);
                x=xinr+(xoutl-xinr)/2-15;
            elseif~isempty(ins)
                posin=get_param(ins(end),'Position');
                if iscell(posin)
                    posin=posin{1};
                end
                x=posin(3)+60;
            elseif~isempty(outs)
                posout=get_param(outs(end),'Position');
                if iscell(posout)
                    posout=posout{1};
                end
                x=max(posout(1)-110,50);
            else
                pos=get_param(blk,'Position');
                if iscell(pos)
                    pos=pos{1};
                end
                xmin=max(pos(1),140);
                x=xmin+floor((pos(3)-pos(1))/2);
            end
        end


        newVCName=createDummyVariantControl(blk);



        newBlk=add_block(['built-in/',choiceType],[getfullname(blk),'/',newBlkName],...
        'MakeNameUnique','on','Position',[x,y,x+50,y+50]);

        if choiceIsSubsystem
            name=getfullname(newBlk);
            newPos=get_param(newBlk,'Position');
            if iscell(newPos)
                newPos=newPos{1};
            end



            isArchitecture=strcmpi(get_param(blk,'SimulinkSubDomain'),'architecture')||...
            strcmpi(get_param(blk,'SimulinkSubDomain'),'softwarearchitecture');


            for inIter=1:length(ins)
                blkName=strrep(get_param(ins{inIter},'Name'),'/','//');
                position=[xinr-30,50*inIter,xinr,50*inIter+15];

                if isArchitecture
                    add_block('simulink/Ports & Subsystems/In Bus Element',[name,'/',blkName,'_elem'],...
                    'CreateNewPort','on','Position',position,'PortName',blkName,'Element','');
                else
                    add_block('built-in/Inport',[name,'/',blkName],...
                    'Position',position);
                end
            end


            if(xoutl==0)
                xoutl=newPos(3)+60;
            end
            for outIter=1:length(outs)
                blkName=strrep(get_param(outs{outIter},'Name'),'/','//');
                position=[xoutl,50*outIter,xoutl+30,50*outIter+15];

                if isArchitecture
                    add_block('simulink/Ports & Subsystems/Out Bus Element',[name,'/',blkName,'_elem'],...
                    'CreateNewPort','on','Position',position,'PortName',blkName,'Element','');
                else
                    add_block('built-in/Outport',[name,'/',blkName],...
                    'Position',position);
                end
            end




            if isempty(inIter)
                inIter=0;
            end
            if isempty(outIter)
                outIter=0;
            end



            for pmioIter=1:length(pmios)


                portSide=get_param(pmios{pmioIter},'Side');
                portNum=get_param(pmios{pmioIter},'Port');
                blkName=strrep(get_param(pmios{pmioIter},'Name'),'/','//');
                if strcmp(portSide,'Left')
                    inIter=inIter+1;
                    add_block('built-in/PMIOPort',[name,'/',blkName],...
                    'Position',[xinr-30,50*inIter,xinr,50*inIter+15],...
                    'Side',portSide,...
                    'Port',portNum);
                else


                    outIter=outIter+1;
                    add_block('built-in/PMIOPort',[name,'/',blkName],...
                    'Position',[xoutl,50*outIter,xoutl+30,50*outIter+15],...
                    'Side',portSide,...
                    'Port',portNum,...
                    'BlockMirror','on');
                end
            end




            vssBlock=get_param(newBlk,'Parent');
            gpcStatus=get_param(vssBlock,'GeneratePreprocessorConditionals');
            set_param(newBlk,'TreatAsAtomicUnit',gpcStatus);
        end


        hilite_system(newBlk,'none');
        set_param(newBlk,'Selected','on');
        set_param(newBlk,'VariantControl',newVCName);

    catch me
        dp=DAStudio.DialogProvider;
        dp.errordlg(me.message,...
        'Error',true);
    end



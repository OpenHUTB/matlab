function hilite_data=rateHighlight(this,msg,advancedConstantDisplay)



    if nargin==2


        advancedConstantDisplay=false;
    end

    if(isequal(msg{2},'M'))
        rateIdx=[];
    else
        rateIdx=str2double(msg{2});
    end

    modelName=msg{3};

    msgLen=length(msg);

    highlighSource=false;
    if(isequal(msgLen,4)&&isequal(msg{4},'source'))
        highlighSource=true;
    end

    if(highlighSource)
        hilite_data.type='source';
    else
        hilite_data.type='all';
    end


    hilite_data.modelName=modelName;

    warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
    legendData=get_param(modelName,'SampleTimes');
    warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');
    if(isempty(legendData))
        w=warning('query','backtrace');
        warning('off','backtrace');
        warning(DAStudio.message('Simulink:Engine:CompileNeededForSampleTimes',modelName));
        warning('backtrace',w.state);
        hilite_data=[];
        return;
    end

    findOpts=Simulink.FindOptions('LookUnderMasks','all','FollowLinks',true);
    sys=Simulink.findBlocks(modelName,findOpts);

    for count=1:length(legendData)
        if(isequal(legendData(count).TID,rateIdx))
            hilite_data.colorRGB=legendData(count).ColorRGBValue;

            if(highlighSource)
                hilite_data.Annotation=' ';
            else
                hilite_data.Annotation={legendData(count).Annotation};
            end

            if(ischar(legendData(count).Value))
                hilite_data.Value=[-1,-1];
            else
                hilite_data.Value=legendData(count).Value;
            end
            break;
        end
    end

    hilite_data.hilitePathSet=zeros(1,0);

    if(isequal(msg{2},'M'))

        if(~highlighSource)
            tab_cont=strcmp(modelName,this.modelList);
            rateBlockInfo=this.legendBlockInfo{tab_cont};
            for count=length(legendData):-1:1
                if(isempty(legendData(count).TID)&&isempty(legendData(count).Value))
                    inclusiveBlocks=[rateBlockInfo(count).AllBlocks(:).Path];
                    break;
                end
            end
            hilite_data.hilitePathSet=inclusiveBlocks;
        end
    elseif(isinf(hilite_data.Value(1))&&(isinf(hilite_data.Value(2))||hilite_data.Value(2)==0))
        stVal=get_param(sys,'CompiledSampleTime');
        isConst=false(size(sys));
        isConstSrc=false(size(sys));
        for count=1:length(sys)
            if(~iscell(stVal))
                stVal={stVal};
            end
            blkST=stVal{count};
            if(~iscell(blkST))
                blkST={blkST};
            end
            for idx=1:length(blkST)
                thisblkST=blkST{idx};

                if(~iscell(thisblkST)&&(isequal(thisblkST,[inf,0])||isequal(thisblkST,[inf,inf])))
                    if advancedConstantDisplay&&...
                        ((isinf(hilite_data.Value(2))&&isequal(thisblkST,[inf,inf]))...
                        ||(hilite_data.Value(2)==0&&isequal(thisblkST,[inf,0])))
                        isConst(count)=true;
                    else
                        isConst(count)=true;
                        blkType=get_param(sys(count),'BlockType');
                        if(isequal(blkType,'Width')||isequal(blkType,'Ground'))
                            isConstSrc(count)=true;
                        end
                    end
                    break;
                end
            end

        end
        blkWithConstRate=sys(isConst);
        tab_cont=strcmp(modelName,this.modelList);
        rateBlockInfo=this.legendBlockInfo{tab_cont};

        allrateIdx=[rateBlockInfo(:).rateIdx];
        idx=find(allrateIdx==rateIdx);
        if(~highlighSource)
            inclusiveBlocks=[rateBlockInfo(idx).AllBlocks(:).Path];
        else
            inclusiveBlocks=[rateBlockInfo(idx).SourceBlocks(:).Path];
        end

        if(~highlighSource)
            if(advancedConstantDisplay)
                hilite_data.hilitePathSet=blkWithConstRate';
            else
                hilite_data.hilitePathSet=[blkWithConstRate',inclusiveBlocks];
                hilite_data.hilitePathSet=unique(hilite_data.hilitePathSet);
            end
        else
            hilite_data.hilitePathSet=[inclusiveBlocks,sys(isConstSrc)'];
        end
    else

        tab_cont=strcmp(modelName,this.modelList);
        rateBlockInfo=this.legendBlockInfo{tab_cont};

        for idx=1:length(rateBlockInfo)
            if(isequal(rateBlockInfo(idx).rateIdx,rateIdx))
                if(highlighSource)
                    if(~isempty(legendData(idx).Owner))
                        if(isstruct(legendData(idx).Owner))
                            if(isfield(legendData(idx).Owner,'OwnerBlock'))
                                inclusiveBlocks=get_param(legendData(idx).Owner.OwnerBlock,'Handle');
                            else
                                ownerStr=legendData(idx).Owner.Owner;
                                posSep=strfind(ownerStr,',');
                                if(~isempty(posSep))
                                    ownerStr=ownerStr(1:posSep(1)-1);
                                end
                                inclusiveBlocks=get_param(ownerStr,'Handle');
                            end
                        else
                            inclusiveBlocks=get_param(legendData(idx).Owner,'Handle');
                        end
                    else
                        inclusiveBlocks=[rateBlockInfo(idx).SourceBlocks(:).Path];
                    end

                else
                    inclusiveBlocks=[rateBlockInfo(idx).AllBlocks(:).Path];
                end

                break;
            end
        end
        hilite_data.hilitePathSet=inclusiveBlocks;
    end




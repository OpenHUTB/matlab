classdef jc_0624_a<slcheck.subcheck

    methods
        function obj=jc_0624_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0624_a';
        end

        function result=run(this)
            result=false;
            doneSet=[];
            vObjArray={};

            subSys=this.getEntity();

            LUM=this.getInputParamByName('Look under masks');
            FL=this.getInputParamByName('Follow links');
            delayBlocks=find_system(subSys,'SearchDepth',1,'LookUnderMasks',LUM,...
            'MatchFilter',@Simulink.match.allVariants,...
            'FollowLinks',FL,'regexp','on','BlockType','(UnitDelay)|(Delay)');


            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(bdroot(subSys));
            nonExcludedBlock=mdladvObj.filterResultWithExclusion(delayBlocks);

            for iDelay=1:length(delayBlocks)
                currentDelay=delayBlocks(iDelay);

                if ismember(currentDelay,doneSet)||~isValidDelay(currentDelay,nonExcludedBlock)
                    continue;
                end


                PortHandle=get_param(currentDelay,'PortConnectivity');
                dstBlk=PortHandle(2).DstBlock;
                tmp=length(dstBlk);



                if tmp>2
                    doneSet=[doneSet;currentDelay];%#ok<*AGROW>
                    continue;
                end
                CommonBlk=[];
                dstDelay=[];
                for m=1:tmp
                    if strcmp(get_param(dstBlk(m),'Commented'),'on')
                        continue
                    end
                    if ismember({get_param(dstBlk(m),'BlockType')},{'UnitDelay','Delay'})
                        dstDelay=dstBlk(m);
                    else
                        CommonBlk=dstBlk(m);
                    end
                end
                if isempty(CommonBlk)
                    continue;
                end
                srcDelay=PortHandle(1).SrcBlock;




                expDst=sort([currentDelay,CommonBlk]);

                DSetBack=[];
                if(-1~=srcDelay)


                    while isValidDelay(srcDelay,nonExcludedBlock)




                        if strcmp(get_param(srcDelay,'Commented'),'on')

                            break;
                        end

                        PortHandleSrc=get_param(srcDelay,'PortConnectivity');
                        SrcDstBlk=sort(PortHandleSrc(2).DstBlock);
                        if length(SrcDstBlk)>2||~isequal(expDst,SrcDstBlk)
                            break
                        end


                        DSetBack=[DSetBack;srcDelay];

                        expDst=sort([srcDelay,CommonBlk]);

                        srcDelay=PortHandleSrc(1).SrcBlock;
                        if(-1==srcDelay)||(length(DSetBack)~=length(unique(DSetBack)))

                            break
                        end

                    end
                end
                doneSet=[doneSet;DSetBack];




                DSetFront=[];
                Convert=true;
                if~isempty(dstDelay)
                    while isValidDelay(dstDelay,nonExcludedBlock)




                        if strcmp(get_param(dstDelay,'Commented'),'on')

                            break;
                        end

                        PortHandleDst=get_param(dstDelay,'PortConnectivity');

                        DstLen=length(PortHandleDst(2).DstBlock);
                        memFlag=ismember(CommonBlk,PortHandleDst(2).DstBlock);
                        if DstLen>2||~memFlag
                            doneSet=[doneSet;dstDelay];
                            Convert=false;
                            break;
                        end





                        DSetFront=[DSetFront;dstDelay];
                        doneSet=[doneSet;dstDelay];
                        dstDelay=setdiff(PortHandleDst(2).DstBlock,CommonBlk);
                        if isempty(dstDelay)||(length(DSetFront)~=length(unique(DSetFront)))

                            break
                        end
                    end
                end
                setToConvert=unique([DSetBack;currentDelay;DSetFront]);
                if length(setToConvert)>1&&Convert
                    vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                    ModelAdvisor.ResultDetail.setData(vObj,'Group',Simulink.ID.getSID(setToConvert));
                    vObjArray=[vObjArray;vObj];
                end
            end
            if~isempty(vObjArray)
                result=this.setResult(vObjArray);
            end
        end
    end
end

function status=isValidDelay(blk,nonExcludedBlock)
    blkObj=get_param(blk,'object');




    status=strcmp(blkObj.Commented,'off')&&...
    (strcmp(blkObj.BlockType,'UnitDelay')||...
    (strcmp(blkObj.BlockType,'Delay')&&strcmp(blkObj.DelayLength,'1')&&strcmp(blkObj.ShowEnablePort,'off')))...
    &&isempty(blkObj.StateName)...
    &&ismember(blk,nonExcludedBlock);
end
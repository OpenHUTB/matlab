classdef jc_0624_b<slcheck.subcheck

    methods
        function obj=jc_0624_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0624_b';
        end

        function result=run(this)
            result=false;
            doneSet=[];
            vObjArray={};

            subSys=this.getEntity();

            LUM=this.getInputParamByName('Look under masks');
            FL=this.getInputParamByName('Follow links');
            delayBlocks=find_system(subSys,'MatchFilter',@Simulink.match.allVariants,...
            'SearchDepth',1,'LookUnderMasks',LUM,'FollowLinks',FL,...
            'regexp','on','BlockType','(UnitDelay)|(Delay)');


            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(bdroot(subSys));
            nonExcludedBlock=mdladvObj.filterResultWithExclusion(delayBlocks);

            for iDelay=1:length(delayBlocks)
                currentDelay=delayBlocks(iDelay);

                if ismember(currentDelay,doneSet)||~isValidDelay(currentDelay,nonExcludedBlock)
                    continue;
                end


                PortHandle=get_param(currentDelay,'PortConnectivity');
                dstDelay=PortHandle(2).DstBlock;
                tmp=length(dstDelay);



                if tmp>1
                    doneSet=[doneSet;currentDelay];%#ok<*AGROW>
                    continue;
                end
                srcDelay=PortHandle(1).SrcBlock;





                DSetBack=[];
                if(-1~=srcDelay)
                    while isValidDelay(srcDelay,nonExcludedBlock)



                        if strcmp(get_param(srcDelay,'Commented'),'on')

                            break;
                        end

                        PortHandleSrc=get_param(srcDelay,'PortConnectivity');
                        SrcDstBlk=sort(PortHandleSrc(2).DstBlock);
                        if length(SrcDstBlk)>1
                            break
                        end
                        DSetBack=[DSetBack;srcDelay];

                        srcDelay=PortHandleSrc(1).SrcBlock;
                        if(-1==srcDelay)||(length(DSetBack)~=length(unique(DSetBack)))

                            break
                        end
                    end
                end
                doneSet=[doneSet;DSetBack];




                DSetFront=[];

                if~isempty(dstDelay)
                    while isValidDelay(dstDelay,nonExcludedBlock)



                        if strcmp(get_param(dstDelay,'Commented'),'on')

                            break;
                        end

                        PortHandleDst=get_param(dstDelay,'PortConnectivity');

                        DstLen=length(PortHandleDst(2).DstBlock);
                        if DstLen>1
                            doneSet=[doneSet;dstDelay];
                            DSetFront=[DSetFront;dstDelay];
                            break;
                        end
                        DSetFront=[DSetFront;dstDelay];
                        doneSet=[doneSet;dstDelay];
                        dstDelay=PortHandleDst(2).DstBlock;
                        if isempty(dstDelay)||(length(DSetFront)~=length(unique(DSetFront)))

                            break
                        end
                    end
                end

                setToConvert=unique([DSetBack;currentDelay;DSetFront]);
                if length(setToConvert)>1
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
    (strcmp(blkObj.BlockType,'Delay')&&strcmp(blkObj.ShowEnablePort,'off')))...
    &&isempty(blkObj.StateName)...
    &&ismember(blk,nonExcludedBlock);
end
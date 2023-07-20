function[initOut,maskObj]=getInitialValueOfConditionalSS(sysH,refMdlToMdlBlk)























    initOut={};
    maskObj={};
    if strcmp(get(sysH,'type'),'block_diagram')
        if~isempty(refMdlToMdlBlk)&&refMdlToMdlBlk.isKey(sysH)
            sysH=refMdlToMdlBlk(sysH);
            sysObj=get(sysH,'Object');
            if sysObj.isSynthesized


                sysH=sysObj.getTrueOriginalBlock;
            end
        else
            return;
        end
    end

    if strcmp(get(sysH,'BlockType'),'SubSystem')&&strcmp(get(sysH,'SFBlockType'),'Chart')
        initOut=getSFInitValue(sysH);
        maskObj=cell(size(initOut));
        return;
    end

    ssPH=get_param(sysH,'PortHandles');
    initOut=cell(1,length(ssPH.Outport));
    maskObj=cell(1,length(ssPH.Outport));
    nOutport=length(ssPH.Outport);
    lastSrcBH=zeros(1,nOutport);
    directSrcEmpty=false(1,nOutport);

    for i=1:nOutport
        outBH=Transform.getOutportBlock(sysH,i);
        directInitOut=[];
        directMskObj=[];


        if hasControlPort(ssPH)
            if strcmp(get(outBH,'SourceOfInitialOutputValue'),'Dialog')
                initV=get_param(outBH,'InitialOutput');
                directMskObj=checkMask(sysH);
                [initVeval,evalStat]=modelslicerprivate('evalinModel',bdroot(sysH),initV);
                if~isempty(initVeval)



                    directInitOut=initV;

                elseif~isempty(directMskObj)&&(~evalStat||~isempty(initVeval))




                    directInitOut=initV;
                end



            end
        end



        nIte=1;
        thisBH=outBH;
        indirectInitOut=[];
        indirectMskObj=[];
        import slslicer.internal.*
        while true

            srcBH=SLGraphUtil.findSrcBlocks(thisBH,false);
            if isempty(srcBH)
                break;
            else
                blockType=get(srcBH,'BlockType');
                parent=get(srcBH,'Parent');
                if strcmp(get_param(parent,'type'),'block_diagram')
                    break;
                end
                indirectMskObj=checkMask(parent);
                ppH=get_param(parent,'PortHandles');
                switch blockType
                case 'Outport'
                    if strcmp(get_param(parent,'SFBlockType'),'Chart')


                        sfInit=getSFInitValue(get_param(parent,'Handle'));
                        indirectInitOut=sfInit{str2double(get(srcBH,'Port'))};
                        break;
                    elseif hasControlPort(ppH)

                        if strcmp(get(srcBH,'SourceOfInitialOutputValue'),'Input signal')
                            thisBH=srcBH;
                        else
                            indirectInitOut=get_param(srcBH,'InitialOutput');
                            break;
                        end
                    else
                        thisBH=srcBH;
                    end
                case 'InitialCondition'
                    indirectInitOut=get_param(srcBH,'Value');
                    break;
                case 'Constant'
                    indirectInitOut=get_param(srcBH,'Value');
                case 'Merge'
                    indirectInitOut=get_param(srcBH,'InitialOutput');
                case{'Goto','From','SignalConversion'}
                    thisBH=srcBH;
                otherwise
                    break;
                end
            end
            if nIte>100

                break;
            end
            nIte=nIte+1;
        end
        if~isempty(directInitOut)
            thisInitOut=directInitOut;
            mskObj=directMskObj;
        else
            thisInitOut=indirectInitOut;
            mskObj=indirectMskObj;
            directSrcEmpty(i)=true;
        end

        if isempty(mskObj)&&isempty(modelslicerprivate('evalinModel',bdroot(sysH),thisInitOut))
            thisInitOut=[];
        end

        initOut{i}=thisInitOut;
        maskObj{i}=mskObj;
        if~isempty(srcBH)

            lastSrcBH(i)=srcBH;
        end
    end







    for i=1:nOutport
        if directSrcEmpty(i)
            idx=find(lastSrcBH(i)==lastSrcBH);
            for j=1:length(idx)
                if i~=idx(j)&&~directSrcEmpty(idx(j))


                    initOut{i}=initOut{idx(j)};
                end
            end
        end
    end
end

function initOut=getSFInitValue(sysH)
    ssPH=get_param(sysH,'PortHandles');
    initOut=cell(1,length(ssPH.Outport));
    rt=sfroot;
    chart=rt.find('-isa','Stateflow.Chart','Path',getfullname(sysH));
    data=chart.find('-isa','Stateflow.Data','Scope','Output');
    for i=1:length(data)
        props=data(i).Props;
        numPort=data(i).Port;
        if numPort<=length(initOut)
            initOut{numPort}=props.InitialValue;
        end
    end
end

function yesno=hasControlPort(ph)
    yesno=~isempty(ph.Enable)||~isempty(ph.Trigger)...
    ||~isempty(ph.Ifaction)||~isempty(ph.Reset);
end

function maskObj=checkMask(sysH)
    maskObj=[];

    maskType=get_param(sysH,'MaskType');
    if any(strcmp(maskType,...
        {'chirp',...
        'Counter Free-Running',...
        'Counter Limited',...
        'Ramp',...
        'Repeating table',...
        'Repeating Sequence Interpolated',...
        'Repeating Sequence Stair',...
        'Sigbuilder block',...
        'WaveformGenerator'}))
        return;
    end
    if strcmp(get_param(sysH,'Mask'),'on')
        maskObj=Simulink.Mask.get(sysH);
    end
end


function[sig,block]=fixHighlightForConstraintSubsystem(this,sig,block,exclusions,dir)%#ok<INUSL>






    origSig=sig;
    origBlock=block;

    try
        if any(strcmpi(dir,{'back','either'}))
            for i=1:length(exclusions)
                if strcmp(get_param(exclusions(i),'BlockType'),'SubSystem')
                    exclPH=get_param(exclusions(i),'PortHandles');
                    outBlks=find_system(exclusions(i),'FindAll','on','LookUnderMasks','all',...
                    'SearchDepth',1,'BlockType','Outport');
                    for oi=1:length(outBlks)
                        thiPortNum=str2double(get_param(outBlks(oi),'Port'));


                        bObj=get_param(outBlks(oi),'Object');
                        aSrcTemp=bObj.getActualSrc;
                        aSrc=aSrcTemp(:,1);


                        pObj=get_param(exclPH.Outport(thiPortNum),'Object');
                        aDstTemp=pObj.getActualDst;
                        aDst=aDstTemp(:,1);


                        idxSrc=ismember(sig.src,aSrc);
                        idxDst=ismember(sig.dst,aDst);
                        sig.src(idxSrc&idxDst)=exclPH.Outport(thiPortNum);
                    end
                end
            end
        end
        if any(strcmpi(dir,{'forward','either'}))
            for i=1:length(exclusions)
                if strcmp(get_param(exclusions(i),'BlockType'),'SubSystem')
                    exclPH=get_param(exclusions(i),'PortHandles');
                    inBlks=find_system(exclusions(i),'FindAll','on','LookUnderMasks','all',...
                    'SearchDepth',1,'BlockType','Inport');
                    for oi=1:length(inBlks)
                        thiPortNum=str2double(get_param(inBlks(oi),'Port'));


                        bObj=get_param(inBlks(oi),'Object');
                        aDstTemp=bObj.getActualDst;
                        aDst=aDstTemp(:,1);


                        pObj=get_param(exclPH.Inport(thiPortNum),'Object');
                        aSrcTemp=pObj.getActualSrc;
                        aSrc=aSrcTemp(:,1);


                        idxSrc=ismember(sig.src,aSrc);
                        idxDst=ismember(sig.dst,aDst);
                        sig.dst(idxSrc&idxDst)=exclPH.Inport(thiPortNum);
                    end
                end
            end
        end
    catch

        sig=origSig;
        block=origBlock;
    end
end

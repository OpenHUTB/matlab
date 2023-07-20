




function setIdealBlockPosition(self,blk,incr)
    if self.ComponentHasBehavior
        assert(~strcmp(get_param(blk,'Parent'),self.MdlName),...
        'setIdealBlockPosition should not be used on the top level model');
    end

    if nargin<3
        incr=true;
    end
    parentSS=get_param(get_param(blk,'Parent'),'Handle');
    if~self.slSubsystem2PositionMap.isKey(parentSS)
        self.createSubsystemPositionEntry(parentSS);
    end
    ssPositions=self.slSubsystem2PositionMap(parentSS);
    blkType=get_param(blk,'BlockType');


    extraW=0;
    extraH=0;
    if strcmpi(blkType,'S-Function')&&...
        strcmpi(get_param(blk,'MaskType'),'Invoke AUTOSAR Server Operation')||...
        strcmpi(blkType,'FunctionCaller')||strcmpi(blkType,'RateTransition')
        extraW=20;
        extraH=30;
        blkType='Inport';
    end

    if strcmpi(blkType,'Constant')
        blkType='Inport';
    end

    if strcmpi(blkType,'ArgIn')
        extraW=5;
        extraH=6;
        blkType='Inport';
    end

    if strcmpi(blkType,'ArgOut')
        extraW=5;
        extraH=6;
        blkType='Outport';
    end

    if any(strcmpi(blkType,{'Lookup_n-D','Interpolation_n-D','Prelookup'}))
        extraW=-50;
        extraH=50;
        blkType='SubSystem';
    end

    if strcmp(blkType,'DataStoreMemory')
        extraW=-110;
        extraH=-160;
        blkType='SubSystem';
    end

    if ssPositions.isKey(blkType)
        lastPosition=ssPositions(blkType);


        x=lastPosition(1);
        y=lastPosition(2)+lastPosition(3);
        w=lastPosition(4)+extraW;
        h=lastPosition(5)+extraH;





        if strcmpi(blkType,'subsystem')
            blk=autosar.mm.mm2sl.SLModelBuilder.getHandle(blk);
            inp=find_system(blk,'SearchDepth',1,'blocktype','Inport');
            outp=find_system(blk,'SearchDepth',1,'blocktype','Outport');
            maxInpName=0;
            maxOutpName=0;
            for ii=1:numel(inp)
                maxInpName=max(maxInpName,numel(get_param(inp(ii),'Name')));
            end
            for ii=1:numel(outp)
                maxOutpName=max(maxOutpName,numel(get_param(outp(ii),'Name')));
            end


            fontSize=10;
            idealWidth=0.5*fontSize*(maxInpName+maxOutpName);
            w=max(w,idealWidth);
            idealHeight=(max(numel(inp),numel(outp))+1)*30+30;
            h=max(h,idealHeight);


            if strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blk,'IsSimulinkFunction'),'on')&&...
                numel(inp)==0&&numel(outp)==0||...
                strcmp(get_param(blk,'BlockType'),'DataStoreMemory')
                h=25;
                y=lastPosition(2)+35;
            end

        end


        if y+h>32000
            x=x+150;
            y=33;
        end

        set_param(blk,'Position',[x,y,x+w,y+h]);


        lastPosition(1)=x;
        lastPosition(2)=y+h;
        if incr
            lastPosition(end)=lastPosition(end)+1;
        end
        ssPositions(blkType)=lastPosition;
        mySelfPosition=ssPositions('MySelf');
        mySelfPosition(1)=max(mySelfPosition(1),x+w);
        mySelfPosition(2)=max(mySelfPosition(2),y+h);
        ssPositions('MySelf')=mySelfPosition;
        self.slSubsystem2PositionMap(parentSS)=ssPositions;
    end

end



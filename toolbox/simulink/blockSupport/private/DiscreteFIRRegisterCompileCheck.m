function DiscreteFIRRegisterCompileCheck(block,h)


    appendCompileCheck(h,block,@CollectDiscreteFIRData,@ReshapeCoefInport);

end



function isCoefColumnVector=CollectDiscreteFIRData(block,~)

    isCoefColumnVector=false;

    if strcmpi(get_param(block,'CoefSource'),'Input port')
        tpDims=get_param(block,'CompiledPortDimensions');
        coefPort=tpDims.Inport(length(tpDims.Outport)+1:end);
        if(coefPort(1)>1)&&(coefPort(2)>1)
            isCoefColumnVector=true;
        end
    end

end



function ReshapeCoefInport(block,~,isCoefColumnVector)
    if isCoefColumnVector
        [~,fcBlkName]=fileparts(tempname);
        blkParentName=get_param(block,'Parent');
        fcBlkName=[blkParentName,'/',fcBlkName];


        blkLHandles=get_param(block,'LineHandles');
        blkLHInport=get(blkLHandles.Inport(2));
        delete_line(blkLHInport.Handle);


        blkPos=get_param(block,'Position');
        blkOrient=get_param(block,'Orientation');
        blkCenter=mean([blkPos(1:2);blkPos(3:4)]);
        blkWidth=blkPos(3)-blkPos(1);
        blkHeight=blkPos(4)-blkPos(2);
        tpsBlkHOffset=40;
        tpsBlkVOffset=-10;
        if strcmpi(blkOrient,'left')||strcmpi(blkOrient,'right')
            sign=strcmpi(blkOrient,'left')*2-1;
            tpsBlkCenter=[blkCenter(1)+sign*(blkWidth/2+tpsBlkHOffset),...
            blkCenter(2)-tpsBlkVOffset];
            tpsBlkWidth=20;
            tpsBlkHeight=blkHeight;
        elseif(strcmpi(blkOrient,'up')||strcmpi(blkOrient,'down'))
            sign=strcmpi(blkOrient,'up')*2-1;
            tpsBlkCenter=[blkCenter(1)-tpsBlkVOffset,...
            blkCenter(2)+sign*(blkHeight/2+tpsBlkHOffset)];
            tpsBlkWidth=blkWidth;
            tpsBlkHeight=20;
        end

        tpsBlkPos=[tpsBlkCenter(1)-tpsBlkWidth/2,...
        tpsBlkCenter(2)-tpsBlkHeight/2,...
        tpsBlkCenter(1)+tpsBlkWidth/2,...
        tpsBlkCenter(2)+tpsBlkHeight/2];

        fcBlkHandle=add_block('built-in/Reshape',fcBlkName,...
        'OutputDimensionality','Row vector (2-D)',...
        'Position',tpsBlkPos,...
        'Orientation',blkOrient,...
        'ShowName','off');

        fcBlkPortH=get_param(fcBlkHandle,'PortHandles');

        fromBlkName=get_param(blkLHInport.SrcBlockHandle,'Name');

        fromBlkName=regexprep(fromBlkName,'/','//');
        fromBlkPortNum=get_param(blkLHInport.SrcPortHandle,'PortNumber');
        toBlkName=get_param(fcBlkHandle,'Name');
        toBlkPortNum=get_param(fcBlkPortH.Inport,'PortNumber');
        add_line(blkParentName,[fromBlkName,'/',int2str(fromBlkPortNum)],...
        [toBlkName,'/',int2str(toBlkPortNum)],...
        'autorouting','on');

        fromBlkName=get_param(fcBlkHandle,'Name');
        fromBlkPortNum=get_param(fcBlkPortH.Outport,'PortNumber');
        toBlkName=get_param(blkLHInport.DstBlockHandle,'Name');

        toBlkName=regexprep(toBlkName,'/','//');
        toBlkPortNum=get_param(blkLHInport.DstPortHandle,'PortNumber');
        add_line(blkParentName,[fromBlkName,'/',int2str(fromBlkPortNum)],...
        [toBlkName,'/',int2str(toBlkPortNum)],...
        'autorouting','on');
    end

end

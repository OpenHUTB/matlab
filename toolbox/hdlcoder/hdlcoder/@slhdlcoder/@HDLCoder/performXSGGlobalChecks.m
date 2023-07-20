function checks=performXSGGlobalChecks(this)




    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});
    if targetcodegen.xilinxsysgendriver.isXsgVivado


        xsgBlks=[];
        isXsg=true;
    else
        xsgBlks=targetcodegen.xilinxisesysgendriver.findXSGBlks(this.getStartNodeName,'all');
        isXsg=~isempty(xsgBlks);
    end


    if isXsg
        if(this.getParameter('clockedge')==1)
            checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
            checks(end).type='model';
            checks(end).MessageID='hdlcoder:validate:xsgnofallingedge';
            checks(end).message=message('hdlcoder:validate:xsgnofallingedge').getString();
            checks(end).level='Error';
        end
    end



    if~isXsg||isempty(xsgBlks)&&isXsg
        return;
    end


    referenceChip=chipString(xlgetparams(xsgBlks{1}));
    for i=1:length(xsgBlks)
        xsgBlk=xsgBlks{i};
        chip=chipString(xlgetparams(xsgBlk));
        if(~isequal(referenceChip,chip))
            checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
            checks(end).type='model';
            checks(end).MessageID='hdlcoder:validate:xsgblkconflictdeviceamongxsgs';
            checks(end).message='Different devices are set in system generator blocks.';
            checks(end).level='Error';
        end
    end

end

function str=chipString(xsgParams)
    str=sprintf('%s %s%s%s',xsgParams.xilinxfamily,xsgParams.part,xsgParams.speed,xsgParams.package);
end



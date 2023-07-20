function checks=performDSPBAGlobalChecks(this)




    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});

    startNodeName=this.getStartNodeName;
    dspbaBlks=targetcodegen.alteradspbadriver.findDSPBABlks(startNodeName);
    if(isempty(dspbaBlks))
        this.hasDspba=false;
        return;
    end
    this.hasDspba=true;

    if(this.getParameter('clockedge')==1)
        checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
        checks(end).type='model';
        checks(end).MessageID='hdlcoder:validate:dspbanofallingedge';
        checks(end).message=message('hdlcoder:validate:dspbanofallingedge').getString();
        checks(end).level='Error';
    end

    if(any(strcmp(dspbaBlks,startNodeName)))
        checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
        checks(end).type='model';
        checks(end).MessageID='hdlcoder:validate:dspbaasdut';
        checks(end).message=message('hdlcoder:validate:dspbaasdut').getString;
        checks(end).level='Error';
    end

    foundIdx=strfind(dspbaBlks,[startNodeName,'/']);
    for i=1:length(foundIdx)
        if(isempty(foundIdx{i}))
            checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
            checks(end).type='block';
            checks(end).MessageID='hdlcoder:validate:dspbablkoutsideofdut';
            checks(end).message=message('hdlcoder:validate:dspbablkoutsideofdut',dspbaBlks{i}).getString;
            checks(end).level='Error';
        end
    end

    deviceBlkPath=find_system(dspbaBlks{1},'searchdepth',1,'ReferenceBlock','DSPBABase/Device');
    firstChip=chipString(deviceBlkPath{:});
    for i=2:length(dspbaBlks)
        deviceBlkPath=find_system(dspbaBlks{i},'searchdepth',1,'ReferenceBlock','DSPBABase/Device');
        chip=chipString(deviceBlkPath{:});
        if(~isequal(firstChip,chip))
            checks(end+1).path=this.getStartNodeName;%#ok<*AGROW>
            checks(end).type='model';
            checks(end).MessageID='hdlcoder:validate:dspbablkconflictdeviceamongdspbas';
            checks(end).message=message('hdlcoder:validate:dspbablkconflictdeviceamongdspbas').getString;
            checks(end).level='Error';
        end
    end

end

function str=chipString(deviceBlkPath)
    str=sprintf('%s %s%s%s',get_param(deviceBlkPath,'family'),...
    get_param(deviceBlkPath,'device'),...
    '',...
    get_param(deviceBlkPath,'speed'));
end





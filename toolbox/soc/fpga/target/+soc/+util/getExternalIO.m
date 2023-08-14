function extIO=getExternalIO(topSys,sys,hboard,verbose)
    extIO=struct('name',{},'dir',{},'std',{},'pin',{});
    led_blk=find_system(topSys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/LED');
    pb_blk=find_system(topSys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/Push Button');
    ds_blk=find_system(topSys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/DIP Switch');
    cIO_blk=find_system(topSys,'SearchDepth',1,'ReferenceBlock','soclib_beta/I//O Pin');
    if isempty(led_blk)&&isempty(pb_blk)&&isempty(ds_blk)&&isempty(cIO_blk)&&~isempty(sys)


        led_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/LED');
        pb_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/Push Button');
        ds_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','hwlogiciolib/DIP Switch');
        cIO_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','soclib_beta/I//O Pin');
    end
    if verbose
        fprintf('---------- Configuring external IO ----------\n');
    end
    if~isempty(led_blk)
        num_leds=0;
        for curBlk=1:numel(led_blk)
            num_leds=evalin('base',get_param(led_blk{curBlk},'NumLEDs'))+num_leds;
        end


        if numel(hboard.LED)<num_leds
            error(message('soc:msgs:noEnoughExternalIO','LED'));
        end

        for i=1:num_leds
            this_io.name=['LED',num2str(i)];
            this_io.dir='O';
            this_io.std=hboard.LED(i).std;
            this_io.pin=hboard.LED(i).pin;
            extIO=[extIO,this_io];
            if verbose
                fprintf('### %s is assigned to %s on %s\n',this_io.name,hboard.LED(i).desc,hboard.Name);
            end
        end
    end

    if~isempty([pb_blk,ds_blk])
        numPBs=0;numDSs=0;
        for curBlk=1:numel(pb_blk)
            numPBs=evalin('base',get_param(pb_blk{curBlk},'NumHMI'))+numPBs;
        end

        for curBlk=1:numel(ds_blk)
            numDSs=evalin('base',get_param(ds_blk{curBlk},'NumHMI'))+numDSs;
        end

        if numel(hboard.PushButton)<numPBs
            error(message('soc:msgs:noEnoughExternalIO','push button'));
        end

        for i=1:numPBs
            this_io.name=['PB',num2str(i)];
            this_io.dir='I';
            this_io.std=hboard.PushButton(i).std;
            this_io.pin=hboard.PushButton(i).pin;
            extIO=[extIO,this_io];
            if verbose
                fprintf('### %s is assigned to %s on %s\n',this_io.name,hboard.PushButton(i).desc,hboard.Name);
            end
        end

        if numel(hboard.DIPSwitch)<numDSs
            error(message('soc:msgs:noEnoughExternalIO','DIP switch'));
        end

        for i=1:numDSs
            this_io.name=['DS',num2str(i)];
            this_io.dir='I';
            this_io.std=hboard.DIPSwitch(i).std;
            this_io.pin=hboard.DIPSwitch(i).pin;
            extIO=[extIO,this_io];
            if verbose
                fprintf('### %s is assigned to %s on %s\n',this_io.name,hboard.DIPSwitch(i).desc,hboard.Name);
            end
        end

    end


    if~isempty(cIO_blk)
        for curBlk=1:numel(cIO_blk)
            blkP=soc.blkcb.cbutils('GetDialogParams',cIO_blk{curBlk});
            for i=1:size(blkP.IOTable,1)
                PinArray=split(string(blkP.IOTable(i,4)),',');
                IOStandardArray=split(string(blkP.IOTable(i,5)),',');
                if strcmpi(blkP.IOTable(i,3),'boolean')
                    bitwidth=1;
                elseif strcmpi(blkP.IOTable(i,3),'uint8')
                    bitwidth=8;
                elseif strcmpi(blkP.IOTable(i,3),'uint16')
                    bitwidth=16;
                end

                for j=1:bitwidth
                    if bitwidth==1
                        this_io.name=string(blkP.IOTable(i,1));
                    else
                        this_io.name=strcat(string(blkP.IOTable(i,1)),'[',num2str(j-1),']');
                    end
                    if strcmpi(string(blkP.IOTable(i,2)),'input')
                        this_io.dir='I';
                    else
                        this_io.dir='O';
                    end
                    this_io.std=strcat("IOSTANDARD ",IOStandardArray(1));
                    this_io.pin=PinArray(j);
                    extIO=[extIO,this_io];
                    if verbose
                        fprintf('### %s is assigned to %s on %s\n',this_io.name,hboard.LED(i).desc,hboard.Name);
                    end
                end
            end
        end
    end
end




function generateSLBlock(this,hC,targetBlkPath)


    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        error(message('hdlcoder:validate:invalidblockpath',sprintf('%e',hC.SimulinkHandle)));
    end


    in1=hC.SLInputPorts(1).Signal;
    in1vect=hdlsignalvector(in1);
    vectorsize=max(in1vect);


    out=hC.SLOutputPorts(1).Signal;
    opvect=hdlsignalvector(out);




    if isequal(opvect,in1vect)
        targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
    else
        xstep=80;
        ystep=80;
        yqtrstep=ystep/4;
        xqtrstep=ystep/4;
        yinc=vectorsize*yqtrstep;
        ycenter=85+yinc;
        xpos=85;
        ypos=ycenter;

        targetBlkPath=addSLBlock(this,hC,'built-in/Subsystem',targetBlkPath);

        [turnhilitingon,color]=getHiliteInfo;
        set_param(targetBlkPath,'BackgroundColor',color);
        if turnhilitingon
            hiliteBlkAncestors(targetBlkPath,color);
        end

        inportPath=[targetBlkPath,'/In1'];
        add_block('built-in/Inport',inportPath,'Position',...
        [xpos,ypos-7,xpos+30,ypos+7]);

        xpos=xpos+xstep;
        demuxPath=sprintf('%s/demux1',targetBlkPath);
        add_block('built-in/Demux',demuxPath);
        set_param(demuxPath,'Outputs',int2str(vectorsize),...
        'Position',[xpos,ypos-yinc,xpos+xqtrstep,ypos+yinc]);

        add_line(targetBlkPath,portPath(inportPath,1),...
        portPath(demuxPath,1),'autorouting','on');

        column_ins=cell(1,vectorsize);
        for ii=1:vectorsize
            column_ins{ii}=portPath(demuxPath,ii);
        end

        xpos=xpos+xstep;
        ypos=ycenter+yqtrstep-yinc;

        sizes=hdlsignalsizes(in1);
        wl_in=ones(1,vectorsize)*sizes(1);
        bp_in=ones(1,vectorsize)*sizes(2);

        looplim=ceil(log2(vectorsize));
        for col=1:looplim
            ii=1;
            column_outs={};
            cinsize=length(column_ins);
            wl_out=ones(1,ceil(cinsize/2));
            bp_out=ones(1,ceil(cinsize/2));
            for row=2:2:cinsize
                prodcol{ii}=sprintf('%s/prod%d_%d',targetBlkPath,col,ii);%#ok
                [wl_out(ii),bp_out(ii)]=localGetProductOutDataType(...
                wl_in(row-1),wl_in(row),bp_in(row-1),bp_in(row));
                dt=localGetModeOutDataTypeScaling(in1,out,wl_out(ii),bp_out(ii));

                add_block('built-in/Product',prodcol{ii},...
                'Position',[xpos,ypos,xpos+xqtrstep,ypos+yqtrstep],...
                'InputSameDT','off',...
                'OutDataTypeStr',dt,...
                'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                'SaturateOnIntegerOverflow',...
                get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));

                add_line(targetBlkPath,column_ins{row-1},portPath(prodcol{ii},1),...
                'autorouting','off');
                add_line(targetBlkPath,column_ins{row},portPath(prodcol{ii},2),...
                'autorouting','off');
                column_outs{ii}=portPath(prodcol{ii},1);%#ok<AGROW>
                ii=ii+1;
                ypos=ypos+ystep;
            end
            if mod(cinsize,2)
                column_outs{end+1}=column_ins{end};%#ok<AGROW>
                wl_out(end)=wl_in(end);
                bp_out(end)=bp_in(end);
            end
            column_ins=column_outs;
            wl_in=wl_out;
            bp_in=bp_out;
            xpos=xpos+xstep;
            ypos=ycenter+yqtrstep-yqtrstep*((cinsize+1)/2);
        end

        ypos=ycenter;

        dt=localGetModeOutDataTypeScaling(out);
        add_block('built-in/DataTypeConversion',...
        [targetBlkPath,'/FinalConvert'],...
        'Position',[xpos,ypos-15,xpos+30,ypos+15],...
        'OutDataTypeStr',dt,...
        'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
        'SaturateOnIntegerOverflow',...
        get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));

        add_line(targetBlkPath,...
        column_outs{end},...
        portPath([targetBlkPath,'/FinalConvert'],1),...
        'autorouting','off');

        xpos=xpos+xstep;
        outportPath=[targetBlkPath,'/Out1'];
        add_block('built-in/Outport',outportPath)
        set_param(outportPath,'Position',[xpos,ypos-7,xpos+30,ypos+7]);

        add_line(targetBlkPath,...
        portPath([targetBlkPath,'/FinalConvert'],1),...
        portPath(outportPath,1),'autorouting','off');
    end
end



function path=portPath(blkPath,portNumber)
    sep=strfind(blkPath,'/');
    if~isempty(sep)
        blkPath=blkPath(sep(end)+1:end);
    end
    path=sprintf('%s/%d',blkPath,portNumber);
end


function hiliteBlkAncestors(blkPath,color)
    while~isempty(blkPath)
        set_param(blkPath,'BackgroundColor',color);
        blkPath=get_param(blkPath,'Parent');
        if isempty(get_param(blkPath,'Parent'))
            break;
        end
    end
end


function[turnhilitingon,color]=getHiliteInfo
    color=hdlgetparameter('hilitecolor');
    turnhilitingon=hdlgetparameter('hiliteancestors');
end


function dt=localGetModeOutDataTypeScaling(in,out,new_wl,new_bp)
    sizes=hdlsignalsizes(in);
    if sizes(1)==0
        dt='double';
    else
        if nargin>1
            if new_wl>128
                sizes=hdlsignalsizes(out);
            else
                sizes(1)=new_wl;
                sizes(2)=new_bp;
            end
        end

        sizes=hdlcheckslsizes(sizes);
        if sizes(3)
            dt=['fixdt(1,',int2str(sizes(1)),',',int2str(sizes(2)),')'];
        else
            dt=['fixdt(0,',int2str(sizes(1)),',',int2str(sizes(2)),')'];
        end
    end
end

function[newwl,newbp]=localGetProductOutDataType(in1wl,in2wl,in1bp,in2bp)
    newwl=in1wl+in2wl;
    newbp=in1bp+in2bp;
end

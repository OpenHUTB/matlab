function[injInBlks,injOutBlks]=addInjectorPortsForSignalsInInjectorSS(accHdls,injHdls,injSS,showAndSelect,varargin)





    if iscell(accHdls)
        blockPath=accHdls{1};
        accHdls=accHdls{2};
    else
        blockPath=[];
    end
    if iscell(injHdls)
        blockPath=injHdls{1};
        injHdls=injHdls{2};
    else
        blockPath=[];
    end

    injInBlks=zeros(1,numel(accHdls));
    injInLines=zeros(1,numel(accHdls));
    injOutBlks=zeros(1,numel(injHdls));

    existingInjInBlks=Simulink.injector.internal.getGrInjectorInportsInInjectorSubsystem(get_param(injSS,'Handle'));
    existingInjOutBlks=Simulink.injector.internal.getGrInjectorOutportsInInjectorSubsystem(get_param(injSS,'Handle'));

    for j=1:numel(existingInjInBlks)
        obj=get_param(existingInjInBlks(j),'Object');
        obj.hilite('none');
    end
    for j=1:numel(existingInjOutBlks)
        obj=get_param(existingInjOutBlks(j),'Object');
        obj.hilite('none');
    end

    defaultvdist=50;
    [inpos,outpos]=getNewPortPositionHeuristic(existingInjInBlks,existingInjOutBlks,defaultvdist);

    for j=1:numel(accHdls)
        prtH=accHdls(j);
        if prtH~=-1
            if~strcmp(get_param(prtH,'PortType'),'outport')
                DAStudio.error('Simulink:Injector:InvalidInjectorPortConfig');
            end
            block=get_param(prtH,'Parent');
            prtIdx=get_param(prtH,'PortNumber');
            injInBlks(j)=add_block('safetylib/Injector Subsystem/InjectorInport',[injSS,'/InjectorInport'],'MakeNameUnique','on','Position',inpos);
            Simulink.injector.internal.configureInjectorPort(injInBlks(j),'Outport',[blockPath,get_param(block,'Handle')],prtIdx);
        else
            injInBlks(j)=add_block('safetylib/Injector Subsystem/InjectorInport',[injSS,'/InjectorInport'],'MakeNameUnique','on','Position',inpos);
        end
        if~isempty(varargin)
            set_param(injInBlks(j),varargin{:});
        end
        portHandles=get_param(injInBlks(j),'PortHandles');
        portPos=get_param(portHandles.Outport,'Position');
        injInLines(j)=add_line(injSS,[portPos;portPos+[90,0]]);
        inpos=inpos+[0,defaultvdist,0,defaultvdist];
    end

    for j=1:numel(injHdls)
        prtH=injHdls(j);
        if prtH~=-1
            if~strcmp(get_param(prtH,'PortType'),'outport')
                DAStudio.error('Simulink:Injector:InvalidInjectorPortConfig');
            end
            block=get_param(prtH,'Parent');
            prtIdx=get_param(prtH,'PortNumber');
            injOutBlks(j)=add_block('safetylib/Injector Subsystem/InjectorOutport',[injSS,'/InjectorOutport'],'MakeNameUnique','on','Position',outpos);
            Simulink.injector.internal.configureInjectorPort(injOutBlks(j),'Outport',[blockPath,get_param(block,'Handle')],prtIdx);
        else
            injOutBlks(j)=add_block('safetylib/Injector Subsystem/InjectorOutport',[injSS,'/InjectorOutport'],'MakeNameUnique','on','Position',outpos);
        end
        if~isempty(varargin)
            set_param(injOutBlks(j),varargin{:});
        end
        outpos=outpos+[0,defaultvdist,0,defaultvdist];
    end

    objs=find_system(injSS,'SearchDepth',1,'FindAll','on','Selected','on');
    arrayfun(@(x)set_param(x,'Selected','off'),objs);
    if showAndSelect
        for j=1:numel(accHdls)
            set_param(injInBlks(j),'Selected','on');
            set_param(injInLines(j),'Selected','on');
        end
        for j=1:numel(injHdls)
            set_param(injOutBlks(j),'Selected','on');
        end
        if~strcmp(get_param(injSS,'open'),'on')
            open_system(injSS,'window');
        end
    end

end

function[inpos,outpos]=getNewPortPositionHeuristic(existingInjInBlks,existingInjOutBlks,defaultvdist)

    blkwidth=45;
    blkheight=26;
    defaulthdist=260;

    inxpos=0;
    inypos=0;
    outxpos=defaulthdist+blkwidth;
    outypos=0;

    if~isempty(existingInjInBlks)&&isempty(existingInjOutBlks)
        posArray=cell2mat(arrayfun(@(x)get_param(x,'Position'),existingInjInBlks,'UniformOutput',false));
        posArray=sortrows(posArray,4);
        inypos=posArray(end,2)+defaultvdist;
        outypos=posArray(1,2);
        posArray=sortrows(posArray,1);
        inxpos=posArray(1,1);
        outxpos=posArray(end,1)+defaulthdist+blkwidth;
    elseif isempty(existingInjInBlks)&&~isempty(existingInjOutBlks)
        posArray=cell2mat(arrayfun(@(x)get_param(x,'Position'),existingInjOutBlks,'UniformOutput',false));
        posArray=sortrows(posArray,4);
        inypos=posArray(1,2);
        outypos=posArray(end,2)+defaultvdist;
        posArray=sortrows(posArray,1);
        inxpos=posArray(1,1)-defaulthdist-blkwidth;
        outxpos=posArray(end,1);
    elseif~isempty(existingInjInBlks)&&~isempty(existingInjOutBlks)
        inposArray=cell2mat(arrayfun(@(x)get_param(x,'Position'),existingInjInBlks,'UniformOutput',false));
        inposArray=sortrows(inposArray,4);
        inypos=inposArray(end,2)+defaultvdist;
        inposArray=sortrows(inposArray,1);
        inxpos=inposArray(1,1);

        outposArray=cell2mat(arrayfun(@(x)get_param(x,'Position'),existingInjOutBlks,'UniformOutput',false));
        outposArray=sortrows(outposArray,4);
        outypos=outposArray(end,2)+defaultvdist;
        outposArray=sortrows(outposArray,1);
        outxpos=outposArray(end,1);
    end

    inpos=[inxpos,inypos,inxpos+blkwidth,inypos+blkheight];
    outpos=[outxpos,outypos,outxpos+blkwidth,outypos+blkheight];
end













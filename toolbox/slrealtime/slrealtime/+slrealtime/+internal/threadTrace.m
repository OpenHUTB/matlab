classdef threadTrace







    properties(Constant,GetAccess=private)
        thrDecoder=slrealtime.internal.binReader(...
        'uint32','uint32','uint32','uint32','uint32','single','uint32','uint32','uint32');
    end
    properties(SetAccess=private,GetAccess=private)
taskList
    end
    properties(SetAccess=private,GetAccess=public)
rawData
        startTime=uint64(0);
    end
    methods
        function t=threadTrace(traceBin,freq)





            if nargin<2
                freq=1e9;
            end
            if nargin<1
                traceBin='ThreadTrace.bin';
            else
                validateattributes(traceBin,{'string','char'},{'nonempty','row'},...
                '','traceBin');
            end













































            dTrc=dir(traceBin);
            if isempty(dTrc)
                error(message('slrealtime:profiling:FileNotFound',traceBin));
            end
            nBytes=dTrc.bytes;
            N=t.thrDecoder.bytesPerRec;

            nRec=fix(nBytes/N);
            [fid,msg]=fopen(traceBin,'rb');
            if(fid<0)
                error(message('slrealtime:profiling:ProfilingFileError',traceBin,msg));
            end
            rec=fread(fid,nRec*N,'*uint8');
            fclose(fid);
            [event,tsL,tsH,tid,cpu,mdlTime,state,priority,pid]=t.thrDecoder.decode(rec);
            if~isempty(tsL)
                t.startTime=(bitshift(uint64(tsH(1)),32)+uint64(tsL(1)))*1e3/(freq*1e-6);
                ts=(bitshift(uint64(tsH),32)+uint64(tsL))*1e3/(freq*1e-6);
                ts=ts-ts(1);
            end
            t.rawData=struct(...
            'time',ts,...
            'event',event,...
            'tid',tid,...
            'pid',pid,...
            'priority',priority,...
            'cpu',cpu,...
            'mdlTime',mdlTime,...
            'state',state);

        end



        function t=byTid(this,tid)

            t=grep(@(s)s.tid==tid,this.taskList);
        end

        function str=byName(this,name)


            str=grep(@(s)strncmp(s.name,name,numel(name)),this.taskList);
        end

        function str=byPrio(this,prio)

            str=grep(@(s)(s.priority==prio),this.taskList);
        end

        function showData(this,rows)

            raw=this.rawData;
            if nargin<2
                rows=1:numel(raw.cpu);
            end
            assert(isrow(rows),'Not row vector');
            fprintf(1,'%8s | %8s | %3s | %3s | %15s\n',...
            'Suspend','Resume ','CPU','Why','When    ');
            fprintf(1,'%8s | %8s | %3s | %3s | %15s\n',...
            dash(8),dash(8),dash(3),dash(3),dash(15));
            for r=rows
                fprintf(1,'%08x | %08x | %3u | %3u | %15u\n',...
                raw.suspend(r),raw.resume(r),...
                raw.cpu(r),raw.whySusp(r),raw.ts(r));
            end
        end

        function disp(this)
            N=numel(this.taskList);
            fprintf('Start Time: %u (%g s)\n',this.startTime,toSec(this.startTime));
            fmtHead='%-25s | %-8s | %-3s | %5s | %-9s | %-9s\n';
            fprintf(fmtHead,...
            'Task Name',' Handle',...
            'Pri','Calls',' Start At','  End At');
            fprintf(fmtHead,...
            dash(25),dash(8),dash(3),dash(5),dash(9),dash(9));
            for k=1:N
                t=this.taskList(k);
                fprintf('%-25s | %08x | %3d | %5d | %9.4g | %9.4g\n',...
                t.name,t.handle,t.priority,size(t.result,2),...
                toSec(t.startTS),toSec(t.endTS));
            end
        end

        function plot(this)
            nTasks=numel(this.taskList);
            y=1;

            ax=axes(figure);
            ax.YLim=[0,(nTasks+1)];
            names=cell(1,nTasks);

            cMap=[0,0,1;0,1,0;1,0,0;0,1,1;1,0,1;1,1,0;1,0.6,0;0,0,0];

            ax.CLim=[0,size(cMap,1)]-0.2;
            colormap(ax,cMap);
            markers=gobjects(1,nTasks);
            for k=1:nTasks
                s=this.taskList(k);
                res=double(s.result);
                if isempty(res),continue,end
                res(1:2,:)=res(1:2,:)/1e9;
                names{y}=sprintf('%s [%d]',s.name,size(res,2));
                X=res(1,:);
                w=res(2,:);
                Y=ones(size(X))*y;
                c=res(3,:);
                patch([X;X;X+w;X+w],[Y;Y+0.4;Y+0.4;Y],c',...
                'EdgeColor','none');
                markers(y)=line(X,Y-0.2,'LineStyle','none',...
                'Marker','^','MarkerEdgeColor','b','Visible','off');
                y=y+1;
            end
            markers(y:end)=[];
            function markerCallback(src,~)
                if src.Value
                    arrayfun(@(m)set(m,'Visible','on'),markers);
                else
                    arrayfun(@(m)set(m,'Visible','off'),markers);
                end
            end
            uicontrol('Style','checkbox','Position',[10,10,100,20],...
            'Callback',@markerCallback,'String','Show markers');


            ax.YLim=[0,(y+2)];
            ax.YTickLabelMode='manual';
            ax.YTick=1:(y-1);
            ax.YTickLabel=names;
            zoom(ax.Parent,'xon');
            addLegend(ax,max(this.rawData.cpu));

            ax.Title.String='Thread Trace Results';
            ax.XLabel.String='Time';
            set(gcf,'Position',get(0,'Screensize'));
            grid on;
        end
    end
end





function array=grep(f,array)



    array=array(arrayfun(f,array));
end

function ts=toSec(tsu64)
    if tsu64==intmax('uint64')
        ts=inf;
    elseif tsu64==uint64(0)
        ts=-inf;
    else
        ts=double(tsu64)/1e9;
    end
end

function yn=isfile(f)




    yn=~isfolder(f)&&~isempty(dir(f));
end


function addLegend(ax,N)




    x=mean(ax.XLim);
    y=mean(ax.YLim);
    d=min(diff(ax.XLim),diff(ax.YLim))/8;
    g=hggroup(ax);
    for c=0:N
        patch('XData',[x,x,x+d,x+d]','YData',[y,y+d,y+d,y]',...
        'FaceColor','flat','FaceVertexCData',c,...
        'DisplayName',sprintf('CPU %d',c),'Parent',g);
    end
    g.Children=flipud(g.Children);
    g.Visible='off';
    legend(g.Children);
end

function t=summarize(t,tr)



    nTasks=numel(t);
    r=tr.rawData;
    st=tr.startTime;
    assert(all(r.suspend~=r.resume),'Task resuming and suspending at the same time');
    for i=1:nTasks
        task=t(i);
        task.endTS=sub(task.endTS,st);
        task.startTS=sub(task.startTS,st);

        tsIdx=r.ts<=task.endTS&r.ts>=task.startTS;
        suspIdx=find(r.suspend==task.handle&tsIdx);
        resIdx=find(r.resume==task.handle&tsIdx);






        if~isempty(suspIdx)&&(isempty(resIdx)||resIdx(1)>suspIdx(1))
            suspIdx(1)=[];
        end




        if~isempty(resIdx)&&(isempty(suspIdx)||resIdx(end)>suspIdx(end))
            resIdx(end)=[];
        end
        assert(numel(resIdx)==numel(suspIdx),'Unequal sizes');
        assert(all(r.cpu(resIdx)==r.cpu(suspIdx)),'CPU Jump');
        if(~all(r.ts(resIdx)<r.ts(suspIdx)))
resIdx
            rts=r.ts(resIdx)
suspIdx
            sts=r.ts(suspIdx)
        end
        assert(all(r.ts(resIdx)<r.ts(suspIdx)));

        tRes=r.ts(resIdx)-r.ts(1);
        wRes=r.ts(suspIdx)-r.ts(resIdx);
        cpu=r.cpu(resIdx);
        t(i)=task;
        t(i).result=[tRes,wRes,cpu]';
    end
end

function t=sub(t,offset)


    if t==uint64(0)||t==intmax('uint64')
        return
    end
    t=t-offset;
end

function e=dash(n)

    e=repmat('-',1,n);
end

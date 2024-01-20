function varargout=smithplot(obj,varargin)

    OtherInfo='';
    Zs='';
    Z0='';
    Zl='';
    xname='Freq';
    xdata=obj.Frequencies;
    [xdata,~,U]=engunits(xdata);
    xunit=strcat(U,'Hz');

    if nargin>1
        m=varargin{1};
        [varargin{:}]=convertStringsToChars(varargin{:});
    end
    if nargin==1

        v=[1:obj.NumPorts,1:obj.NumPorts];
        ports=unique(nchoosek(v,2),'rows');
        varargin={};
    elseif nargin>1&&((ismatrix(m)&&~isscalar(m)&&isnumeric(m))...
        ||ischar(m)||isstring(m))

        if ischar(m)||isstring(m)
            v=[1:obj.NumPorts,1:obj.NumPorts];
            ports=unique(nchoosek(v,2),'rows');
            varargin=[1,varargin];
        else
            validateattributes(m,{'numeric'},...
            {'integer','positive','2d','nonempty','nonzero','<=',...
            obj.NumPorts,'ncols',2,'finite','real','nonnan'},...
            'smithplot','m',2);
            ports=m;
        end
    else

        n=varargin{2};
        validateattributes(m,{'numeric'},{'integer','scalar','positive','<=',...
        obj.NumPorts,'size',[1,1],'finite','nonempty','real','nonnan',...
        'nonzero'},'smithplot','I',2);
        validateattributes(n,{'numeric'},{'integer','scalar','positive','<=',...
        obj.NumPorts,'size',[1,1],'finite','nonempty','real','nonnan',...
        'nonzero'},'smithplot','J',3);
        ports=[m,n];
        varargin=varargin(2:end);
    end

    obj_new=repmat(obj,size(ports,1),1);
    data=arrayfun(@rfparam,obj_new,ports(:,1),ports(:,2),...
    'UniformOutput',false);
    freq=obj.Frequencies;


    hlgnd=[];
    isParent=find(strcmp(varargin,'Parent'),1);
    isExisting=smithplot('gco');
    flag=0;
    if~isempty(isExisting)
        if ishold||strcmp(isExisting.NextPlot,'add')
            schg=smithplot('gco');
            flag=1;
        end
    elseif isParent
        schg=rf.internal.smithplot.getCurrentPlot(varargin{isParent+1});
        if~isempty(schg)&&strcmp(schg.NextPlot,'add')
            flag=1;
        end
    end

    if flag
        schg.LegendVisible=1;
        tagStr=sprintf('smithplotLegend%d',schg.pAxesIndex);
        hlgnd=findobj(schg.Parent,'Tag',tagStr);
        hlgnd=get(hlgnd,'String');
    end

    if~any(strcmp(varargin,'LegendLabels'))
        lgndtext=arrayfun(@calculateLegendText,obj_new,ports(:,1),ports(:,2),...
        'UniformOutput',false);
        tipcell=simplifytip(obj,lgndtext);
        if~isempty(hlgnd)
            tipcell=horzcat(hlgnd,tipcell');
        end
        p=smithplot(freq,cell2mat(transpose(data)),varargin{2:end},...
        'LegendLabels',tipcell);
    else
        p=smithplot(freq,cell2mat(transpose(data)),varargin{2:end});
        if strcmp(p.NextPlot,'add')
            tipcell=horzcat(hlgnd,p.LegendLabels);
            p.LegendLabels=tipcell;
        else
            tipcell=p.LegendLabels;
        end
    end

    if~iscell(tipcell)
        tipcell={tipcell};
    end

    if size(ports,1)>size(tipcell,1)
        tagStr=sprintf('smithplotLegend%d',p.pAxesIndex);
        hlgnd=findobj(p.Parent,'Tag',tagStr);
        hlgnd=get(hlgnd,'String');
        tipcell=hlgnd(size(hlgnd,2)-size(ports,1)+1:end);
    end

    for nlines=0:size(ports,1)-1
        if~diff(ports(end-nlines,:))&&isa(obj,'sparameters')
            Type='gamma';
            Z0=obj.Impedance;
        else
            Type='';
        end
        linesinfo=p.currentlineinfo(Type,tipcell{end-nlines},...
        xname,xdata,xunit,'None',OtherInfo,Zs,Z0,Zl);
        set(p.hDataLine(end-nlines),'UserData',linesinfo);
    end

    if nargout
        varargout{1}=p;
    end
end

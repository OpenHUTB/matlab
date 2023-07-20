function varargout=smithp(obj,circuitIndices,Z0,varargin)




    direction='SourcetoLoad';
    varargout{:}=smith_matching(obj,circuitIndices,Z0,direction,varargin{:});
end

function hsm=smith_matching(obj,cktplot,Zo,direction,varargin)

    index=find(strcmp(varargin,'Parent'),1);
    if index
        fig=varargin{index+1};
        varargin(index:index+1)=[];
    else
        fig=figure('Name',['Circuit ',num2str(cktplot)],...
        'NumberTitle','off');
    end

    f=obj.CenterFrequency;
    [~,Zl]=obj.interpretImpedanceData(obj.LoadImpedanceData,...
    obj.LoadDataType,obj.CenterFrequency);
    [~,Zin]=obj.interpretImpedanceData(obj.SourceImpedanceData,...
    obj.SourceDataType,obj.CenterFrequency);
    gamma_all=z2gamma([Zin,conj(Zl),conj(Zin),Zl],Zo);
    if strcmpi(direction,'SourcetoLoad')


        gammain=gamma_all(1);
        gammal=gamma_all(2);
        znew=Zin/Zo;
        label1='z_in';
        label2='z_out';

        output=topologyToRfckt(obj.Nets(cktplot,:),...
        obj.Values(cktplot,:),f,Zo);
    elseif strcmpi(direction,'LoadtoSource')


        gammal=gamma_all(3);
        gammain=gamma_all(4);
        znew=Zl/Zo;
        label1='z_out';
        label2='z_in';

        output=topologyToRfckt(flip(obj.Nets(cktplot,:)),...
        flip(obj.Values(cktplot,:)),f,Zo);
    end

    path=zeros(size(output,1),100);
    data_int=zeros(1,size(output,1));
    for i=1:size(output,1)
        if output(i,1)==1
            tempz=linspace(znew,znew+output(i,2),100);
            znew=znew+output(i,2);
        elseif output(i,1)==2
            ynew=(1/znew)+output(i,2);
            temp=linspace((1/znew),ynew,100);
            tempz=1./temp;
            znew=1/ynew;
        end
        g=z2gamma(tempz,1);
        path(i,:)=g;
        data_int(i)=znew;
    end
    path=transpose(path);
    path=path(:);
    tag="z "+(1:size(output,1));
    data_int=[gammain,z2gamma(data_int(1:end-1),1),gammal];
    data_int=repmat(data_int,2,1);
    freq_int=f*ones(size(data_int,1),1);
    freq=f*ones(size(path,1),1);
    [freq,~,U]=engunits(freq);
    xunit=strcat(U,'Hz');




    switch(length(output(:,1)))
    case{2,'L'}
        llabels=[label1,tag(1:end-1),label2,'Matching path'];
        hsm=smithplot(fig,freq_int,data_int,'MarkerSize',10,...
        'GridType','ZY','LineWidth',2,'Marker',{'o','o','o','none'},...
        'LegendLabels',llabels,varargin{:});
        add(hsm,freq,path);
        for nlines=0:size(data_int,2)
            linesinfo=hsm.currentlineinfo('gamma',llabels{end-nlines},...
            'Freq',freq,xunit,'None','',Zin,Zo,Zl);
            set(hsm.hDataLine(end-nlines),'UserData',linesinfo);
        end
    case{3,'Pi','Tee'}
        Q=obj.LoadedQ;
        llabels=["Loaded Q="+num2str(Q),label1,tag(1:end-1)...
        ,label2,'Matching path'];
        hsm=smithplot(fig,'Q',Q,'LegendLabels',llabels,...
        'Marker',{'none','o','o','o','o','none'},'MarkerSize',10,...
        'GridType','ZY','LineWidth',2,varargin{:});
        add(hsm,freq_int,data_int);
        add(hsm,freq,path);

        for nlines=0:size(data_int,2)
            linesinfo=hsm.currentlineinfo('gamma',llabels{end-nlines},...
            'Freq',freq,xunit,'None','',Zin,Zo,Zl);
            set(hsm.hDataLine(end-nlines),'UserData',linesinfo);
        end

    end
    hsm.NextPlot='replace';
end


function output=topologyToRfckt(net,values,f,Zo)
    EMPTY=0;
    SER_CAP=1;
    SER_INDCT=2;
    SHNT_CAP=3;
    SHNT_INDCT=4;
    SER_RES=5;
    SHNT_RES=6;


    output=zeros(numel(net),2);
    for j=1:length(net)
        switch net(j)
        case SER_CAP
            xc=1/(values(j)*2*pi*f*Zo);
            output(j,:)=[1,-1i*xc];
        case SER_INDCT
            xl=(2*pi*f*values(j))/Zo;
            output(j,:)=[1,1i*xl];
        case SHNT_CAP
            bc=2*pi*f*values(j)*Zo;
            output(j,:)=[2,1i*bc];
        case SHNT_INDCT
            bl=Zo/(2*pi*f*values(j));
            output(j,:)=[2,-1i*bl];
        case EMPTY

        otherwise

            error(message('rf:matchingnetwork:UndefinedElement','smithp'));
        end
    end
    output(output(:,1)==0,:)=[];


end

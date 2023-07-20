function simrfV2plotparam(block,dialog)




    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')
        return;
    end








    auxData=get_param([block,'/AuxData'],'UserData');
    cacheData=get_param(block,'UserData');

    if dialog.getSource.isValidProperty('DataSource')
        dataSrc=get_param(dialog.getSource,'DataSource');
    else
        dataSrc='notValidParameter';
    end


    sourceFreq=dialog.getComboBoxText('SourceFreq');
    if strcmpi(sourceFreq,'User-specified')
        userFreqstr=dialog.getWidgetValue('PlotFreq');
        frequnit=dialog.getComboBoxText('PlotFreq_unit');
        xformat=frequnit;
        try
            freqs=evalin('base',userFreqstr);

            rf.internal.checkfreq(freqs)
            freqs=convert2hz(freqs,frequnit);
        catch %#ok<*CTCH>
            blkName=regexprep(block,'\n','');
            error(message('simrf:simrfV2errors:InvalidExpr',...
            blkName,'Frequency',userFreqstr));
        end
    else
        xformat={'Auto'};

        if strcmpi(dataSrc,'Rational model')
            freqs=[0,logspace(0,10,1000)];
        else
            if isempty(auxData)
                blkName=regexprep(block,'\n','');
                error(message('simrf:simrfV2errors:ApplyButton',blkName));
            end
            freqs=auxData.Spars.Frequencies;
        end
    end


    plotType=dialog.getComboBoxText('PlotType');
    if any(strcmpi(plotType,{'Polar plane','Z Smith chart',...
        'Y Smith chart','ZY Smith chart'}))
        yformat={'None'};
        yformat2='None';
    else
        yformat={dialog.getComboBoxText('YFormat1')};
        yformat2=dialog.getComboBoxText('YFormat2');
    end

    yparam={dialog.getComboBoxText('YParam1')};
    yparam2=dialog.getComboBoxText('YParam2');
    if~strcmpi(yparam2,'None')
        yparam=[yparam,{yparam2}];
        yformat=[yformat,{yformat2}];
    end

    switch dialog.getComboBoxText('XOption')
    case 'Linear'
        switch dialog.getComboBoxText('YOption')
        case 'Linear'
            plotfun=@plot;
        otherwise
            plotfun=@semilogy;
        end
    otherwise
        switch dialog.getComboBoxText('YOption')
        case 'Linear'
            plotfun=@semilogx;
        otherwise
            plotfun=@loglog;
        end
    end



    modelingOpt=get_param(dialog.getSource,'SparamRepresentation');
    if~isempty(modelingOpt)&&strcmpi(modelingOpt,'Frequency domain')
        if~isfield(auxData,'Ckt')
            blkName=regexprep(block,'\n','');
            error(message('simrf:simrfV2errors:ApplyButton',blkName));
        end
        if isempty(auxData.Ckt)
            actData=MYrfinterp1(auxData.Spars,freqs);
        elseif regexp(get_param(block,'Model_type'),...
            '^(Coplanar waveguide|Microstrip|Stripline)$')

            tmp=sparameters(auxData.Ckt,freqs);
            actData.Parameters=tmp.Parameters;
            actData.Frequencies=freqs;
            actData.Impedance=real(tmp.Impedance);
            actData.NumPorts=tmp.NumPorts;
        else

            tmp=analyze(auxData.Ckt,freqs);
            actData.Parameters=tmp.AnalyzedResult.S_Parameters;
            actData.Frequencies=freqs;
            actData.Impedance=real(tmp.AnalyzedResult.Z0);
            actData.NumPorts=tmp.nPort;
        end
        fitData=[];
    else
        ratmod=cacheData.RationalModel;
        Poles=ratmod.A;
        Residues=ratmod.C;
        DF=ratmod.D;
        nports=cacheData.NumPorts;
        tmpData.Parameters=ratmodresp(Poles,Residues,DF,freqs,nports);
        tmpData.Frequencies=freqs;
        tmpData.Impedance=cacheData.Impedance;
        tmpData.NumPorts=nports;
        if strcmpi(dataSrc,'Rational model')
            actData=tmpData;
            fitData=[];
        else
            if isempty(auxData.Ckt)
                actData=MYrfinterp1(auxData.Spars,freqs);
            elseif regexp(get_param(block,'Model_type'),...
                '^(Coplanar waveguide|Microstrip|Stripline)$')

                tmp=sparameters(auxData.Ckt,freqs);
                actData.Parameters=tmp.Parameters;
                actData.Frequencies=freqs;
                actData.Impedance=real(tmp.Impedance);
            else

                tmp=analyze(auxData.Ckt,freqs);
                actData.Parameters=tmp.AnalyzedResult.S_Parameters;
                actData.Frequencies=freqs;
                actData.Impedance=real(tmp.AnalyzedResult.Z0);
                actData.NumPorts=size(tmp.AnalyzedResult.S_Parameters,1);
            end
            fitData=tmpData;
        end
    end




    hBlk=get_param(block,'Handle');
    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    mask=Simulink.Mask.get(block);
    maskPars=mask.Parameters;
    allowedParams=maskPars(idxMaskNames.('YParam1')).TypeOptions;
    auxData=collectresponse(auxData,plotType,yparam,yformat,{'Freq'},...
    xformat,allowedParams);
    if numel(unique(auxData.Plot.PlotFormat))==2
        plotType='Plotyy';
    end
    parameters=cell(1,2*length(auxData.Plot.Parameters)+2);
    parameters(1:2:end-2)=auxData.Plot.Parameters;
    parameters(2:2:end-2)=auxData.Plot.PlotFormat;
    parameters(end-1:end)={auxData.Plot.XAxisName,auxData.Plot.XFormat};

    auxData=singleplot(auxData,actData,fitData,plotType,...
    parameters,plotfun,block);


    set_param([block,'/AuxData'],'UserData',auxData);

end


function auxData=collectresponse(auxData,plottype,yparam,yformat,...
    xname,xformat,allowedParams)


    parameters=[auxData.Plot.Parameters,yparam];
    formats=[auxData.Plot.PlotFormat,yformat];


    if needNewPlot(auxData,plottype,paramLabel(parameters,formats),...
        xname,xformat,allowedParams)
        XAxisName=xname;
        XFormat=xformat;
        parameters=yparam;
        formats=yformat;
        if numel(unique(formats))==1
            [parameters,idx]=myunique(parameters);
            formats=formats(idx);
        end
    else

        XAxisName=auxData.Plot.XAxisName;
        XFormat=auxData.Plot.XFormat;
        unique_formats=myunique(formats);
        if numel(unique_formats)==1
            [parameters,idx]=myunique(parameters);
            formats=formats(idx);
        else
            first_format=unique_formats{1};
            idx=strcmp(first_format,formats);
            tempParam1=parameters(idx);
            tempParam2=parameters(~idx);
            tempFormat1=formats(idx);
            tempFormat2=formats(~idx);

            [tempParam1,new_idx]=myunique(tempParam1);
            tempFormat1=tempFormat1(new_idx);
            [tempParam2,new_idx]=myunique(tempParam2);
            tempFormat2=tempFormat2(new_idx);
            parameters=[tempParam1,tempParam2];
            formats=[tempFormat1,tempFormat2];
        end
    end


    auxData.Plot.Parameters=parameters;
    auxData.Plot.PlotFormat=formats;
    auxData.Plot.PlotType=plottype;
    auxData.Plot.XAxisName=XAxisName;
    auxData.Plot.XFormat=XFormat;
end


function result=needNewPlot(auxData,plottype,formats,xaxisname,...
    xformat,allowedParams)


    hfig=auxData.Plot.PlotHandle;
    if isempty(hfig)||~ishghandle(hfig)
        result=true;
    elseif~strcmp(plottype,auxData.Plot.PlotType)
        result=true;
    elseif~strcmp(xaxisname,auxData.Plot.XAxisName)
        result=true;
    elseif~strcmp(xformat,auxData.Plot.XFormat)
        result=true;
    elseif numel(unique(formats))>2
        result=true;
    elseif~isempty(setdiff(auxData.Plot.Parameters,allowedParams))
        result=true;
    else
        result=false;
    end

end


function[out,idx]=myunique(in)
    [~,idx]=unique(in,'first');
    idx=sort(idx);
    out=in(idx);
end

function x=convert2hz(x,funit)

    switch upper(funit)
    case 'KHZ'
        x=1e3*x;
    case 'MHZ'
        x=1e6*x;
    case 'GHZ'
        x=1e9*x;
    case 'THZ'
        x=1e12*x;
    end

end

function auxData=singleplot(auxData,actData,fitData,plottype,...
    params,plotfun,block)



    hfig=auxData.Plot.PlotHandle;
    if isempty(hfig)||~ishghandle(hfig)
        hfig=figure('HandleVisibility','callback');


        auxData.Plot.PlotHandle=hfig;

        top_obj=get_param(bdroot(block),'Object');

        objectID=matlab.lang.makeValidName(...
        [get_param(block,'classname'),'_',get_param(block,'Handle')],...
        'ReplacementStyle','hex');
        if top_obj.hasCallback('PreClose',objectID)

            top_obj.removeCallback('PreClose',objectID);
        end

        top_obj.addCallback('PreClose',objectID,@()simrfV2_delete_plot(hfig))
    end


    delete(get(hfig,'Children'));



    y=[];
    yfit=[];
    f=[];
    ffit=[];
    lstr={};
    lfitstr={};
    for paramidx=1:2:(length(params)-2)
        if regexp(params{paramidx},'[sS]\([1-9][0-9]?,[1-9][0-9]?\)')
            myinput='S';
        else
            myinput='NF';
            if strcmp(plottype,'X-Y plane')&&length(params)>4
                plottype='Plotyy';
            end
        end

        switch myinput
        case 'S'
            fndStr=regexp(params{paramidx},'[1-9][0-9]?,[1-9][0-9]?',...
            'match');
            thislstr=['S_{',fndStr{:},'}'];
            thisfitlstr=['S_{',fndStr{:},'} fit'];
        case 'NF'
            thislstr=params{paramidx};
            thisfitlstr=horzcat(params{paramidx},' fit');
        end


        switch plottype
        case{'X-Y plane','Plotyy'}
            switch params{paramidx}
            case 'NF'
                func=@(x)x;
                funstr='dB';
            otherwise
                switch params{paramidx+1}
                case 'Magnitude (dB)'
                    func=@(x)20*log10(abs(x));
                    funstr='dB';
                case 'Magnitude (linear)'
                    func=@abs;
                    funstr='';
                case 'Angle (degrees)'
                    func=@(x)180*unwrap(angle(x))/pi;
                    funstr='deg';
                case 'Real'
                    func=@real;
                    funstr='real';
                case 'Imaginary'
                    func=@imag;
                    funstr='imag';
                end
            end
            thislstr=horzcat(funstr,'(',thislstr,')');%#ok<AGROW>
            thisfitlstr=horzcat(funstr,'(',thisfitlstr,')');%#ok<AGROW>
        otherwise
            func=@(x)x;
        end

        lstr=horzcat(lstr,thislstr);%#ok<AGROW>
        lfitstr=horzcat(lfitstr,thisfitlstr);%#ok<AGROW>
        needFitPlot=~isempty(fitData);

        switch myinput
        case 'S'
            numMatch=regexp(params{paramidx},'[1-9][0-9]?','match');
            r=str2double(numMatch{1});
            c=str2double(numMatch{2});
            y=nanhorzcat(y,func(squeeze(actData.Parameters(r,c,:))));
            f=nanhorzcat(f,actData.Frequencies(:));
        case 'NF'
            hBlk=get_param(block,'Handle');
            MaskVals=get_param(hBlk,'MaskValues');
            idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
            MaskWSValues=simrfV2getblockmaskwsvalues(hBlk);
            if strcmpi(MaskVals{idxMaskNames.classname},'amplifier')
                if strcmpi(MaskVals{idxMaskNames.Source_linear_gain},...
                    'Data source')&&...
                    strcmpi(MaskVals{idxMaskNames.DataSource},...
                    'Data file')&&~isempty(auxData)&&...
                    isfield(auxData,'Noise')&&...
                    isfield(auxData.Noise,'HasNoisefileData')&&...
                    auxData.Noise.HasNoisefileData==true
                    y=nanhorzcat(y,auxData.Noise.NF);
                    f=nanhorzcat(f,auxData.Noise.Freq(:));
                else
                    if(strcmpi(MaskVals{idxMaskNames.NoiseType},...
                        'Spot noise data'))
                        if(strcmpi(MaskVals{...
                            idxMaskNames.Source_linear_gain},...
                            'Data source'))


                            Z0=auxData.Spars.Impedance;
                        else
                            Z0=50;

                        end
                        minNF=MaskWSValues.MinNF(:);
                        Fmin=10.^(minNF/10);
                        Gopt=MaskWSValues.Gopt(:);
                        Yopt=(1-Gopt)./(1+Gopt)/Z0;
                        RN=MaskWSValues.RN(:);
                        Rn=Z0*RN;
                        blockNF=10*log10(Fmin+...
                        (Rn./real(Yopt)).*abs((1/Z0)-Yopt).^2);
                    else
                        blockNF=MaskWSValues.NF(:);
                    end
                    y=nanhorzcat(y,blockNF);
                    blockFreq=simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreq,...
                    MaskWSValues.CarrierFreq_unit);
                    f=nanhorzcat(f,blockFreq(:));
                end
            else
                y=nanhorzcat(y,auxData.Noise.NF);
                f=nanhorzcat(f,auxData.Noise.Freq(:));
            end
        end

        if needFitPlot
            switch myinput
            case 'S'
                yfit=nanhorzcat(yfit,...
                func(squeeze(fitData.Parameters(r,c,:))));
                ffit=nanhorzcat(ffit,fitData.Frequencies(:));
            case 'NF'
                yfit=nanhorzcat(yfit,nan);
                ffit=nanhorzcat(ffit,nan);
            end
        end
    end


    if needFitPlot
        [~,scale,unitstr]=engunits(max(max(f),max(ffit)));
        ffit=scale*ffit;
    else
        [~,scale,unitstr]=engunits(max(f));
    end
    f=scale*f;


    if size(y,1)==1
        y=vertcat(y,nan(size(y)));
        f=vertcat(f,nan(size(f)));
    end
    if needFitPlot
        if size(yfit,1)==1
            yfit=vertcat(yfit,nan(size(yfit)));
            ffit=vertcat(ffit,nan(size(ffit)));
        end
    end

    switch plottype
    case 'X-Y plane'
        haxes=axes('Parent',hfig);
        if needFitPlot
            nonNFindex=find(strcmp(params(1:2:(length(params)-2)),...
            'NF')~=1);
            fitIndices=[zeros(size(y,2),1);ones(numel(nonNFindex),1)];
            hl=plotfun(haxes,f,y,ffit(:,nonNFindex),yfit(:,nonNFindex));
        else
            hl=plotfun(haxes,f,y);
        end
        ylabel(haxes,params{2})
    case 'Plotyy'
        allLabels=paramLabel(params(1:2:(length(params)-2-1)),...
        params(2:2:(length(params)-2)));
        [label_idx,~,axis_idx]=unique(allLabels,'Stable');
        colorPlot=['k';'m';'c';'r';'g';'b';'y'];
        haxes=axes('Parent',hfig);
        yyaxis(haxes,'left');
        if needFitPlot
            if length(label_idx)>1
                y1=y(:,axis_idx==1);
                f1=f(:,axis_idx==1);
                fitIndices1=zeros(size(y1,2),1);
                if~strcmpi(label_idx{1}(1:2),'NF')
                    y1=nanhorzcat(y1,yfit(:,axis_idx==1));
                    f1=nanhorzcat(f1,f(:,axis_idx==1));
                    fitIndices1=[fitIndices1;...
                    ones(size(yfit(:,axis_idx==1),2),1)];
                end
                y2=y(:,axis_idx==2);
                f2=f(:,axis_idx==2);
                fitIndices2=zeros(size(y2,2),1);
                if~strcmpi(label_idx{2}(1:2),'NF')
                    y2=nanhorzcat(y2,yfit(:,axis_idx==2));
                    f2=nanhorzcat(f2,f(:,axis_idx==2));
                    fitIndices2=[fitIndices2;...
                    ones(size(yfit(:,axis_idx==2),2),1)];
                end
                fitIndices=[fitIndices1;fitIndices2];
            else






                index1=find(strcmp(params(1:2:(length(params)-2)),...
                'NF')==1);
                index2=find(strcmp(params(1:2:(length(params)-2)),...
                'NF')~=1);
                y1=nanhorzcat(y(:,index1));
                fitIndices1=zeros(sum(index1),1);
                y2=nanhorzcat(y(:,index2),yfit(:,index2));
                fitIndices2=[zeros(sum(index2),1);ones(sum(index2),1)];
                f1=nanhorzcat(f(:,index1));
                f2=nanhorzcat(f(:,index2),f(:,index2));
                label_idx{2}=label_idx{1};
                fitIndices=[fitIndices1;fitIndices2];
            end
            if length(colorPlot)<size(y1,2)+size(y2,2)
                colorPlot=repmat(colorPlot,ceil((size(y1,2)+...
                size(y2,2))/length(colorPlot)),1);
            end
            for i=1:size(y1,2)
                if~fitIndices(i)
                    hl1(i)=plotfun(haxes,f1(:,i),y1(:,i),...
                    colorPlot(i),'LineStyle','-',...
                    'Marker','none');%#ok<AGROW>
                    hold(haxes,'on');
                else
                    hl1(i)=plotfun(haxes,f1(:,i),y1(:,i),colorPlot(i),...
                    'LineWidth',2,'LineStyle',':',...
                    'Marker','none');%#ok<AGROW>
                end
            end


            hold(haxes,'off')
            yyaxis(haxes,'right');
            for i=1:size(y2,2)
                if~fitIndices(size(y1,2)+i)
                    hl2(i)=plotfun(haxes,f2(:,i),y2(:,i),...
                    colorPlot(i+size(y1,2)),'LineStyle','-',...
                    'Marker','none');%#ok<AGROW>
                    hold(haxes,'on')
                else
                    hl2(i)=plotfun(haxes,f2(:,i),y2(:,i),...
                    colorPlot(i+size(y1,2)),...
                    'LineWidth',2,'LineStyle',':',...
                    'Marker','none');%#ok<AGROW>
                end
            end
        else
            yleft=y(:,axis_idx==1);
            yright=y(:,axis_idx==2);
            hl1=plotfun(haxes,f(:,axis_idx==1),yleft);
            hl1=reshape(hl1,1,[]);
            yyaxis(haxes,'right');
            hl2=plotfun(haxes,f(:,axis_idx==2),yright);
            hl2=reshape(hl2,1,[]);
        end
        hl=vertcat(hl1',hl2');
        ylabel(haxes,label_idx{2});
        yyaxis(haxes,'left');
        ylabel(haxes,label_idx{1});
        haxes.YAxis(1).Color='k';
        haxes.YAxis(2).Color='k';
    case 'Polar plane'
        if needFitPlot
            nonNFindex=strcmp(params(1:2:(length(params)-2)),'NF')~=1;

            yall=nanhorzcat(y,yfit(:,nonNFindex));
        else
            yall=y;
        end
        [theta,rho]=cart2pol(real(yall),imag(yall));
        theta=theta*180/pi;
        haxes=axes('Parent',hfig);
        hl=polarpattern(haxes,theta(:,1),rho(:,1),'LineWidth',2);
        if size(yall,2)>=2
            for i=2:size(yall,2)
                add(hl,theta(:,i),rho(:,i));
            end
        end

        if builtin('license','test','Antenna_Toolbox')
            hc=hl.UIContextMenu_Master;
            h1c=hc.findobj('Label','Antenna Metrics','-depth',1);
            h1c.Visible='off';
            hm=hc.findobj('Label','Measurements','-depth',1);
            setappdata(hm,'RFMetrics',true);
            hd=hl.UIContextMenu_Grid;
            setappdata(hd,'RFMetrics',true);
        end
    case{'Z Smith chart','Y Smith chart','ZY Smith chart'}
        if needFitPlot
            nonNFindex=strcmp(params(1:2:(length(params)-2)),...
            'NF')~=1;
            yall=nanhorzcat(y,yfit(:,nonNFindex));
            fall=nanhorzcat(f,ffit(:,nonNFindex));
        else
            yall=y;
            fall=f;
        end
        haxes=axes('Parent',hfig);
        hl=smithplot(haxes,fall(:,1)./scale,yall(:,1),...
        'LineWidth',2,'GridType',strtrim(plottype(1:2)));
        if size(yall,2)>=2
            for i=2:size(yall,2)
                add(hl,fall(:,i)./scale,yall(:,i));
            end
        end
    end


    if needFitPlot
        switch plottype
        case 'Polar plane'
            hlfit=1+size(hl.AngleData,2)/2:size(hl.AngleData,2);
        case{'Z Smith chart','Y Smith chart','ZY Smith chart'}
            hlfit=1+size(hl.Data,2)/2:size(hl.Data,2);
        otherwise
            hlfit=hl(logical(fitIndices));
        end
    end


    grid(haxes(1),'on')


    switch plottype
    case{'Polar plane','Z Smith chart','Y Smith chart','ZY Smith chart'}
        hlStyle=[45*ones(size(y,2),1);58*ones(size(yfit,2),1)];
        hl.LineStyle=cellstr(char(hlStyle))';
        hlMarker=repmat({'none'},1,size(yall,2));
        if needFitPlot&&any(strcmp(params,'NF'))
            hlMarker(size(y,2)+ceil(find(strcmp(params,'NF'))/2))=...
            {'square'};
        end
        hl.Marker=hlMarker;
    otherwise
        if~strcmp(plottype,'Plotyy')
            if all(size(hl(1).YData)==[1,2])&&isnan(hl(1).YData(1,2))
                markers={'o','d','+','x'};
                for idx_hl=1:length(hl)
                    markNum=1;
                    if~isinf(hl(idx_hl).YData(1,1))
                        hl(idx_hl).Marker=markers{mod(markNum-1,4)+1};
                        markNum=markNum+1;%#ok<NASGU>
                    end
                end
            end
        end
        if((~strcmp(plottype,'Plotyy'))&&(needFitPlot))
            set(hlfit,'LineWidth',2,'LineStyle',':')
        end
    end


    switch plottype
    case 'Plotyy'
        if needFitPlot
            if length(unique(label_idx))>1
                lstr1=lstr(axis_idx==1);
                if~strcmpi(label_idx{1}(1:2),'NF')
                    lstr1=horzcat(lstr1,lfitstr(axis_idx==1));
                end
                lstr2=lstr(axis_idx==2);
                if~strcmpi(label_idx{2}(1:2),'NF')
                    lstr2=horzcat(lstr2,lfitstr(axis_idx==2));
                end
            else
                lstr1=horzcat(lstr(:,index1),lfitstr(:,index1));
                lstr2=horzcat(lstr(:,index2),lfitstr(:,index2));
            end
        else
            lstr1=lstr(axis_idx==1);
            lstr2=lstr(axis_idx==2);
        end
        legend(haxes,horzcat(lstr1,lstr2))
    otherwise
        if needFitPlot
            nonNFmask=~(strcmp(params(1:2:(length(params)-2)),...
            'NF'));
            lstrall=horzcat(lstr,lfitstr(nonNFmask));
        else
            lstrall=lstr;
        end
        if strcmpi(plottype,'X-Y plane')
            for idx_hl=1:length(hl)
                if any(isinf(hl(idx_hl).YData))
                    lstrall(idx_hl)={[lstrall{idx_hl},' - INF Values']};
                end
            end
        end
        legend(haxes,lstrall)
    end


    set(hfig,'Name',block,'NumberTitle','off')


    xlabel(haxes(1),horzcat('Freq [',unitstr,'Hz]'))

end

function out=paramLabel(paramName,paramFormat)



    out=regexprep(strcat(paramName,{' '},paramFormat),...
    'S[0-9][0-9]','S-param');
end

function out=nanhorzcat(y1,y2)


    [y1r,y1c]=size(y1);
    [y2r,y2c]=size(y2);
    out=nan(max(y1r,y2r),y1c+y2c);

    out(1:y1r,1:y1c)=y1;
    out(1:y2r,(y1c+1):end)=y2;
end

function simrfV2_delete_plot(hfig)
    if~isempty(hfig)&&ishghandle(hfig)
        delete(hfig);
    end
end

function spars=ratmodresp(Poles,Residues,DF,freqs,nport)
    if isempty(Poles)
        Poles(1:nport,1:nport)={0};
    end
    if isempty(Residues)
        Residues(1:nport,1:nport)={0};
    end
    if isempty(DF)
        DF(1:nport^2,1)={0};
    end
    num_freqs=length(freqs);
    spars=zeros(nport,nport,num_freqs);
    if~iscell(DF)
        DF=num2cell(DF);
    end
    [row_idx,col_idx]=ind2sub([nport,nport],1:nport^2);
    for idx=1:nport^2
        hRatMod=rfmodel.rational('A',Poles{idx},'C',Residues{idx},...
        'D',DF{idx});
        spars(row_idx(idx),col_idx(idx),:)=freqresp(hRatMod,freqs);
    end
end

function actData=MYrfinterp1(Spars,freqs)


    resampled=rfdata.data;
    resampled.Freq=Spars.Frequencies;
    resampled.S_Parameters=Spars.Parameters;
    resampled.Z0=Spars.Impedance;
    analyze(resampled,freqs);

    dc_idx=find(abs(freqs)<1e-3);
    resampled.S_Parameters(:,:,dc_idx)=...
    real(resampled.S_Parameters(:,:,dc_idx));
    actData.Parameters=resampled.S_Parameters;
    actData.Frequencies=freqs;
    actData.Impedance=real(resampled.Z0);
    actData.NumPorts=size(resampled.S_Parameters,1);
end


function simrfV2plotfilter(block,dialog)

    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')
        return;
    end
    plotLeft=dialog.getComboBoxText('PlotFuncLeft');
    switch plotLeft
    case 'Voltage transfer'
        plotRight=dialog.getComboBoxText('PlotRightOnVT');
    case 'Phase delay'
        plotRight=dialog.getComboBoxText('PlotRightNoTD');
    case 'Group delay'
        plotRight=dialog.getComboBoxText('PlotRightNoGD');
    case 'Impulse response'
        plotRight=dialog.getComboBoxText('PlotRightNoIR');
    case 'Step response'
        plotRight=dialog.getComboBoxText('PlotRightNoSR');
    end

    switch plotLeft
    case{'Voltage transfer','Phase delay','Group delay'}
        dataPointsStr=dialog.getWidgetValue('FreqPoints');
        dataUnits=dialog.getComboBoxText('Freq_unit');
        xLabelStr='Frequency';
        xLabelUnitStr='Hz';
    otherwise
        dataPointsStr=dialog.getWidgetValue('TimePoints');
        dataUnits=dialog.getComboBoxText('Time_unit');
        xLabelStr='Time';
        xLabelUnitStr='sec';
    end
    try
        dataPoints=evalin('base',dataPointsStr);

        validateattributes(dataPoints,{'numeric'},...
        {'nonempty','vector','real',...
        'finite','nonnegative','increasing'},...
        mfilename,'Data points')
        validateattributes(length(dataPoints),{'numeric'},{'>=',2},...
        mfilename,'Data points')
    catch %#ok<*CTCH>
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:InvalidExpr',...
        blkName,xLabelStr,dataPointsStr));
    end

    xData=simrfV2convert2baseunit(dataPoints,dataUnits);
    mwsv=simrfV2getblockmaskwsvalues(block);
    uData=get_param(block,'UserData');
    switch mwsv.Implementation
    case 'Transfer function'

        filterResponse=@responseRat;
        filtPars=uData.DesignData;
    otherwise

        filterResponse=@responseLC;
        filtPars=rfckt.(lower(regexprep(mwsv.Implementation,' ',...
        mwsv.ResponseType)))('L',uData.DesignData.Inductors,...
        'C',uData.DesignData.Capacitors);
        try
            analyze(filtPars,xData,mwsv.Rsrc,mwsv.Rload,mwsv.Rload);
        catch me
            error(message('simrf:simrfV2errors:FilterPlotInvalid',block));
        end
    end


    switch dialog.getComboBoxText('XaxisScale')
    case 'Linear'
        switch dialog.getComboBoxText('YaxisScale')
        case 'Linear'
            plotfun=@plot;
        otherwise
            plotfun=@semilogy;
        end
    otherwise
        switch dialog.getComboBoxText('YaxisScale')
        case 'Linear'
            plotfun=@semilogx;
        otherwise
            plotfun=@loglog;
        end
    end
    leftForm=dialog.getComboBoxText('PlotLeftForm');
    rightForm=dialog.getComboBoxText('PlotRightForm');
    [ydata1,legendStr1]=filterResponse(filtPars,xData,plotLeft,leftForm);
    hfig=singleplot(block);

    if~strcmpi(plotRight,'None')&&...
        (~strcmpi(plotLeft,plotRight)||~strcmpi(leftForm,rightForm))
        [ydata2,legendStr2]=filterResponse(filtPars,xData,...
        plotRight,rightForm);

        haxes=axes('Parent',hfig);
        yyaxis(haxes,'left');
        hl(1)=plotfun(haxes,xData,ydata1);
        ylabel(haxes,[plotLeft,' [',legendStr1,']']);
        yyaxis(haxes,'right');
        haxes.YAxis(1).Color='k';
        hl(2)=plotfun(haxes,xData,ydata2);
        ylabel(haxes,[plotRight,' [',legendStr2,']']);
        legend(haxes,{plotLeft,plotRight},'Location','Best')
        haxes.YAxis(2).Color='k';
    else
        haxes=axes('Parent',hfig);
        hl(1)=plotfun(haxes,xData,ydata1);
        ylabel(haxes(1),[plotLeft,' [',legendStr1,']']);
    end


    grid(haxes(1),'on')

    set(hl,'LineWidth',2,'LineStyle',':')

    set(hfig,'Name',block,'NumberTitle','off')

    xlabel(haxes(1),[xLabelStr,' [',xLabelUnitStr,']']);
end



function hfig=singleplot(block)
    figureID=matlab.lang.makeValidName(...
    [get_param(block,'classname'),'_',get_param(block,'Handle')],...
    'ReplacementStyle','hex');
    hfig=findall(0,'Type','Figure','Tag',figureID);
    top_obj=get_param(bdroot(block),'Object');

    if top_obj.hasCallback('PreClose',figureID)
        top_obj.removeCallback('PreClose',figureID);
    end

    if~isempty(hfig)&&ishghandle(hfig)
        delete(hfig)
    end

    hfig=figure('HandleVisibility','callback','Tag',figureID);

    top_obj.addCallback('PreClose',figureID,@()delete_plot(hfig))
end

function[yData,legendStr]=responseRat(ratFcns,xData,...
    funcType,dataForm)

    num=simrfV2_quad2poly(ratFcns.Numerator21);
    den=simrfV2_quad2poly(ratFcns.Denominator);
    switch funcType
    case 'Voltage transfer'
        omega=2*pi*xData;
        legendStrFunc='VT';
        switch dataForm
        case 'Angle (degrees)'
            angNum=anglePoly(num,omega);
            angDen=anglePoly(den,omega);
            ydata=angNum-angDen;
        otherwise
            ydata=polyeval21(ratFcns,omega);
        end
    case 'Phase delay'
        omega=2*pi*xData;
        legendStrFunc='TD';
        angNum=anglePoly(num,omega);
        angDen=anglePoly(den,omega);
        ydata=angNum-angDen;
        ydata=ydata./omega;
    case 'Group delay'
        omega=2*pi*xData;
        legendStrFunc='GD';
        grpNum=groupPoly(num,omega);
        grpDen=groupPoly(den,omega);
        ydata=grpDen-grpNum;
    end

    [yData,legendStrForm]=dataForPlot(ydata,dataForm);
    legendStr=[legendStrForm,' (',legendStrFunc,')'];
end

function ydata=polyeval21(designData,omega)

    num=designData.Numerator21;
    den=designData.Denominator;
    denEval=polyvalCoeff(den,1i*omega);
    flag=0;
    if isfield(designData,'Auxiliary')
        if isfield(designData.Auxiliary,'Numerator21Polynomial')
            flag=1;
            numEval=polyvalCoeff(designData.Auxiliary.Numerator21Polynomial,...
            1i*omega);
        end
    end
    if~flag||any(isinf(prod(numEval,1)))||any(isinf(prod(denEval,1)))
        numEval=polyvalCoeff(num,1i*omega);
        ydata=prod(numEval./denEval,1);
    else
        ydata=prod(numEval,1)./prod(denEval,1);
    end
end

function values=polyvalCoeff(coeff,x_data)

    func=@(x)polyval(x,x_data);
    if size(coeff,1)==1
        values=func(coeff);
    else
        scell_coeff=mat2cell(coeff,ones(1,size(coeff,1)),size(coeff,2));
        values=cell2mat(cellfun(func,scell_coeff,'UniformOutput',false));
    end
end

function[yData,legendStr]=responseLC(lcFilt,xData,funcType,dataForm)

    switch funcType
    case 'Voltage transfer'
        switch dataForm
        case 'Angle (degrees)'
            ydata=cell2mat(calculate(lcFilt,'S21','Angle (degrees)'));
        otherwise
            ydata=cell2mat(calculate(lcFilt,'S21','Magnitude (linear)'));
        end
    case 'Phase delay'
        ydata=cell2mat(calculate(lcFilt,'S21','Angle (degrees)'));
        ydata=ydata'./(2*pi*xData);
    case 'Group delay'
        ydata=lcFilt.AnalyzedResult.GroupDelay;
    end

    [yData,legendStr]=dataForPlot(ydata,dataForm);
end

function[yDataOut,legendStrForm]=dataForPlot(ydata,dataForm)
    switch dataForm
    case 'Magnitude (dB)'
        yDataOut=20*log10(abs(ydata));
        yDataOut(yDataOut>0)=0;
        legendStrForm='Mag dB';
    case 'Magnitude (linear)'
        yDataOut=abs(ydata);
        yDataOut(yDataOut>1)=1;
        legendStrForm='Mag';
    case 'Angle (degrees)'
        yDataOut=ydata;
        legendStrForm='deg';
    case 'Real'
        yDataOut=real(ydata);
        legendStrForm='real';
    case 'Imaginary'
        yDataOut=imag(ydata);
        legendStrForm='imag';
    end
end


function angPoly=anglePoly(polyCoeffs,omega)
    angReal=@(zeroes,omega)atand(omega./(-zeroes));
    angCplx=@(zeroes,omega)atan2d(-2*real(zeroes).*omega,...
    (real(zeroes).^2+imag(zeroes).^2-omega.^2));
    [zeroes,numCplx]=simrfV2topconj(roots(polyCoeffs));
    lenZeroes=length(zeroes);
    if lenZeroes==0
        angPoly=0;
    else
        if numCplx==0
            angPoly=sum(bsxfun(angReal,zeroes,omega),1);
        elseif numCplx==lenZeroes
            angPoly=sum(bsxfun(angCplx,zeroes,omega),1);
        else
            angPoly=sum(bsxfun(angCplx,zeroes(1:numCplx),omega),1)+...
            sum(bsxfun(angReal,zeroes(numCplx+1:end),omega),1);
        end
    end
end

function grpPoly=groupPoly(polyCoeffs,omega)
    grpReal=@(zeroes,omega)zeroes./(zeroes.^2+omega.^2);
    grpCplx=@(zeroes,omega)2*real(zeroes).*...
    (real(zeroes).^2+imag(zeroes).^2+omega.^2)./...
    ((real(zeroes).^2+imag(zeroes).^2-omega.^2).^2+...
    (2*real(zeroes)*omega).^2);

    [zeroes,numCplx]=simrfV2topconj(roots(polyCoeffs));
    lenZeroes=length(zeroes);
    if lenZeroes==0
        grpPoly=0;
    else
        if numCplx==0
            grpPoly=sum(bsxfun(grpReal,zeroes,omega),1);
        elseif numCplx==lenZeroes
            grpPoly=sum(bsxfun(grpCplx,zeroes,omega),1);
        else
            grpPoly=sum(bsxfun(grpCplx,zeroes(1:numCplx),omega),1)+...
            sum(bsxfun(grpReal,zeroes(numCplx+1:end),omega),1);
        end
    end
end


function delete_plot(hfig)

    if~isempty(hfig)&&ishghandle(hfig)
        delete(hfig);
    end
end



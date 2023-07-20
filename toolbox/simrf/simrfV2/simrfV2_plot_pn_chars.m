function simrfV2_plot_pn_chars(this)






    hBlk=get_param(this,'Handle');
    objBlk=get_param(this,'Object');
    BlkFullName=objBlk.getFullName;

    idxMaskNames=simrfV2getblockmaskparamsindex(hBlk);
    OpenDialogs=this.getOpenDialogs;
    panelHasChanges=OpenDialogs{1}.hasUnappliedChanges;



    if isfield(idxMaskNames,'LOFreq')
        CarrFreqField={'LOFreq','Local oscillator frequency'};
        CarrFreq_uField={'LOFreq_unit','Local oscillator frequency'};
        AutoImpLenField={'AutoImpulseLengthPN',...
        'Automatically estimate impulse response duration'};
        ImpLenField={'ImpulseLengthPN','Impulse response duration'};
        ImpLen_uField={'ImpulseLength_unitPN',...
        'Impulse response duration'};
    else
        CarrFreqField={'CarrierFreq','Carrier frequencies'};
        CarrFreq_uField={'CarrierFreq_unit','Carrier frequencies'};
        AutoImpLenField={'AutoImpulseLength',...
        'Automatically estimate impulse response duration'};
        ImpLenField={'ImpulseLength','Impulse response duration'};
        ImpLen_uField={'ImpulseLength_unit',...
        'Impulse response duration'};
    end
    [~,RefBlkName]=fileparts(get(hBlk,'ReferenceBlock'));


    if panelHasChanges
        maskStrings=get_param(this,'MaskValues');
        if~strcmp(OpenDialogs{1}.getWidgetValue(CarrFreqField{1}),...
            maskStrings{idxMaskNames.(CarrFreqField{1})})
            msg=sprintf(['Changes to dialog parameter ',CarrFreqField{2}...
            ,' exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        elseif~strcmp(OpenDialogs{1}.getComboBoxText(CarrFreq_uField{1}),...
            maskStrings{idxMaskNames.(CarrFreq_uField{1})})
            msg=sprintf(['Changes to the unit of dialog parameter '...
            ,CarrFreqField{2},' exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue('PhaseNoiseOffset'),...
            maskStrings{idxMaskNames.PhaseNoiseOffset})
            msg=sprintf(['Changes to dialog parameter Phase noise '...
            ,'offset (Hz) exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue('PhaseNoiseLevel'),...
            maskStrings{idxMaskNames.PhaseNoiseLevel})
            msg=sprintf(['Changes to dialog parameter Phase noise level '...
            ,'(dBc/Hz) exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        elseif~OpenDialogs{1}.getWidgetValue(AutoImpLenField{1})==...
            strcmp(maskStrings{idxMaskNames.(AutoImpLenField{1})},'on')
            msg=sprintf(['Changes to dialog parameter ',AutoImpLenField{2}...
            ,' exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        elseif~strcmp(OpenDialogs{1}.getWidgetValue(ImpLenField{1}),...
            maskStrings{idxMaskNames.(ImpLenField{1})})
            msg=sprintf(['Changes to dialog parameter ',ImpLenField{2}...
            ,' exists. Press Apply and try again.']);
            errordlg([BlkFullName,': ',msg],...
            ['RF Blockset ',RefBlkName,' block Error']);
            return
        else
            mo=get_param(this,"MaskObject");
            typeOpts=...
            mo.Parameters(idxMaskNames.(ImpLen_uField{1})).TypeOptions;
            if~strcmp(typeOpts{...
                OpenDialogs{1}.getWidgetValue(ImpLen_uField{1})+1},...
                maskStrings{idxMaskNames.(ImpLen_uField{1})})
                msg=sprintf(['Changes to the unit of dialog parameter '...
                ,ImpLen_uField{2},' exists. Press Apply and try again.']);
                errordlg([BlkFullName,': ',msg],...
                ['RF Blockset ',RefBlkName,' block Error']);
                return
            end
        end
    end


    maskWSValues=simrfV2getblockmaskwsvalues(hBlk);
    if isempty(maskWSValues.(CarrFreqField{1}))
        error(['Parameter ',CarrFreqField{2},' not defined.'])
    end
    if strcmp(CarrFreqField{1},'LOFreq')

        validateattributes(maskWSValues.(CarrFreqField{1}),{'numeric'},...
        {'nonempty','scalar','positive','finite'},'',CarrFreqField{2});
        if isempty(maskWSValues.PhaseNoiseOffset)
            error('Parameter Phase noise offset (Hz) not defined.')
        end

        validateattributes(maskWSValues.PhaseNoiseOffset,{'numeric'},...
        {'nonempty','vector','positive','finite'},'',...
        'Phase noise frequency offsets');
        if isempty(maskWSValues.PhaseNoiseLevel)
            error('Parameter Phase noise level (dBc/Hz)s not defined.')
        end

        validateattributes(maskWSValues.PhaseNoiseLevel,{'numeric'},...
        {'nonempty','vector','real'},'',...
        'Phase noise level');
        if isempty(maskWSValues.(ImpLenField{1}))
            error(['Parameter ',ImpLenField{2},' not defined.'])
        end
    end

    [CarrFreqSorted,PhNoFreq,phNoLevIntNorm,step,phNoOffFull,...
    phNoLevFull,stepSource]=simrfV2getphasenoise(BlkFullName);


    Udata=get_param(hBlk,'UserData');
    if~isfield(Udata,'FigHandle')||isempty(Udata.FigHandle)||...
        ~ishghandle(Udata.FigHandle)
        hfig=figure;
        Udata.FigHandle=hfig;
        set_param(hBlk,'UserData',Udata)
    else
        hfig=Udata.FigHandle;
        figure(hfig)
    end
    clf(hfig)
    hAxes=gca(hfig);

    if~isempty(PhNoFreq)&&~isempty(phNoLevIntNorm)
        actResolution=PhNoFreq(1,2)-PhNoFreq(1,1);
        imp=rfsolver.ImpulseResponse(step,...
        size(PhNoFreq,2)*ones(size(PhNoFreq,1),1),0,PhNoFreq(1,:),...
        sqrt(phNoLevIntNorm),2*ones(size(PhNoFreq,1),1));
        H2=fft(imp,[],2);

        if length(CarrFreqSorted)==1
            halfFreqs=abs(PhNoFreq(length(PhNoFreq)/2+1:-1:1));
            semilogx(hAxes,halfFreqs,...
            20*log10(abs(H2(1:length(PhNoFreq)/2+1))),'xg',halfFreqs,...
            10*log10(phNoLevIntNorm(length(PhNoFreq)/2+1:-1:1)),'+',...
            phNoOffFull,phNoLevFull,'ok')
            lgd=legend(hAxes,'Filter Response','Design Specification',...
            'Phase Noise Specification','location','southwest',...
            'AutoUpdate','off');
        else
            co=colororder(hAxes);
            legStr=cell(3*length(CarrFreqSorted),1);
            halfLen=size(PhNoFreq,2)/2;
            halfFreqs=abs(PhNoFreq(:,halfLen+1:-1:1));
            for carrInd=1:length(CarrFreqSorted)
                semilogx(hAxes,halfFreqs(carrInd,:),...
                20*log10(abs(H2(carrInd,1:halfLen+1))),'x',...
                halfFreqs(carrInd,:),...
                10*log10(phNoLevIntNorm(carrInd,halfLen+1:-1:1)),'+',...
                phNoOffFull(:,carrInd),phNoLevFull(:,carrInd),'o',...
                'Color',co(carrInd,:))
                hold(hAxes,'on');
                [evaluatedCF,unitCF]=engUnitsHz(CarrFreqSorted(carrInd));
                carrStr=sprintf('Carrier = %g%s',evaluatedCF,unitCF);
                legStr((carrInd-1)*3+1:carrInd*3)=...
                {['Filter Resp., ',carrStr],...
                ['Design Spec., ',carrStr],...
                ['Phase Noise Spec., ',carrStr]};
            end
            hold(hAxes,'off');
            lgd=legend(hAxes,legStr,'AutoUpdate','off');
        end
        matlabshared.internal.InteractiveLegend(lgd);
        [evaluatedSR,unitSR]=engUnitsHz(1/step);
        [evaluatedActRes,unitActRes]=engUnitsHz(actResolution);
        xlabel(hAxes,sprintf(...
        'Frequency\n(%s=%g %s with Resolution=%g %s)',...
        stepSource,evaluatedSR,unitSR,evaluatedActRes,unitActRes));
        ylabel(hAxes,'dBc/Hz')
        title(hAxes,'Phase Noise Magnitude Response')
        grid(hAxes,'on')
    else
        axis(hAxes,'off');
        text(0.5,0.5,'No phase noise introduced','FontSize',14,...
        'HorizontalAlignment','center');
    end

end

function[evaluatedSR,unitSR]=engUnitsHz(sampleRate)
    if sampleRate<1
        evaluatedSR=sampleRate;
        unitSR='';
    else
        [evaluatedSR,evaluatedSR_exp,unitSR]=...
        engunits(sampleRate);
        if(evaluatedSR_exp<1e-9)
            evaluatedSR=evaluatedSR*(1/(evaluatedSR_exp))*1e-9;
            unitSR='G';
        end
    end
    unitSR=[unitSR,'Hz'];
end
function simrfV2dlg_mixerimt_plot(block,~)

    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')
        return;
    end

    dialog=simrfV2_find_dialog(block);

    if dialog.hasUnappliedChanges
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:ApplyButton',blkName));
    end
    mwsv=simrfV2getblockmaskwsvalues(block);
    uData=get_param(block,'UserData');

    validateattributes(mwsv.PowerOut,...
    {'numeric'},{'nonempty','scalar','finite','real'},...
    '','Desired mixer output signal power (dBm)');

    if strcmp(mwsv.UseDataFile,'on')
        if isempty(uData)
            spurData=mwsv.UserSpurValues;
            rfPower=mwsv.PowerRF;
            ifPower=mwsv.PowerLO;
        elseif uData.hasFileIMT
            spurData=uData.IMT.SpurValues;
            rfPower=mwsv.PowerRF_Data;
            if uData.hasFileSpars
                ifPower=mwsv.PowerLO_Data;
            else
                ifPower=mwsv.PowerLO_DataNoAC;
            end
        elseif uData.hasFileSpars
            spurData=mwsv.UserSpurValues;
            rfPower=mwsv.PowerRF_DataNoIMT;
            ifPower=mwsv.PowerLO_Data;
        else
            spurData=mwsv.UserSpurValues;
            rfPower=mswv.PowerRF_DataNoIMT;
            ifPower=mswv.PowerLO_DataNoAC;
        end
    else
        spurData=mwsv.UserSpurValues;
        rfPower=mwsv.PowerRF;
        ifPower=mwsv.PowerLO;
    end


    spurs=rfdata.mixerspur('Data',spurData,'PinRef',rfPower,...
    'PLORef',ifPower);
    sizeSpurs=size(spurs.Data);
    bigSpurs=ones(sizeSpurs(1)+2,sizeSpurs(2)+2)*99;
    bigSpurs(1:sizeSpurs(1),1:sizeSpurs(2))=spurs.Data;
    spurs.Data=bigSpurs;
    if uData.hasFileSpars
        netwk=rfdata.network('Data',uData.Spars.Parameters,...
        'Freq',uData.Spars.Frequencies,'Type',...
        uData.Spars.OrigParamType,'Z0',uData.Spars.Impedance);
    else
        netwk=[];
    end
    mixer=rfckt.mixer('FLO',mwsv.FrequencyLO,'MixerSpurData',spurs,...
    'MixerType',mwsv.MixerType,'NetworkData',netwk);
    figureID=matlab.lang.makeValidName(...
    [get_param(block,'classname'),'_'...
    ,num2str(get_param(block,'Handle'))],'ReplacementStyle','hex');
    hfig=findall(0,'Type','Figure','Tag',figureID);

    top_obj=get_param(bdroot(block),'Object');

    if top_obj.hasCallback('PreClose',figureID)
        top_obj.removeCallback('PreClose',figureID);
    end

    if~isempty(hfig)&&ishghandle(hfig)
        delete(hfig)
    end

    hlines=plot(mixer,'mixerspur',1,mwsv.PowerOut,mwsv.FrequencyRF);
    hfig=get(get(hlines(1),'Parent'),'Parent');
    hfig.HandleVisibility='callback';
    hfig.Tag=figureID;

    top_obj.addCallback('PreClose',figureID,@()delete_plot(hfig))
    set(hfig,'Name',block,'NumberTitle','off')

end



function delete_plot(hfig)

    if~isempty(hfig)&&ishghandle(hfig)
        delete(hfig);
    end
end



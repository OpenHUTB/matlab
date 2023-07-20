function updateREMapping(obj,ax,bwpIdx,channel,selectedRow,resetFlag,useJava)









    waveconfig=[];
    msg='';
    try
        waveconfig=getConfiguration(obj);
    catch ME
        msg=ME.message;
    end

    fig=ax.Parent;
    chk=obj.RECheckbox{bwpIdx};
    if isempty(chk)||~ishghandle(chk)




        reChk=uicontrol('Parent',fig,'Style','checkbox','Tag','RECheckbox');
        if useJava
            reChk.String=getString(message('nr5g:waveformGeneratorApp:RECheckboxStringJava'));
        else
            reChk.String{1}=getString(message('nr5g:waveformGeneratorApp:RECheckboxStringJFLine1'));
            reChk.String{2}=getString(message('nr5g:waveformGeneratorApp:RECheckboxStringJFLine2'));
        end
        reChk.Tooltip=getString(message('nr5g:waveformGeneratorApp:RECheckboxTT'));
        reChk.Callback=@wirelessWaveformGenerator.internal.plotResourceGridRE;
        reChk.UserData=struct('Obj',obj,'Axes',ax,'Waveconfig',waveconfig,'BPIndex',bwpIdx,'Channel',channel,'SelectedRow',selectedRow,'Msg',msg);
        updateCheckboxVisibility(reChk,channel);
    else
        reChk=chk(1);


        reChk.UserData.Obj=obj;
        reChk.UserData.Axes=ax;
        reChk.UserData.Msg=msg;
        if~isempty(msg)






        else

            reChk.UserData.Waveconfig=waveconfig;
            reChk.UserData.BPIndex=bwpIdx;
            reChk.UserData.Channel=channel;
            reChk.UserData.SelectedRow=selectedRow;
        end

        if resetFlag

            reChk.Value=0;
        end


        rbgridFigResizedCallback([],[],obj,fig,bwpIdx);
        updateCheckboxVisibility(reChk,channel);


        wirelessWaveformGenerator.internal.plotResourceGridRE(reChk,[]);
    end


    obj.RECheckbox{bwpIdx}=reChk;

    if resetFlag


        reAx=findall(fig,'Tag','REAxes');
        delete(reAx);
    end

end

function updateCheckboxVisibility(chk,channel)



    if contains(channel,{'PDSCH','PDCCH','CSI-RS','PUSCH','PUCCH','SRS'})
        chk.Visible='on';
    else
        chk.Visible='off';
    end
end
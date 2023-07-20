function mplayconnect(BlockHandle)







    ioSigs=get_param(BlockHandle,'IOSignals');


    mPlayUD=get_param(BlockHandle,'UserData');

    hSrcSL=mPlayUD.hMPlay.getExtInst('Sources','Simulink');
    if ishandle(ioSigs{1}(1).Handle)
        nIOSigs=length(ioSigs{1});
        lSig=[];
        for j=1:nIOSigs

            hLine=get_param(ioSigs{1}(j).Handle,'line');
            if ishandle(hLine)
                lSig=[lSig,hLine];%#ok<AGROW>
            end
        end
        hSrcSL.DataConnectArgs={lSig};
        updateScopeCLI(hSrcSL);
        mPlayUD.hMPlay.connectToDataSource(hSrcSL);
    else
        try

            releaseData(mPlayUD.hMPlay);
            screenMsg(mPlayUD.hMPlay,'No signal selected');
        catch mexception %#ok<NASGU>

        end
    end



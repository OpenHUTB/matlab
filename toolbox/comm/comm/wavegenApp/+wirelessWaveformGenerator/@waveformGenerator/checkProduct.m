function exists=checkProduct(obj,baseCode,varargin)




    exists=true;


    isSupportPackage=false;
    if nargin>2
        propSet=varargin{1};
        spProp=propSet.findProperty('SupportPackage');
        if~isempty(spProp)&&spProp.Value
            isSupportPackage=true;
        end
    end

    if isSupportPackage

        SPs=matlab.addons.installedAddons;
        productName=propSet.getPropValue('ProductName');
        if strcmp(productName,'Communications Toolbox Library for ZigBee and UWB')
            msgID='comm:waveformGenerator:Need2InstallFreeWave';
            name=obj.pCurrentWaveformType;
        else

            msgID='comm:waveformGenerator:Need2InstallFreeRadio';
            name=obj.pCurrentHWTag;
        end

        if isempty(SPs)||~any(strcmp(SPs.Name,productName))
            exists=false;







        end
    else

        productName=propSet.getPropValue('ProductName');
        verDir=propSet.getPropValue('ToolboxDir');
        licName=propSet.getPropValue('LicenseFcnIn');

        if strcmp(baseCode,'IC')
            msgID='comm:waveformGenerator:Need2InstallNoAddOn';
            msg=getString(message(msgID,productName));
        elseif strcmp(baseCode,'WB')
            msgID='comm:waveformGenerator:Need2InstallWirelessTestbench';
            msg=getString(message(msgID));
        else
            msgID='comm:waveformGenerator:Need2Install';
            name=obj.pCurrentWaveformType;
        end

        if isempty(ver(verDir))
            exists=false;
        end
    end

    if isSupportPackage||~any(strcmp(baseCode,["IC","WB"]))
        msg=getString(message(msgID,productName,name));
    end


    if~exists

        eFig=errordlg(msg,...
        getString(message('comm:waveformGenerator:DialogTitle')),'modal');

        if~strcmp(baseCode,'IC')
            okBtn=findall(eFig,'Tag','OKButton');
            okBtn.Callback=@(a,b)okCallback(baseCode,[]);
        end

        uiwait(eFig);

    elseif~isSupportPackage&&~license('checkout',licName)

        exists=false;
        eFig=errordlg(getString(message('comm:waveformGenerator:NoLicense',productName)),...
        getString(message('comm:waveformGenerator:DialogTitle')),'modal');
        uiwait(eFig);
    else
        exists=true;
    end

end



function okCallback(baseCode,~)

    delete(gcbf);

    matlab.addons.supportpackage.internal.explorer.showSupportPackages(baseCode,'AddOns');
end
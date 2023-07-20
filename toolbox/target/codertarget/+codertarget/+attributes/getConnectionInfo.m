function connectionInfo=getConnectionInfo(hCS)





    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
    connectionInfo=struct();
    if isprop(targetInfo,'ExternalModeInfo')
        extmodeInfo=targetInfo.ExternalModeInfo;
        if~isempty(extmodeInfo)
            for ii=1:numel(extmodeInfo)
                if isequal(extmodeInfo(ii).Transport.Type,'tcp/ip')
                    lConnection=struct('IPAddress',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.IPAddress.value,targetInfo.Tokens),...
                    'Port',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.Port.value,targetInfo.Tokens),...
                    'Verbose',extmodeInfo(ii).Transport.Verbose.value);
                elseif isequal(extmodeInfo(ii).Transport.Type,'serial')
                    lConnection=struct('Baudrate',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.Baudrate.value,targetInfo.Tokens),...
                    'COMPort',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.COMPort.value,targetInfo.Tokens),...
                    'Verbose',extmodeInfo(ii).Transport.Verbose.value);
                elseif isequal(extmodeInfo(ii).Transport.Type,'can')
                    lConnection=struct('CANVendor',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.CANVendor.value,targetInfo.Tokens),...
                    'CANDevice',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.CANDevice.value,targetInfo.Tokens),...
                    'CANChannel',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.CANChannel.value,targetInfo.Tokens),...
                    'BusSpeed',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.BusSpeed.value,targetInfo.Tokens),...
                    'CANIDCommand',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.CANIDCommand.value,targetInfo.Tokens),...
                    'CANIDResponse',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.CANIDResponse.value,targetInfo.Tokens),...
                    'IsCANIDExtended',extmodeInfo(ii).Transport.IsCANIDExtended.value,...
                    'Verbose',extmodeInfo(ii).Transport.Verbose.value);
                elseif isequal(extmodeInfo(ii).Transport.Type,'custom')
                    lConnection=struct('MEXArgs',codertarget.utils.replaceTokens(hCS,extmodeInfo(ii).Transport.MEXArgs.value,targetInfo.Tokens));
                end
                if targetInfo.ExternalModeInfo(ii).Task.InBackground&&targetInfo.ExternalModeInfo(ii).Task.InForeground
                    lConnection.RunInBackground=isequal(extmodeInfo(ii).Task.Default,'background');
                end
                connectionInfo.(regexprep(extmodeInfo(ii).Transport.IOInterfaceName,'\W',''))=lConnection;
            end
        end
    end
end
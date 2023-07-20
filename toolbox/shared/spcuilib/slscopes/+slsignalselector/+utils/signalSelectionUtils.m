function varargout=signalSelectionUtils(varargin)














    Action=varargin{1};
    args=varargin(2:end);

    try
        switch Action
        case 'GetSelection'
            hBlock=args{1};
            AxesNumber=args{2};

            signalHandles=get_param(hBlock,'IOSignals');
            if isempty(signalHandles)||numel(signalHandles)==1&&isempty(signalHandles{1})
                ports=struct('Handle',-1,'RelativePath','');
                signalHandles{1}=ports;
            end
            varargout{1}=[signalHandles{AxesNumber}.Handle];

        case 'AddSelection'
            hBlock=args{1};
            AxesNumber=args{2};
            addSelHandle=args{3};

            if iscell(addSelHandle)
                addSelHandle=[addSelHandle{:}]';
            end

            if(isempty(addSelHandle))
                return
            end

            Simulink.scopes.Util.AddSelection(hBlock,AxesNumber,addSelHandle);
            slsignalselector.utils.updateSSMConnectedSignals(hBlock);

        case 'RemoveSelection'
            hBlock=args{1};
            AxesNumber=args{2};
            remSelHandle=args{3};

            if iscell(remSelHandle)
                remSelHandle=[remSelHandle{:}]';
            end

            if(isempty(remSelHandle))
                return
            end

            Simulink.scopes.Util.RemoveSelection(hBlock,AxesNumber,remSelHandle);
            slsignalselector.utils.updateSSMConnectedSignals(hBlock);

        case 'AddStateflowSelection'
            hBlock=args{1};
            AxesNumber=args{2};
            addSelHandle=args{3};
            addRelPath=args{4};

            ioSigs=get_param(hBlock,'IOSignals');
            ioSigs=Simulink.scopes.Util.RemoveInvalHandles(ioSigs,AxesNumber);
            axIOSigs=ioSigs{AxesNumber};
            for i=1:length(addSelHandle)
                hp=addSelHandle(i);
                if ishandle(hp)
                    axIOSigs(end+1)=struct('Handle',hp,'RelativePath',addRelPath);%#ok<AGROW>
                end
            end
            [~,i,~]=unique([axIOSigs.Handle],'stable');
            axIOSigs=axIOSigs(i);
            ioSigs{AxesNumber}=axIOSigs;

            set_param(hBlock,'IOSignals',ioSigs);

        case 'SwitchSelectionStateflow'
            hBlock=args{1};
            AxesNumber=args{2};
            addSelHandle=args{3};
            addRelPath=args{4};

            ioSigs=get_param(hBlock,'IOSignals');
            ioSigs{AxesNumber}=struct('Handle',addSelHandle,'RelativePath',addRelPath);
            set_param(hBlock,'IOSignals',ioSigs);
        end
    catch ex
        varargout{1}.error=true;
        if isa(ex,'MException')
            varargout{1}.faultMessage=ex.message;
        end
    end
function opcslwrite(block)


    grp=[];
    writeMode=0;
    tfItm=[];
    locItm=[];
    errState=[];

    setup(block);


    function setup(block)
        itemIDs=parseitemids(block.DialogPrm(3).Data);
        updateRate=block.DialogPrm(4).Data;
        writeMode=block.DialogPrm(5).Data;

        block.NumInputPorts=1;
        block.NumOutputPorts=0;
        block.SetPreCompInpPortInfoToDynamic;

        block.InputPort(1).DatatypeID=-1;
        block.InputPort(1).Complexity='Real';
        block.InputPort(1).SamplingMode='Sample';
        block.InputPort(1).Dimensions=max(1,length(itemIDs));

        block.NumDialogPrms=5;
        block.DialogPrmsTunable=repmat({'Nontunable'},1,5);

        if updateRate==0,

            minorRate=1.0;
        else
            minorRate=0.0;
        end
        block.SampleTimes=[updateRate,minorRate];

        block.SetAccelRunOnTLC(false);
        block.RegBlockMethod('CheckParameters',@CheckPrms);

        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);

        block.RegBlockMethod('ProcessParameters',@ProcessPrms);

        block.RegBlockMethod('InitializeConditions',@InitializeConditions);

        block.RegBlockMethod('Start',@Start);

        block.RegBlockMethod('Outputs',@Outputs);

        block.RegBlockMethod('Update',@Update);

        block.RegBlockMethod('Derivatives',@Derivatives);

        block.RegBlockMethod('Projection',@Projection);

        block.RegBlockMethod('ZeroCrossings',@ZeroCrossings);

        block.RegBlockMethod('SimStatusChange',@SimStatusChange);

        block.RegBlockMethod('Terminate',@Terminate);

        block.RegBlockMethod('WriteRTW',@WriteRTW);
    end



    function CheckPrms(block)

        hostName=block.DialogPrm(1).Data;
        if~ischar(hostName)
            error('opc:slwrite:hostNameInvalid','Invalid HostName parameter');
        end

        serverID=block.DialogPrm(2).Data;
        if~ischar(serverID)
            error('opc:slwrite:serverIDInvalid','Invalid ServerID parameter');
        end

        itemIDs=block.DialogPrm(3).Data;
        if~ischar(itemIDs)
            error('opc:slwrite:itemIDsNotChar','ItemIDs must be a comma-separated string.');
        end


        try
            parseitemids(itemIDs);
        catch
            error('opc:slwrite:itemIDsInvalid','ItemIDs string is not comma-separated.');
        end

        updateRate=block.DialogPrm(4).Data;
        if length(updateRate)~=1||~isreal(updateRate)||(updateRate<0&&updateRate~=-1),
            error('opc:slwrite:sampleRateInvalid','Sample time must be -1, 0, or a positive real scalar.');
        end

    end

    function ProcessPrms(block)%#ok
    end

    function DoPostPropSetup(block)%#ok
    end

    function InitializeConditions(block)%#ok
    end

    function Start(block)

        itemIDs=parseitemids(block.DialogPrm(3).Data);

        if isempty(itemIDs),

            return;
        end


        writeMode=block.DialogPrm(5).Data;

        errState=opcslconfigitf(block.BlockHandle,'GetErrorState');

       grps=opcfind('Type','dagroup','UserData',block.BlockHandle);
        if isempty(grps)

            da=opcslclntmgritf(block.BlockHandle,'GetClient');
            if isempty(da),

                error('opc:slwrite:clientNotFound','Could not find client at start of simulation.');
            end

            grp=addgroup(da,sprintf('%s/%s',...
            get(block.BlockHandle,'Path'),...
            get(block.BlockHandle,'Name')));
            grp.UserData=block.BlockHandle;
        elseif length(grps)>1,
            error('opc:slwrite:groupDuplicated','Found too many groups with the same block handle.');
        else
            grp=grps{1};
            da=grp.Parent;
        end

        try
            grp.Subscription='off';
        catch ME

            errMsg=ME.message;
            errID=ME.identifier;
            if strcmp(errID,'opc:subsasgn:servererror'),

                if writeMode==1,
                    errStruct=MException('opc:slwrite:callbackNotAvailable','Cannot use asynchronous writes on a server with no callbacks defined. Use synchronous writes with this server.');
                    throwAsCaller(errStruct);

                end
            end
        end

        grp.WriteAsyncFcn='';
        grp.UserData=block.BlockHandle;

        if~strcmpi(da.Status,'connected'),
            try
                connect(da);
            catch
                if errState.shutdown==1,

                    errStruct=MException('opc:slwrite:serverDisconnected','Client could not be connected to server at start.');
                    throwAsCaller(errStruct);
                elseif errState.shutdown==2,
                    throwwarning('opc:slwrite:serverDisconnected',...
                    'Client could not be connected to server at start.');
                end
            end

            myDlg=opcslclntmgritf(block.BlockHandle,'GetOpenClntMgr');
            if~isempty(myDlg),


                opcslclntmgr('RefreshClientList',myDlg,[],guihandles(myDlg));
            end
        end

        if errState.shutdown<3,
            da.ShutdownFcn={@shutdownhandler,errState};
        else

            da.ShutdownFcn=[];
        end


        itm=grp.Item;
        if isempty(itm)||~isequal(itemIDs(:),itm.ItemID),
            delete(itm);
            try
                lastwarn('');
                warnState=warning('off','opc:additem:additemfailed');
                itm=additem(grp,itemIDs);
                warning(warnState);

                additemErrMsg=lastwarn;
            catch ME


                itm=[];
                additemErrMsg=ME.message;
            end
            if length(itm)<length(itemIDs),
                errStruct=struct('identifier','opc:slwrite:missingItems',...
                'message',sprintf('\n\nCould not create all items for write block ''%s''.\n%s\n\n',...
                grp.Name,strrep(additemErrMsg,sprintf('\t'),'    ')));
                if errState.missingItems==1,
                    errStruct=MException(errStruct.identifier,errStruct.message);
                    throwAsCaller(errStruct);
                elseif errState.missingItems==2,
                    throwwarning(errStruct.identifier,errStruct.message);
                end
            end
        end
        if~isempty(itm)
            set(itm,'UserData',block.BlockHandle);

            [tfItm,locItm]=ismember(itemIDs,itm.ItemID);

        else
            tfItm=false(size(itemIDs));
            locItm=[];
        end
        if isempty(grp),
            error('opc:slwrite:blockDisabled','Cannot start a simulation with a disabled OPC Write block.');
        end



        da.ErrorFcn={@opcslerrorhandler,errState};

    end

    function WriteRTW(block)%#ok
    end

    function Outputs(block)%#ok
    end

    function Update(block)

        vals=block.InputPort(1).Data;
        valCell=num2cell(vals(locItm(tfItm)));
        if~isempty(valCell),
            try
                if writeMode==2,
                    write(grp,valCell);
                else
                    writeasync(grp,valCell);
                end
            catch opcME
                opcslerrorhandler(grp,opcME,errState);
            end
        end
    end

    function Derivatives(block)%#ok
    end

    function Projection(block)%#ok
    end

    function ZeroCrossings(block)%#ok
    end

    function SimStatusChange(block,s)%#ok
    end

    function Terminate(block)%#ok
    end
end


function shutdownhandler(obj,eventData,errState)%#ok

    errID='opc:slwrite:clientShutdown';
    errMsg=sprintf('Client ''%s'' has shutdown.',obj.Name);


    configBlk=opcslconfigitf(block.BlockHandle,'FindUsed');
    myDlg=findall(0,'Type','figure','Tag','dlgOPCClntMgr');
    for k=1:length(myDlg)
        bh=getAppData(myDlg(k),'blockHandle');
        if bh==get_param(configBlk,'Object'),
            opcslclntmgr('RefreshClientList',myDlg(k),[],guihandles(myDlg(k)));
        end
    end
    if errState.shutdown==1,



        errStruct=MException(errID,errMsg);
        throwAsCaller(errStruct);
    elseif errState.shutdown==2,
        throwwarning(errID,errMsg);
    end
end
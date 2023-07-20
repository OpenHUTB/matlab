function opcslread(block)




















    grp=[];
    itmudd=[];

    val=[];
    qual=[];
    ts=[];
    defaultTS=datenum(1601,1,1,2,0,0);
    defaultTSYear=1601;

    readMode=0;
    tsMode=0;

    tfItm=[];
    locItm=[];
    errState=[];
    dnStart=[];

    setup(block);











    function setup(block)


        hostName=block.DialogPrm(1).Data;
        serverID=block.DialogPrm(2).Data;
        itemIDs=parseitemids(block.DialogPrm(3).Data);
        dataType=block.DialogPrm(4).Data;
        readMode=block.DialogPrm(5).Data;
        updateRate=block.DialogPrm(6).Data;
        showOutputs=block.DialogPrm(7).Data;

        block.NumInputPorts=0;
        block.NumOutputPorts=1+sum(showOutputs);



        block.SetPreCompOutPortInfoToDynamic;



        dtIDs={'double','single','int8','uint8','int16','uint16','int32','uint32','logical'};
        dtInd=find(strncmpi(dataType,dtIDs,length(dataType)))-1;
        block.OutputPort(1).DatatypeID=dtInd;
        block.OutputPort(1).Complexity='Real';
        block.OutputPort(1).SamplingMode='Sample';

        block.OutputPort(1).Dimensions=max(length(itemIDs),1);

        opInd=1;


        if showOutputs(1),
            opInd=opInd+1;
            block.OutputPort(opInd).DatatypeID=5;
            block.OutputPort(opInd).Complexity='Real';
            block.OutputPort(opInd).SamplingMode='Sample';
            block.OutputPort(opInd).Dimensions=block.OutputPort(1).Dimensions;
        end


        if showOutputs(2),
            opInd=opInd+1;
            block.OutputPort(opInd).DatatypeID=0;
            block.OutputPort(opInd).Complexity='Real';
            block.OutputPort(opInd).SamplingMode='Sample';
            block.OutputPort(opInd).Dimensions=block.OutputPort(1).Dimensions;
        end


        block.NumDialogPrms=8;
        block.DialogPrmsTunable=repmat({'Nontunable'},1,8);








        minorRate=0.0;
        block.SampleTimes=[updateRate,minorRate];






        block.SetAccelRunOnTLC(false);






















        block.RegBlockMethod('CheckParameters',@CheckPrms);









        block.RegBlockMethod('SetInputPortSamplingMode',@SetInpPortFrameData);








        block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);








        block.RegBlockMethod('SetOutputPortDimensions',@SetOutPortDims);








        block.RegBlockMethod('SetInputPortDataType',@SetInpPortDataType);








        block.RegBlockMethod('SetOutputPortDataType',@SetOutPortDataType);








        block.RegBlockMethod('SetInputPortComplexSignal',@SetInpPortComplexSig);








        block.RegBlockMethod('SetOutputPortComplexSignal',@SetOutPortComplexSig);








        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);












        block.RegBlockMethod('ProcessParameters',@ProcessPrms);








        block.RegBlockMethod('InitializeConditions',@InitializeConditions);








        block.RegBlockMethod('Start',@Start);








        block.RegBlockMethod('Outputs',@Outputs);








        block.RegBlockMethod('Update',@Update);








        block.RegBlockMethod('Derivatives',@Derivatives);








        block.RegBlockMethod('Projection',@Projection);










        block.RegBlockMethod('ZeroCrossings',@ZeroCrosssings);








        block.RegBlockMethod('SimStatusChange',@SimStatusChange);







        block.RegBlockMethod('Terminate',@Terminate);











        block.RegBlockMethod('WriteRTW',@WriteRTW);
    end




    function CheckPrms(block)

        hostName=block.DialogPrm(1).Data;
        if~ischar(hostName)
            error('opc:opcslread:invalidHostName','Invalid HostName parameter');
        end

        serverID=block.DialogPrm(2).Data;
        if~ischar(serverID)
            error('opc:opcslread:invalidServerID','Invalid ServerID parameter');
        end

        itemIDs=block.DialogPrm(3).Data;
        if~ischar(itemIDs)
            error('opc:opcslread:invalidItemIDs','ItemIDs must be a comma-separated string.');
        end
        itemIDs=parseitemids(itemIDs);

        dataType=block.DialogPrm(4).Data;


        readMode=block.DialogPrm(5).Data;


        updateRate=block.DialogPrm(6).Data;
        if length(updateRate)~=1||~isreal(updateRate)||updateRate<0,
            error('opc:simulink:sampleTimeInvalid',...
            'Sample Time must be a positive real scalar.');
        end


        if(readMode==1)&&(updateRate==0)
            error('opc:simulink:readSampleTime',...
            'Sample time cannot be continuous for asynchronous read mode. Set Read mode to be synchronous, or specify a non-zero sample time.');
        end
        updateRate=fixupdaterate(updateRate);
        showOutputs=block.DialogPrm(7).Data;
        if length(showOutputs)~=2
            error('opc:opcslread:showOutputsInvalidLength',...
            'INTERNAL ERROR: Show Outputs parameter must be a vector.');
        end
    end

    function ProcessPrms(block)
    end

    function SetInpPortFrameData(block,idx,fd)
    end

    function SetOutPortFrameData(block,idx,fd)
    end

    function SetInpPortDims(block,idx,di)
    end

    function SetOutPortDims(block,idx,di)
        block.OutputPort(idx).Dimensions=di;
    end

    function SetInpPortDataType(block,idx,dt)
    end

    function SetOutPortDataType(block,idx,dt)
        block.OutputPort(idx).DataTypeID=dt;
    end

    function SetOutPortComplexSig(block,idx,c)
        block.OutputPort(idx).Complexity=c;
    end

    function DoPostPropSetup(block)


        block.NumDworks=0;
    end

    function InitializeConditions(block)

    end

    function Start(block)


        itemIDs=parseitemids(block.DialogPrm(3).Data);

        if isempty(itemIDs),

            return;
        end
        dataType=block.DialogPrm(4).Data;
        readMode=block.DialogPrm(5).Data;
        updateRate=block.DialogPrm(6).Data;
        updateRate=fixupdaterate(updateRate);
        showOutputs=block.DialogPrm(7).Data;
        tsMode=block.DialogPrm(8).Data;



        errState=opcslconfigitf(block.BlockHandle,'GetErrorState');


        grps=opcfind('Type','dagroup','UserData',block.BlockHandle);
        if isempty(grps)

            da=opcslclntmgritf(block.BlockHandle,'GetClient');
            if isempty(da),


                configBlk=opcslconfigitf(block.BlockHandle,'FindUsed',false);
                if isempty(configBlk),
                    error('opcblks:read:configNotFound','OPC Configuration block not found. Cannot start simulation.');
                else
                    serverHost=get(block.BlockHandle,'serverHost');
                    serverID=get(block.BlockHandle,'serverID');
                    clntInd=opcslclntmgritf(block.BlockHandle,'AddClient',...
                    serverHost,serverID,'10');
                    da=opcslclntmgritf(block.BlockHandle,'GetClient');
                end
            end

            grp=addgroup(da,sprintf('%s/%s',...
            get(block.BlockHandle,'Path'),...
            get(block.BlockHandle,'Name')));
            grp.UserData=block.BlockHandle;
        elseif length(grps)>1,
            error('opc:opcslread:multipleGroupsSameHandle',...
            'Found too many groups with the same block handle.');
        else
            grp=grps{1};
            da=grp.Parent;
        end

        if~strcmpi(da.Status,'connected'),
            try
                connect(da);
            catch opcME
                if errState.shutdown==1,
                    errException=MException('opc:simulink:serverDisconnected','Client could not be connected to server at start.');
                    errException.addCause(opcME);
                    throw(errException);
                elseif errState.shutdown==2,
                    throwwarning('opc:simulink:serverDisconnected',...
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

        try
            grp.Subscription='off';
        catch ME

            errMsg=ME.message;
            errID=ME.identifier;
            if strcmp(errID,'opc:subsasgn:servererror'),

                if readMode==1,
                    errStruct=MException('opc:simulink:callbackNotAvailable','Cannot use asynchronous reads on a server with no callbacks defined. Use synchronous reads with this server.');
                    throwAsCaller(errStruct);
                end
            end
        end
        updateRate=fixupdaterate(block.DialogPrm(6).Data);
        grp.UpdateRate=updateRate;

        if strcmpi(dataType,'logical')
            val=false(length(itemIDs),1);
        else
            val=zeros(length(itemIDs),1,dataType);
        end
        qual=zeros(length(itemIDs),1,'uint16');
        ts=ones(length(itemIDs),1).*now;



        if isempty(itm)||~isequal(itemIDs(:),itm.ItemID),
            delete(itm);
            additemErrMsg='';
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
                errStruct=struct('identifier','opc:simulink:missingItems',...
                'message',sprintf('\n\nCould not create all items for read block ''%s''.\n%s\n',...
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
            set(itm,'DataType',dataType,'UserData',block.BlockHandle);

            [tfItm,locItm]=ismember(itemIDs,itm.ItemID);

            itmudd=getudd(itm);
        else
            tfItm=false(size(itemIDs));
            locItm=[];
            itmudd=[];
        end
        if isempty(grp),
            error('opc:simulink:readBlockDisabled','Cannot start a simulation with a disabled Read block.');
        end
        set(grp,'UpdateRate',updateRate);

        try

            s=warning('off','opc:read:failed');
            r=read(grp,'device');
            warning(s);
            ind=1;
            dnStart=[];
            while isempty(dnStart)&&ind<length(r)+1,
                if~isempty(r(ind).TimeStamp)&&r(ind).TimeStamp(1)>defaultTSYear,
                    dnStart=datenum(r(ind).TimeStamp);
                end
                ind=ind+1;
            end

            if(readMode==1)
                grp.Subscription='on';



            end

            da.ErrorFcn={@opcslerrorhandler,errState};
        catch opcME
            opcslerrorhandler(grp,opcME,errState);
        end
        if isempty(dnStart),
            dnStart=now;
        end

        ts(1:end)=dnStart;
    end

    function WriteRTW(block)
    end

    function Outputs(block)

        showOutputs=block.DialogPrm(7).Data;
        isBool=strcmp(block.DialogPrm(4).Data,'logical');
        for k=1:length(tfItm)
            if tfItm(k),
                thisVal=get(itmudd(locItm(k)),'Value');
                if~isempty(thisVal),
                    if isBool,
                        val(k)=(thisVal(1)~=0);
                    else
                        val(k)=thisVal(1);
                    end
                end
                if showOutputs(1),

                    qual(k)=uint16(get(itmudd(locItm(k)),'QualityID'));
                end
                if showOutputs(2),

                    thisTS=datenum(get(itmudd(locItm(k)),'TimeStamp'));

                    if~isempty(thisTS)&&(thisTS>defaultTS)
                        ts(k)=thisTS;
                    end
                end
            end
        end
        block.OutputPort(1).Data=val;
        oi=2;
        if showOutputs(1),
            block.OutputPort(oi).Data=qual;
            oi=3;
        end
        if showOutputs(2)
            if tsMode==1,
                block.OutputPort(oi).Data=(ts-dnStart).*86400;
            else
                block.OutputPort(oi).Data=ts;
            end
        end
    end

    function Update(block)
        switch readMode
        case 2,
            try
                s=warning('off','opc:read:failed');
                r=read(grp,'cache');
                warning(s);
                if errState.readWrite<3,


                    checkerrorfield(grp,r,errState.readWrite);
                end
            catch opcME
                opcslerrorhandler(grp,opcME,errState);
            end
        case 3,
            try
                s=warning('off','opc:read:failed');
                r=read(grp,'device');
                warning(s);
                if errState.readWrite<3,


                    checkerrorfield(grp,r,errState.readWrite);
                end
            catch opcME
                opcslerrorhandler(grp,opcME,errState);
            end
        end
drawnow
    end

    function Derivatives(block)
    end

    function Projection(block)
    end

    function ZeroCrosssings(block)
    end

    function SimStatusChange(block,s)


    end

    function Terminate(block)
        if~isempty(grp),
            try
                grp.Subscription='off';
            catch

            end
        end
    end

end


function updateRate=fixupdaterate(updateRate)




    h=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','OPC Configuration');
    if~isempty(h),
        if iscell(h),h=h{1};end
        spdup=get_param(h,'speedup');
        updateRate=updateRate./eval(spdup);
    end
end


function shutdownhandler(obj,eventData,errState)

    errID='opc:simulink:clientShutdown';
    errMsg=sprintf('Client ''%s'' has shutdown.',obj.Name);


    myDlg=opcslclntmgritf(block.BlockHandle,'GetOpenClntMgr');
    if~isempty(myDlg),
        opcslclntmgr('RefreshClientList',myDlg,[],guihandles(myDlg));
    end
    if errState.shutdown==1,
        errStruct=MException(errID,errMsg);
        throwAsCaller(errStruct);



    elseif errState.shutdown==2,
        throwwarning(errID,errMsg);
    end
end



function checkerrorfield(grp,r,rwErrState)
    hasErr=~cellfun('isempty',{r.Error});
    grpName=grp.Name;
    errMsg='Block ''%s'' returned errors during read:\n%s';
    errID='opcblks:read:readerrors';
    if any(hasErr),
        infoCell={r(hasErr).ItemID;r(hasErr).Error};
        errMsg=sprintf(errMsg,grpName,sprintf('\t[%s] %s\n',infoCell{:}));
        errMsg(end)=[];
        if rwErrState==1,
            errStruct=MException(errID,errMsg);
            throwAsCaller(errStruct);

        elseif rwErrState==2,
            throwwarning(errID,errMsg);
        end
    end
end


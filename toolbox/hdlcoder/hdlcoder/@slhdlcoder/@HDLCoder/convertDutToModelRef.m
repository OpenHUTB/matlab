function hs=convertDutToModelRef(this)




    prefix=this.getParameter('GeneratedModelNamePrefix');
    gmName=getGeneratedModelName(prefix,this.OrigModelName);
    gmStartNodeName=regexprep(this.OrigStartNodeName,['^',this.OrigModelName],gmName);

    try

        junkModelName=getGeneratedModelName('tempHDLC_',gmName);
        new_system(junkModelName,'model');
        junkSS=add_block('built-in/SubSystem',[junkModelName,'/tempHDLC']);
        Simulink.BlockDiagram.copyContentsToSubSystem(this.OrigModelName,junkSS);




        new_system(gmName,'model');
        Simulink.SubSystem.copyContentsToBlockDiagram(junkSS,gmName);





        slInternal('convertAllSSRefBlocksToSubsystemBlocks',...
        get_param(gmName,'handle'));
        blk=gmStartNodeName;
        while~isempty(blk)
            if strcmp(get_param(blk,'Type'),'block')&&...
                strcmp(get_param(blk,'StaticLinkStatus'),'resolved')

                set_param(blk,'LinkStatus','inactive');
            end
            blk=get_param(blk,'Parent');
        end
        close_system(junkModelName,0);


        slpir.PIR2SL.initOutputModel(this.OrigModelName,gmName);



        if(strncmp(get_param(gmName,'SignalResolutionControl'),'TryResolve',10))
            set_param(gmName,'SignalResolutionControl','UseLocalSettings');
        end

    catch me
        close_system(junkModelName,0);
        close_system(gmName,0);
        error(message('hdlcoder:engine:createtargetmodel',gmName,me.message));
    end


    if this.isDutModelRef
        gsmName=get_param(gmStartNodeName,'ModelName');
        load_system(gsmName);
        this.DUTMdlRefHandle=get_param(gmStartNodeName,'Handle');
    else


        gsmName=hdllegalname(get_param(gmStartNodeName,'Name'));
        bdclose(gsmName);
        gsmName=getGeneratedModelName('',gsmName);

        set_param(gmStartNodeName,'TreatAsAtomicUnit','on');
        try
            [success,newMdlRefHandle]=...
            Simulink.SubSystem.convertToModelReference(gmStartNodeName,gsmName,...
            'ReplaceSubsystem',true,'AutoFix',true,'CreateBusObjectsForAllBuses',true);
            if~success
                msg=message('hdlcoder:engine:convertToModelReferenceFailed');
                error(message('hdlcoder:engine:createtargetmodel',gmName,msg.getString));
            end


            set_param(gsmName,'FixedStep','auto');


            hdlset_param(gsmName,'HDLSubsystem',gsmName);
        catch me

            if strcmp(me.identifier,'Simulink:modelReferenceAdvisor:CannotCompileModel')

                firstError=me.cause{1};
                if strcmp(firstError.identifier,'MATLAB:MException:MultipleErrors')

                    me=firstError;
                else


                    causeMsg='';
                    for ii=1:numel(me.cause)
                        causeMsg=[causeMsg,newline,me.cause{ii}.message];%#ok<AGROW>
                    end
                    msg=message('hdlcoder:engine:NonTopDutExtractionFailed',...
                    me.message,causeMsg);
                    me=MException(msg.Identifier,msg.getString);
                    me.throw;
                end

            end
            if strcmp(me.identifier,'MATLAB:MException:MultipleErrors')
                firstError=me.cause{1};
                switch firstError.identifier
                case 'Simulink:blocks:InvInterSysConn1'
                    if strcmp(me.cause{2}.identifier,'Simulink:blocks:InvInterSysConn2')
                        startMsg=sprintf('%s.',me.cause{2}.message);
                    else
                        startMsg='';
                    end
                    if strcmp(me.cause{3}.identifier,'Simulink:blocks:InvInterSysConn3')
                        stopMsg=sprintf('%s.',me.cause{3}.message);
                    else
                        stopMsg='';
                    end
                    error(message('hdlcoder:engine:GotoFromCrossesDUT',startMsg,stopMsg));
                case{'Simulink:Engine:UnableToSolveAlgLoop',...
                    'Simulink:Engine:AlgLoopsDisabled',...
                    'Simulink:Engine:BlockWithStatesModifiedInOutputUpdateInAlgLoop'}
                    exception=algLoopExceptionHelper(me,this.OrigStartNodeName,...
                    gmStartNodeName);
                    exception.throwAsCaller;
                otherwise
                    me.rethrow;
                end
            else
                me.rethrow;
            end
        end
        this.DUTMdlRefHandle=newMdlRefHandle;




        if strcmp(get_param(this.OrigStartNodeName,'IsInSynchronousDomain'),'on')&&...
            isempty(find_system(gsmName,'SearchDepth',1,'BlockType','StateControl'))
            scName=[gsmName,'/StateControl'];
            add_block('built-in/StateControl',scName,'StateControl','Synchronous');
        end





        mdlInfoBlks=find_system(gsmName,'LookUnderMasks','all','FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'ReferenceBlock','simulink/Model-Wide Utilities/Model Info');
        if~isempty(mdlInfoBlks)
            cellfun(@(x)set_param(x,'commented','on'),mdlInfoBlks);
        end



    end



    origVariant.Name=this.DUTVariantName;
    origVariant.ModelName=gsmName;
    origVariant.ParameterArgumentNames='';
    origVariant.ParameterArgumentValues='';
    origVariant.SimulationMode=get_param(this.OrigModelName,'SimulationMode');
    if strcmpi(origVariant.SimulationMode,'External')
        origVariant.SimulationMode='Normal';
    elseif strcmpi(origVariant.SimulationMode,'Rapid Accelerator')
        msgObj=message('hdlcoder:engine:GenModelRapidAccelDropped');
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',msgObj);
        origVariant.SimulationMode='Accelerator';
    else

        origVariant.SimulationMode(1)=upper(origVariant.SimulationMode(1));
    end



    vssHdl=Simulink.VariantManager.convertToVariant(this.DUTMdlRefHandle);
    this.DUTMdlRefHandle=vssHdl;
    activeVariant=get_param(vssHdl,'ActiveVariantBlock');
    set_param(activeVariant,'ModelName',origVariant.ModelName);
    set_param(activeVariant,'SimulationMode',origVariant.SimulationMode);
    set_param(activeVariant,'VariantControl',origVariant.Name);


    params=this.getCmdLineParams;
    if~isempty(params)&&strcmp(params{1},'HDLSubsystem')
        params{2}=gsmName;
        this.setCmdLineParams(params);
    end


    if~this.isDutModelRef

        set_param(gsmName,'LoadExternalInput','off');
        set_param(gsmName,'LoadInitialState','off');
        save_system(gsmName);
    end

    this.updateStartNodeName(gsmName);
    hs=this.initMakehdl(this.ModelName);

    this.setParameter('generatedmodelname',gmName);
    this.updateCLI('generatedmodelname',gmName);
end


function exception=algLoopExceptionHelper(me,origStartNodeName,gmStartNodeName)
    msg=message('hdlcoder:engine:AlgLoopInNonTopDUT',origStartNodeName);
    exception=MSLException(get_param(gmStartNodeName,'handle'),...
    msg.Identifier,msg.getString);
    for ii=2:numel(me.cause)
        exception=exception.addCause(me.cause{ii});
    end
end



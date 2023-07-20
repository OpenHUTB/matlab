


function checks=performGlobalFloatChecks(this)
    checks=[];

    fpMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode;
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    otherFpMode=fpMode&&~nfpMode;
    realsInCodeMsgLvl=this.getParameter('TreatRealsInGeneratedCodeAs');
    frame2Sample=this.getParameter('FrameToSampleConversion');


    if fpMode&&this.getParameter('isvhdl')&&...
        ~(this.getParameter('filter_input_type_std_logic')&&...
        this.getParameter('filter_output_type_std_logic'))
        msg=message('hdlcommon:nativefloatingpoint:OnlyLogicInVHDL');
        checks(end+1).level='Error';
        checks(end).path=this.AllModels(1).modelName;
        checks(end).type='block';
        checks(end).message=msg.getString;
        checks(end).MessageID=msg.Identifier;
    end



    emittedmsg=struct('one',false,'two',false,'three',false,'four',false);

    numModels=numel(this.AllModels);
    for mdlIdx=1:numModels
        this.mdlIdx=mdlIdx;
        mdlName=this.AllModels(mdlIdx).modelName;
        p=pir(mdlName);
        this.PirInstance=p;
        checks=[checks,doGlobalFloatChecks(p,nfpMode,otherFpMode,emittedmsg,realsInCodeMsgLvl,frame2Sample,mdlName)];%#ok<AGROW>
    end
end

function checks=doGlobalFloatChecks(p,nfpMode,otherFpMode,emittedmsg,realsInCodeMsgLvl,frame2Sample,mdlName)
    checks=[];
    vN=p.Networks;
    if nfpMode&&~emittedmsg.one

        for ii=1:numel(vN)
            break;

            hN=vN(ii);
            vS=hN.Signals;
            for jj=1:numel(vS)
                hS=vS(jj);
                hT=hS.Type;
                if hT.isDoubleType
                    if emittedmsg.one==false
                        emittedmsg.one=true;
                        msg=message('hdlcommon:nativefloatingpoint:NFPContainsDoubleError');
                        checks(end+1).level='Error';
                        checks(end).path=getDriverPath(hS);
                        checks(end).type='block';
                        checks(end).message=msg.getString;
                        checks(end).MessageID=msg.Identifier;
                        break;
                    end
                end
            end
        end
    elseif~otherFpMode&&~(emittedmsg.two&&emittedmsg.three)


        if~strcmpi(realsInCodeMsgLvl,'none')



            for ii=1:numel(vN)
                hN=vN(ii);
                vS=hN.Signals;
                for jj=1:numel(vS)
                    hS=vS(jj);
                    hT=hS.Type.getLeafType;
                    if hT.isSingleType
                        if emittedmsg.two==false
                            emittedmsg.two=true;
                            if frame2Sample
                                msg=message('hdlcommon:nativefloatingpoint:SMTWithSingleShouldUseNFP',mdlName);
                            else
                                msg=message('hdlcommon:nativefloatingpoint:SingleShouldUseNFP',mdlName);
                            end
                            checks(end+1).level=realsInCodeMsgLvl;%#ok                    
                            checks(end).path=getDriverPath(hS);
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).MessageID=msg.Identifier;
                        end
                    elseif hT.isDoubleType
                        if emittedmsg.three==false
                            emittedmsg.three=true;
                            if frame2Sample
                                msg=message('hdlcommon:nativefloatingpoint:SMTWithDoubleShouldUseNFP',mdlName);
                            else
                                msg=message('hdlcommon:nativefloatingpoint:DoubleShouldUseNFP',mdlName);
                            end
                            checks(end+1).level=realsInCodeMsgLvl;%#ok                    
                            checks(end).path=getDriverPath(hS);
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).MessageID=msg.Identifier;
                        end
                    elseif hT.isHalfType
                        if emittedmsg.four==false
                            emittedmsg.four=true;
                            if frame2Sample
                                msg=message('hdlcommon:nativefloatingpoint:SMTWithHalfShouldUseNFP',mdlName);
                            else
                                msg=message('hdlcommon:nativefloatingpoint:HalfShouldUseNFP',mdlName);
                            end
                            checks(end+1).level=realsInCodeMsgLvl;%#ok                    
                            checks(end).path=getDriverPath(hS);
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).MessageID=msg.Identifier;
                        end
                    end
                end
            end
        end
    end
end

function pathName=getDriverPath(hS)

    owner=hS.getDrivers.Owner;
    driverslbh=owner.SimulinkHandle;


    if driverslbh==-1
        driverslbh=owner.OrigModelHandle;
    end
    if driverslbh==-1
        pathName=owner.Name;
    else
        pathName=getfullname(driverslbh);
    end
end



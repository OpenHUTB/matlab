function DownsampleBlock(obj)












    msg='dsp:block:';

    if isR2022aOrEarlier(obj.ver)
        blks=obj.findBlocksOfType('DownSample');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            vsMode=get_param(this_blk,'AllowArbitraryFixedInput');
            multirateMode=get_param(this_blk,'RateOptions');
            frameMode=get_param(this_blk,'InputProcessing');
            if strcmp(vsMode,'on')...
                &&strcmpi(multirateMode,getString(message('dsp:dialog:EnforceSingleRate_CB')))...
                &&strcmpi(frameMode,getString(message('dsp:dialog:InProcessingFrameBased_CB')))


                subsys_msg=getString(message([msg,'EmptySubsystem_VarsizeSignal'],'Downsample','R2022b'));
                subsys_err=getString(message([msg,'NewFeaturesNotAvailable']));
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end

        obj.appendRules({...
        '<Block<BlockType|DownSample><AllowArbitraryFixedInput:remove>>',...
        });
    end






    if isR2014bOrEarlier(obj.ver)

        blockType='DownSample';
        maskType='Downsample';
        fcnName='sdspdsamp2';
        refRule='dspsigops/Downsample';
        setFcn=@setupDownSampleBlock;

        obj.appendRules(blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn));
    end


    if isR2010aOrEarlier(obj.ver)


        downsampleBlks=obj.findBlocksWithMaskType('Downsample');

        n2bReplaced=length(downsampleBlks);

        for i=1:n2bReplaced
            blk=downsampleBlks{i};
            rateOptions=get_param(blk,'RateOptions');
            if strcmpi(rateOptions,'Allow multirate processing')
                set_param(blk,'fmode','Maintain input frame size',...
                'smode','Allow multirate');
            else
                set_param(blk,'fmode','Maintain input frame rate',...
                'smode','Force single rate');
            end

            ud=get_param(blk,'UserData');
            if(~isempty(ud)&&isstruct(ud)&&isfield(ud,'hasInheritedOption'))
                ud=rmfield(ud,'hasInheritedOption');
                numFields=numel(fieldnames(ud));
                if numFields==0
                    set_param(blk,'UserData','');
                else
                    set_param(blk,'UserData',ud);
                end
            end
        end

        obj.appendRules({...
        '<Block<SourceBlock|"dspsigops/Downsample"><InputProcessing:remove>>',...
        '<Block<SourceBlock|"dspsigops/Downsample"><RateOptions:remove>>',...
        });
    end

end


function maskVarNames=setupDownSampleBlock(sfcn)
    set_param(sfcn,...
    'Parameters','N,phase,InputProcessing,RateOptions,smode,fmode,ic',...
    'MaskVariables','N=@1;phase=@2;InputProcessing=@3;RateOptions=@4;smode=@5;fmode=@6;ic=@7;',...
    'MaskPromptString','Downsample factor, K:|Sample offset (0 to K-1):|Input processing:|Rate options:|Sample-based mode:|Frame-based mode:|Initial condition:',...
    'MaskStyleString','edit,edit,popup(Columns as channels (frame based)|Elements as channels (sample based)|Inherited (this choice will be removed - see release notes)),popup(Enforce single-rate processing|Allow multirate processing),popup(Allow multirate|Force single rate),popup(Maintain input frame size|Maintain input frame rate),edit',...
    'MaskTunableValueString','off,off,off,off,off,off,off',...
    'MaskCallbackString','||dspblkdsamp2|dspblkdsamp2|||',...
    'MaskEnableString','on,on,on,on,off,off,off',...
    'MaskVisibilityString','on,on,on,on,off,off,off',...
    'MaskToolTipString','on,on,on,on,on,on,on',...
    'MaskVarAliasString','',...
    'MaskSelfModifiable','on',...
    'MaskIconFrame','on',...
    'MaskIconOpaque','on',...
    'MaskIconRotate','none',...
    'MaskIconUnits','autoscale',...
    'MaskValueString','2|0|Columns as channels (frame based)|Enforce single-rate processing|Allow multirate|Maintain input frame size|0',...
    'MaskTabNameString','',...
    'MaskType','Downsample'...
    );


    blkUserData=[];
    blkUserData.hasInheritedOption=true;
    set_param(sfcn,'UserDataPersistent','on',...
    'UserData',blkUserData);


    maskVarNames={'N','phase','InputProcessing','RateOptions','smode','fmode','ic'};
end





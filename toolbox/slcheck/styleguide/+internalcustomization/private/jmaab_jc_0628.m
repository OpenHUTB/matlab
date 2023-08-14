function jmaab_jc_0628




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0628');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0628_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0628';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0628',@checkAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0628_tip');
    rec.setLicense({styleguide_license});
    rec.Value=false;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function FailingObjs=checkAlgo(system)
    FailingObjs=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    saturationBlocks=find_system(system,'MatchFilter',@Simulink.match.activeVariants,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Saturate');
    saturationBlocks=mdladvObj.filterResultWithExclusion(saturationBlocks);



    saturationDynamicBlocks=find_system(system,'MatchFilter',@Simulink.match.activeVariants,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'MaskType','Saturation Dynamic');
    saturationDynamicBlocks=mdladvObj.filterResultWithExclusion(saturationDynamicBlocks);

    allBlks=[saturationBlocks;saturationDynamicBlocks];

    if isempty(allBlks)
        return;
    end

    flags=true(1,length(allBlks));

    for k=1:length(allBlks)
        currBlock=allBlks{k};
        currHndl=get_param(currBlock,'Handle');
        blkObj=get_param(currHndl,'Object');






        if strcmp('Saturate',blkObj.BlockType)||...
            strcmp('Saturation Dynamic',blkObj.MaskType)





            oPort=get(blkObj.PortHandles.Outport);
            iPorts=get(blkObj.PortHandles.Inport);

            whichPort=1;
            if any(size(iPorts)==3)


                whichPort=2;
            end


            if~strcmp(iPorts(whichPort).CompiledPortDataType,oPort.CompiledPortDataType)
                flags(k)=false;
                continue;
            end
        end

        flagLower=false;
        flagUpper=false;


        if strcmp('Saturate',blkObj.BlockType)
            oPort=get_param(blkObj.PortHandles.Outport,'object');
            upperlowerStrs=[string(blkObj.UpperLimit),string(blkObj.LowerLimit)];

            upperValue=Advisor.Utils.Simulink.evalSimulinkBlockParameters(currHndl,'UpperLimit');
            lowerValue=Advisor.Utils.Simulink.evalSimulinkBlockParameters(currHndl,'LowerLimit');


            upperValue=processValue(upperValue{1});
            lowerValue=processValue(lowerValue{1});

        else




            iPorts=blkObj.PortHandles.Inport;
            upObj=get_param(iPorts(1),'object');
            loObj=get_param(iPorts(3),'object');
            upSrc=upObj.getActualSrc;
            loSrc=loObj.getActualSrc;
            PO=get_param(upSrc(1),'object');
            if strcmp('Constant',get_param(PO.Parent,'BlockType'))
                upperValue=Advisor.Utils.Simulink.evalSimulinkBlockParameters(get_param(PO.Parent,'handle'),'Value');
                upperValue=processValue(upperValue{1});
            end
            PO=get_param(loSrc(1),'object');
            if strcmp('Constant',get_param(PO.Parent,'BlockType'))
                lowerValue=Advisor.Utils.Simulink.evalSimulinkBlockParameters(get_param(PO.Parent,'handle'),'Value');
                lowerValue=processValue(lowerValue{1});
            end
        end

        upperLim=[];
        lowerLim=[];

        baseType=Advisor.Utils.Simulink.outDataTypeStr2baseType(...
        system,oPort.CompiledPortDataType);

        baseType=baseType{1};

        switch baseType
        case{'int8','int16','int32','int64'...
            ,'uint8','uint16','uint32','uint64'}
            upperLim=intmax(baseType);
            lowerLim=intmin(baseType);
        case{'single','double'}
            lim=realmax(baseType);
            upperLim=lim;
            lowerLim=-lim;
        otherwise
            if contains(baseType,'fixdt')
                baseType=regexprep(baseType,'\s','');
                argument=regexp(baseType,'\((.*)\)','tokens');
                argument=[argument{:}];
                argument=str2num(argument{1});

                limits=ModelAdvisor.internal.getFixdtDataTypeLimits(argument);
                if~isempty(limits)
                    upperLim=limits.realMax;
                    lowerLim=limits.realMin;
                end
            else
                upperLim=[];
                lowerLim=[];
            end
        end
        if~isempty(upperLim)&&~isempty(lowerLim)

            if~isempty(upperValue)
                if upperValue>=upperLim||upperValue<=lowerLim
                    flagUpper=true;
                end
            end

            if~isempty(lowerValue)
                if lowerValue<=lowerLim||lowerValue>=upperLim
                    flagLower=true;
                end
            end
        end

        if flagUpper&&flagLower
            flags(k)=false;
        end
    end
    FailingObjs=allBlks(~flags);
end


function retVal=processValue(value)
    if~isempty(value)
        if iscell(value)
            retVal=min([value{:}]);
        elseif ismatrix(value)
            [sz1,sz2]=size(value);
            if sz1==1&&sz2==1
                retVal=value;
            else
                retVal=min(value,[],'all');
            end
        end
    else
        retVal=value;
    end
end

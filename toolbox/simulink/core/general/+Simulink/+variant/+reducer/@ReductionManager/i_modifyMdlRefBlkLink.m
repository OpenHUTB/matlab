
function i_modifyMdlRefBlkLink(optArgs,mdlRefBlk)



    topModelName=optArgs.getOptions().TopModelName;
    bdNameRedBDNameMap=optArgs.BDNameRedBDNameMap;
    activeRefMdls=optArgs.ActiveRefMdls;


    origMdlRefBlk=mdlRefBlk;

    rootBD=i_getRootBDNameFromPath(mdlRefBlk);
    if~strcmp(rootBD,topModelName)&&isKey(bdNameRedBDNameMap,rootBD)
        mdlRefBlk=[bdNameRedBDNameMap(rootBD),mdlRefBlk((length(rootBD)+1):end)];
    end



    copyArgVals=~strcmp(get_param(mdlRefBlk,'LinkStatus'),'resolved');



    if copyArgVals

        modelBlockParamValsToReset=struct(...
        'ParameterArgumentValues',[],...
        'InstanceParameters',[],...
        'MaskValues',[]);

        modelBlockParamsToReset=fieldnames(modelBlockParamValsToReset);

        for ii=1:numel(modelBlockParamsToReset)

            param=modelBlockParamsToReset{ii};

            try %#ok<TRYNC>
                if isequal(param,'MaskValues')
                    modelBlockParamValsToReset.(param)=getMaskValues(mdlRefBlk);
                    continue;
                end
                modelBlockParamValsToReset.(param)=get_param(mdlRefBlk,param);
            end
        end

    end





    if strcmp(get_param(mdlRefBlk,'Variant'),'off')

        oldModelName=get_param(mdlRefBlk,'ModelName');
        newModelName=bdNameRedBDNameMap(oldModelName);


        set_param(mdlRefBlk,'ModelNameDialog',newModelName);





        if~strcmp(newModelName,get_param(mdlRefBlk,'ModelName'))


            topModelOrigName=optArgs.getOptions().TopModelOrigName;
            rootBD=i_getRootBDNameFromPath(origMdlRefBlk);
            if strcmp(rootBD,topModelName)
                origMdlRefBlk=[topModelOrigName,mdlRefBlk((length(rootBD)+1):end)];
            end
            throwAsCaller(MException(message('Simulink:Variants:ReducerBadModelBlock',origMdlRefBlk,topModelOrigName)));
        end


    else







        variantsParam=get_param(mdlRefBlk,'Variants');




        [~,variantMdlChoiceNames,~]=cellfun(@fileparts,{variantsParam.ModelName},'UniformOutput',0);



        for varBlkChoice=1:numel(variantMdlChoiceNames)
            currRefModel=variantMdlChoiceNames{varBlkChoice};
            if~isempty(Simulink.variant.reducer.utils.searchNameInCell(currRefModel,activeRefMdls))
                variantsParam(varBlkChoice).ModelName=bdNameRedBDNameMap(currRefModel);
            end
        end


        set_param(mdlRefBlk,'Variants',variantsParam);
    end




    if copyArgVals
        for ii=1:numel(modelBlockParamsToReset)

            param=modelBlockParamsToReset{ii};

            val=modelBlockParamValsToReset.(param);
            if isempty(val)
                continue;
            end
            if isstruct(val)&&isempty(fieldnames(val))


                continue;
            end
            if strcmp(param,'InstanceParameters')
                i_modifyInstanceParamsBlockPaths();
            end

            try %#ok<TRYNC>
                set_param(mdlRefBlk,param,val);
            end
        end
    end



    function i_modifyInstanceParamsBlockPaths()




        for instPrmIdx=1:numel(val)

            blkPathObj=val(instPrmIdx).Path;
            blkPathLength=blkPathObj.getLength();

            blkPaths=cell(1,blkPathLength);
            validBlkPathIdx=1;
            for blkPathIdx=1:blkPathLength

                blkPath=blkPathObj.getBlock(blkPathIdx);

                origModelName=strtok(blkPath,'/');
                if~bdNameRedBDNameMap.isKey(origModelName)
                    blkPaths(end)=[];
                    continue;
                end

                blkPaths{validBlkPathIdx}=[bdNameRedBDNameMap(origModelName),blkPath((length(origModelName)+1):end)];
                validBlkPathIdx=validBlkPathIdx+1;
            end

            if~isempty(blkPaths)
                val(instPrmIdx).Path=Simulink.BlockPath(blkPaths);
            end

        end

    end

end

function maskValues=getMaskValues(mdlRefBlk)



    maskValues=get_param(mdlRefBlk,'MaskValues');
    maskNames=get_param(mdlRefBlk,'MaskNames');


    mdlNameIdx=strcmp(maskNames,'ModelNameDialog');
    maskValues(mdlNameIdx)=[];
end



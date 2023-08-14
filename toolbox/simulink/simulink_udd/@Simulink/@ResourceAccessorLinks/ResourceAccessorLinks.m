function sObj=ResourceAccessorLinks(resourceOwnerBlkH,glyphType)





    sObj=Simulink.ResourceAccessorLinks;
    sObj.ResourceOwnerBlock=resourceOwnerBlkH;
    sObj.StateInfo=[];
    sObj.ParamInfo=[];

    if glyphType=="state"
        accMap=get_param(bdroot(resourceOwnerBlkH),'StateAccessorInfoMap');





        ind=1;
        for k=1:length(accMap)
            if(resourceOwnerBlkH==accMap(k).StateOwnerBlock)
                sObj.StateInfo(ind).Name=accMap(k).StateName;
                sObj.StateInfo(ind).ReaderBlocks=accMap(k).StateReaderBlockSet;
                sObj.StateInfo(ind).WriterBlocks=accMap(k).StateWriterBlockSet;
                sObj.StateInfo(ind).StateflowSfunctions=accMap(k).StateflowSfuncSet;
                ind=ind+1;
            end
        end
    else
        accMap=get_param(bdroot(resourceOwnerBlkH),'ParamAccessorInfoMap');





        ind=1;
        for k=1:length(accMap)
            if(resourceOwnerBlkH==accMap(k).ParamOwnerBlock)
                sObj.ParamInfo(ind).Name=accMap(k).ParamName;
                sObj.ParamInfo(ind).ReaderBlocks=accMap(k).ParamReaderBlockSet;
                sObj.ParamInfo(ind).WriterBlocks=accMap(k).ParamWriterBlockSet;
                sObj.ParamInfo(ind).StateflowSfunctions=accMap(k).StateflowSfuncSet;


                if strcmp(get_param(resourceOwnerBlkH,'BlockType'),'ModelReference')
                    paramNameParsed=strsplit(accMap(k).ParamName,'.');
                    if~isempty(paramNameParsed)
                        if~isnan(str2double(paramNameParsed{1}))
                            accessorBlocks=[accMap(k).ParamWriterBlockSet,accMap(k).StateflowSfuncSet...
                            ,accMap(k).ParamReaderBlockSet];
                            sObj.ParamInfo(ind).Name=get_param(accessorBlocks(1),'ParameterName');
                        end
                    end
                end
                ind=ind+1;
            end
        end
    end
end


function replacementInfo=getRefinedLinkMatch(h,block,map)








    numMaps=numel(map);

    if numMaps>1


        replacementInfo=[];

        oldBlockType=get_param(block,'BlockType');
        oldMaskNames=get_param(block,'MaskNames');
        numOldMaskNames=numel(oldMaskNames);


        for k=1:numMaps
            if strcmp(oldBlockType,map{k}.newBlockType)&&...
                numel(map{k}.MaskNames)==numOldMaskNames



                if numOldMaskNames==0||...
                    (...
                    numOldMaskNames>0&&...
                    all(strcmp(oldMaskNames,map{k}.MaskNames))...
                    )


                    if(strcmp(oldBlockType,'S-Function')||...
                        strcmp(oldBlockType,'M-S-Function'))
                        oldFcnName=get_param(block,'FunctionName');
                        if strcmp(map{k}.SFunctionName,oldFcnName)
                            replacementInfo=map{k};
                            break
                        end
                    else
                        replacementInfo=map{k};
                        break
                    end
                end
            end
        end

        if isempty(replacementInfo)

            replacementInfo.oldMaskType=get_param(block,'MaskType');
            replacementInfo.newMaskType='';
            replacementInfo.newBlockType='';
            replacementInfo.newRefBlock='';
        end
    else

        replacementInfo=map{1};
    end

end

function power_LicMgrUpdate()







    objList=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'findall','on','SearchDepth',2,'FollowLinks','off','LookUnderMasks','all','type','block','mask','on');
    isJustTest=0;

    for idx=1:size(objList)



        refBlock=get_param(objList(idx),'ReferenceBlock');
        if(isempty(refBlock))

            testStr=get_param(objList(idx),'OpenFcn');
            if(isempty(testStr))
                if(~isJustTest)
                    set_param(objList(idx),'OpenFcn','power_openblockproxy();');
                end
            else
                newStr=sprintf('if (power_openblockproxy (''secondary''))\n%s\nend;',testStr);
                set_param(objList(idx),'OpenFcn',newStr);

                tmpName=get_param(objList(idx),'Name');
                disp(['Block: ''',tmpName,''' already has OpenFcn ',testStr]);
                disp([newStr]);
            end



            tmpInitCode=get_param(objList(idx),'MaskInitialization');
            tmpInitCode=strtrim(tmpInitCode);

            if(~isempty(tmpInitCode)||size(tmpInitCode,1)>0)
                newInit=sprintf('%s\n%s',tmpInitCode',...
                'power_initmask();')
            else
                newInit='power_initmask();';
            end
            if(~isJustTest)
                set_param(objList(idx),'MaskInitialization',newInit);
            end

            isModifiable=get_param(objList(idx),'MaskSelfModifiable');
            if(strcmp(isModifiable,'off'))
                blkName=get_param(gcb,'Name');
                disp(['Now Modifiable: ',blkName]);
            end
            if(~isJustTest)
                set_param(objList(idx),'MaskSelfModifiable','on');
            end
        end
    end
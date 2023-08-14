function[fn_list,missing,reference2flist,reference2missing]=model_impl(mdlFileName,followLinks)





    fn_list={};
    missing={};

    reference2flist={};
    reference2missing={};




    componentReference='SimscapeComponent';




    mdlFullFileName=which(mdlFileName);
    if~isempty(mdlFullFileName)&&...
        ~strcmpi(mdlFullFileName,'Not on MATLAB path')

        fn_list=[fn_list,mdlFullFileName];

    else
        pm_error('physmod:simscape:simscape:dependency:model:NonExistingModel',mdlFileName);
    end






    if~bdIsLoaded(mdlFileName)
        pm_error('physmod:simscape:simscape:dependency:model:NonLoadedModel',mdlFileName);
    end





    pmBlockListOrig=find_system(mdlFileName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks',followLinks,...
    'BlockType','SubSystem');


    pmBlockListCore=find_system(mdlFileName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks',followLinks,...
    'Regexp','on',...
    'BlockType','SimscapeBlock|SimscapeComponentBlock');
    pmBlockList=[pmBlockListOrig;pmBlockListCore];



    sourceFileList={};
    fcnHandle=@simscape.compiler.sli.internal.functioncallfromblock;
    for i=1:numel(pmBlockList)

        currentBlock=pmBlockList{i};


        [callName,isSimscapeBlock]=fcnHandle(currentBlock);



        if isSimscapeBlock
            sourceFile=which(callName);

            if isempty(sourceFile)||strcmpi(sourceFile,'Not on MATLAB path')
                [isIn,loc]=ismember(callName,missing);

                if isIn


                    reference2missing{loc}.names{end+1}=currentBlock;%#ok<AGROW>
                    reference2missing{loc}.type{end+1}=componentReference;%#ok<AGROW>
                else
                    missing=[missing,{callName}];%#ok<AGROW>

                    ref.names={currentBlock};
                    ref.type={componentReference};

                    reference2missing{end+1}=ref;%#ok<AGROW>
                end
            else
                [isIn,loc]=ismember(sourceFile,sourceFileList);

                if isIn


                    reference2flist{loc}.names{end+1}=currentBlock;%#ok<AGROW>
                    reference2flist{loc}.type{end+1}=componentReference;%#ok<AGROW>
                else
                    sourceFileList=[sourceFileList,sourceFile];%#ok<AGROW>

                    ref.names={currentBlock};
                    ref.type={componentReference};

                    reference2flist{end+1}=ref;%#ok<AGROW>
                end
            end
        end
    end




    fullLibraryList={};
    ref2libList={};





    [fileList,missingList,reference2fileList,reference2missingList]...
    =simscape.dependency.internal.recursion(...
    sourceFileList,fullLibraryList,simscape.DependencyType.All,...
    false,reference2flist,ref2libList);




    fn_list=[fn_list,fileList];

    rf.names={};
    rf.type={};

    reference2flist=[{rf},reference2fileList];




    for j=1:numel(missingList)

        [isIn,loc]=ismember(missingList{j},missing);

        if~isIn
            missing{end+1}=missingList{j};%#ok<AGROW>



            ref.names=reference2missingList{j}.names;
            ref.type=reference2missingList{j}.type;

            reference2missing{end+1}=ref;%#ok<AGROW>
        else

            for i=1:numel(reference2missingList{j}.names)

                fileName=reference2missingList{j}.names{i};
                refType=reference2missingList{j}.type{i};

                [isIn,loc2]=ismember(fileName,reference2missing{loc}.names);



                if~isIn
                    reference2missing{loc}.names{end+1}=fileName;%#ok<AGROW>
                    reference2missing{loc}.type{end+1}=refType;%#ok<AGROW>
                else
                    if~strcmpi(reference2missing{loc}.type{loc2},refType)
                        reference2missing{loc}.names{end+1}=fileName;%#ok<AGROW>
                        reference2missing{loc}.type{end+1}=refType;%#ok<AGROW>
                    end
                end
            end

        end
    end
end


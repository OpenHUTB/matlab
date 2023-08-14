function subsystem2sscimpl(blockPath,target)






    try
        blockPath=getfullname(blockPath);
        if(numel(string(blockPath))~=1)
            pm_error('physmod:simscape:simscape:subsystem2ssc:NonScalarInput');
        end
        if(~strcmp(get_param(blockPath,'BlockType'),'SubSystem'))
            pm_error('physmod:simscape:simscape:subsystem2ssc:NotASubsystem',blockPath);
        end

        lCheckBlockValidity(blockPath)


        strs=strsplit(blockPath,'/');
        modelName=strs{1};
        set_param(modelName,'SimulationCommand','update');
        sf=simscape.compiler.sli.componentModel(modelName,false);
        if numel(sf)==1
            sf={sf};
        end


        sscFiles=network2ssc(modelName,blockPath,sf);


        if~exist(target,'dir')
            mkdir(target);
        end
        for i=1:length(sscFiles)
            filepath=strcat(target,filesep,sscFiles(i).filename);
            lCheckFileExists(filepath);
        end
        for i=1:length(sscFiles)
            filepath=strcat(target,filesep,sscFiles(i).filename);
            lCheckNumPorts(sscFiles(i).objectinfo,sscFiles(i).numports,filepath);
            lWriteToFile(filepath,sscFiles(i).objectinfo,sscFiles(i).contents);
        end
    catch e
        throwAsCaller(e);
    end


    function lCheckBlockValidity(blockPath)





        blocks=find_system(blockPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on');
        blockTypes=get_param(blocks,'BlockType');
        maskTypes=get_param(blocks,'MaskType');


        invalidBlocks="";
        for i=1:length(blocks)
            if any(strcmp(maskTypes{i},{sprintf('Solver\nConfiguration'),...
                sprintf('Simulink-PS\nConverter'),...
                sprintf('PS-Simulink\nConverter')}))
                invalidBlocks=invalidBlocks+"'"+blocks{i}+"'"+newline;
            end
        end
        if invalidBlocks~=""
            pm_error('physmod:simscape:simscape:subsystem2ssc:UnsupportedBlocks',invalidBlocks);
        end


        invalidBlocks="";
        for i=1:length(blocks)
            if~any(strcmp(blockTypes{i},{'SimscapeBlock',...
                'SimscapeComponentBlock',...
                'PMIOPort',...
                'SubSystem'}))
                invalidBlocks=invalidBlocks+"'"+blocks{i}+"'"+newline;
            end
        end
        if invalidBlocks~=""
            pm_error('physmod:simscape:simscape:subsystem2ssc:UnsupportedBlocks',invalidBlocks);
        end


        if(~any(strcmp(blockTypes,'SimscapeBlock'))&&...
            ~any(strcmp(blockTypes,'SimscapeComponentBlock')))
            pm_error('physmod:simscape:simscape:subsystem2ssc:NoBlocks',blockPath);
        end

        function lCheckFileExists(filepath)



            if exist(filepath,'file')
                pm_error('physmod:simscape:simscape:subsystem2ssc:FileAlreadyExists',filepath);
            end

            function lCheckNumPorts(blockPath,numPorts,filePath)



                ports=get_param(blockPath,'Ports');
                actPorts=ports(6)+ports(7);

                if actPorts~=numPorts
                    pm_warning('physmod:simscape:simscape:subsystem2ssc:PortMismatch',filePath,blockPath);
                end

                function lWriteToFile(filepath,blockPath,contents)



                    fid=fopen(filepath,'w+');
                    if fid==-1
                        pm_error('physmod:simscape:simscape:subsystem2ssc:FailedToOpenFile',filepath);
                    end

                    lWriteHeader(fid,blockPath);
                    fprintf(fid,'%s',contents);
                    fclose(fid);

                    function lWriteHeader(fileId,blockPath)


                        mVer=ver('matlab');
                        slVer=ver('simulink');
                        ssVer=ver('simscape');
                        [mVerNum,slVerNum,ssVerNum]=deal('unknown');
                        if~isempty(mVer)
                            mVerNum=mVer.Version;
                        end
                        if~isempty(slVer)
                            slVerNum=slVer.Version;
                        end
                        if~isempty(ssVer)
                            ssVerNum=ssVer.Version;
                        end

                        headerMsg=message('physmod:simscape:simscape:subsystem2ssc:FileHeader',...
                        strrep(blockPath,newline,' '),mVerNum,slVerNum,ssVerNum,datestr(now));
                        fprintf(fileId,'%s\n\n',headerMsg.getString);

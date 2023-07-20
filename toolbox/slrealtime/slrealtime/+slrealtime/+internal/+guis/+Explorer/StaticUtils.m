classdef StaticUtils







    methods(Static)




        function blockPath=convertBlockPathsToDisplayString(blockPaths)


















            if isempty(blockPaths)
                blockPath=blockPaths;
                return;
            end

            if isa(blockPaths,'Simulink.SimulationData.BlockPath')
                blockPaths=blockPaths.convertToCell();
            end

            if~iscell(blockPaths)
                blockPath=blockPaths;
                return;
            end

            if length(blockPaths)==1
                blockPath=blockPaths{1};
                return;
            end

            blockPath=blockPaths{1};
            for nBlockPath=2:length(blockPaths)
                idxs=strfind(blockPaths{nBlockPath},'/');
                assert(~isempty(idxs));
                blockPath=strcat(blockPath,blockPaths{nBlockPath}(idxs(1):end));
            end
        end

        function blockPath=convertBlockPathsToDisplayStringForSignal(blockPaths,portNumber,statename)









            assert(isnumeric(portNumber));
            assert(length(portNumber)==1);

            blkpath=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayString(blockPaths);
            if~isempty(statename)
                blockPath=strcat(blkpath,':',statename);
            else
                blockPath=strcat(blkpath,':',num2str(portNumber));
            end
        end

        function key=convertToParamValuesCacheKey(blockPath,paramName)



























            blkPathStr=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayString(blockPath);





            blkPathStr=regexprep(blkPathStr,newline,' ');

            key=strcat(blkPathStr,':',paramName);
        end

        function enableDisableWidgets(widget,val)




            try
                widget.Enable=val;
            catch

            end
            try
                if~isempty(widget.Children)
                    for i=1:length(widget.Children)
                        try
                            widget.Children(i).Enable=val;
                        catch
                        end
                        try
                            if~isempty(widget.Children(i).Children)
                                slrealtime.internal.guis.Explorer.StaticUtils.enableDisableWidgets(widget.Children(i),val);
                            end
                        catch
                        end
                    end
                else

                    return;
                end
            catch

                return;
            end
        end

        function str=num2string(v)



            s=string(num2str(v));
            if length(s)==1
                if isscalar(v)
                    str=s;
                else
                    str=sprintf("[%s]",s);
                end
            else
                str="[";
                for j=1:length(s)
                    str=strcat(str,s(j),"; ");
                end
                str=strcat(str,"]");
            end
        end

        function[paramNameStr,paramNameDims]=parseForIndex(paramName)

















            if contains(paramName,'(')

                parsedParamName=regexp(paramName,'([^\(])*\(([^\)]*)\)','tokens');
                if length(parsedParamName)~=1||...
                    length(parsedParamName{1})~=2||...
                    isempty(parsedParamName{1}{1})||...
                    isempty(parsedParamName{1}{2})




                    paramNameStr=paramName;
                    paramNameDims=[];
                else
                    paramNameStr=parsedParamName{1}{1};
                    paramNameDimsStr=parsedParamName{1}{2};
                    paramNameDims=cellfun(@(x)str2num(x),split(paramNameDimsStr,','))';
                end
            else

                paramNameStr=paramName;
                paramNameDims=[];
            end
        end

    end


    methods(Static)



        function tg=getSLRTTargetObject(targetName)




            tg=[];
            try



                tg=slrealtime(targetName);
            catch
            end
        end

        function application=getSLRTStartupAppName(targetName)
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            try
                application=tg.getStartupApp();
            catch
                application=[];
                return;
            end
        end

        function apps=getSLRTInstalledApps(targetName)
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            try
                res=tg.executeCommand(['ls ',tg.appsDirOnTarget]);
            catch
                apps=[];
                return;
            end
            apps=split(res.Output);
            idxs=cellfun(@(x)~isempty(x),apps);
            if isempty(idxs)
                apps=[];
            else
                apps=apps(idxs);
            end
        end

        function connected=isSLRTTargetConnected(targetName)




            connected=false;
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            if~isempty(tg)
                connected=tg.isConnected();
            end

        end


        function defaultTargetName=getSLRTDefaultTargetName()



            targets=slrealtime.Targets;
            defaultTargetName=targets.getDefaultTargetName;
        end

        function[ipaddr,netmask]=getSLRTIpAddrAndNetMask(targetName)
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);




            if(isempty(tg.TargetSettings.address))
                ipaddr=[];
                netmask=[];
                return;
            end

            filename='slrtipaddr';
            dirOnHost=tempname;
            mkdir(dirOnHost);
            fileOnHost=fullfile(dirOnHost,filename);
            tg.receiveFile(strcat('/etc/',filename),fileOnHost);

            fid=fopen(fileOnHost);
            c=onCleanup(@()fclose(fid));

            str=textscan(fid,'%s %s %s');

            ipaddr=str{1};
            while iscell(ipaddr)
                ipaddr=ipaddr{1};
            end

            netmask=str{3};
            while iscell(netmask)
                netmask=netmask{1};
            end
        end



        function match=isDuplicateIP(newAddr)
            match=false;


            targets=slrealtime.Targets;
            targetList=targets.getTargetNames;
            for i=1:length(targetList)
                target=targets.getTarget(targetList{i});
                if(strcmp(target.TargetSettings.address,newAddr))
                    match=true;
                    return;
                end
            end
        end

    end
end

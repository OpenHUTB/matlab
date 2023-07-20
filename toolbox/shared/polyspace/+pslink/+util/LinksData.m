classdef LinksData




    methods(Static=true)




        function dlinkInfo=ExtractLinksData(slModelName,isRTW,slModelFileName,slModelVersion)

            if nargin<2
                isRTW=true;
            end
            if nargin<3
                slModelFileName='';
            end
            if nargin<4
                slModelVersion='';
            end


            dlinkInfo.name=slModelName;
            dlinkInfo.source='psLinkInfo';
            dlinkInfo.model=slModelFileName;
            dlinkInfo.version=slModelVersion;
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                systemList=find_system(slModelName,'LookUnderMasks','all',...
                'FollowLinks','on','MatchFilter',@Simulink.match.codeCompileVariants);
            else
                systemList=find_system(slModelName,'LookUnderMasks','all','FollowLinks','on','Variants','ActivePlusCodeVariants');
            end
            linksList={};
            useGetrtwnameFile=exist(fullfile(matlabroot,'toolbox','rtw','rtw','private','getrtwname'),'file')==2;

            for ii=1:numel(systemList)
                sysObj=get_param(systemList{ii},'Object');
                if~(isa(sysObj,'Simulink.BlockDiagram'))

                    linksList{end+1}={systemList{ii},strrep(get_param(systemList{ii},'Name'),'/','//'),'/'};%#ok<AGROW>


                    chartObj=sysObj.find('-isa','Stateflow.Chart');
                    if~isempty(chartObj)
                        sfStateList=chartObj.find('-isa','Stateflow.State');
                        for jj=1:numel(sfStateList)
                            linksList{end+1}={sfStateList(jj).Chart.Path,num2str(sfStateList(jj).SSIdNumber),':'};%#ok<AGROW>
                        end
                        sfTransitionList=chartObj.find('-isa','Stateflow.Transition');
                        for jj=1:numel(sfTransitionList)
                            linksList{end+1}={sfTransitionList(jj).Chart.Path,num2str(sfTransitionList(jj).SSIdNumber),':'};%#ok<AGROW>
                        end
                        sfJunctionList=chartObj.find('-isa','Stateflow.Junction');
                        for jj=1:numel(sfJunctionList)
                            linksList{end+1}={sfJunctionList(jj).Chart.Path,num2str(sfJunctionList(jj).SSIdNumber),':'};%#ok<AGROW>
                        end
                    end
                end
            end

            dlinkInfo.info(1:numel(linksList))=pslink.verifier.Coder.createLinkDataInfoStruct();
            for ii=1:numel(linksList)
                linksData=linksList{ii};
                longname=char(linksData(1));
                if isRTW

                    if useGetrtwnameFile
                        shortname=rtwprivate('getrtwname',longname);
                    else
                        h=get_param(longname,'Object');
                        shortname=h.getRTWName;
                    end
                    if strcmpi(char(linksData(3)),':')
                        dlinkInfo.info(ii).codename=[shortname,char(linksData(3)),char(linksData(2))];
                    else
                        dlinkInfo.info(ii).codename=shortname;
                    end
                else
                    dlinkInfo.info(ii).codename='';
                end
                dlinkInfo.info(ii).name=char(linksData(2));
                dlinkInfo.info(ii).path=longname;
                dlinkInfo.info(ii).sid=Simulink.ID.getSID(longname);
            end

        end




        function errMsg=writeNewDataLinkFile(dataLinkInfo,lnkFileName,codeGenName)
            errMsg='';
            [fid,status]=fopen(lnkFileName,'wt','native','UTF-8');
            if~isempty(status)
                errMsg=sprintf('Cannot open %s (%s).',lnkFileName,status);
                return
            end
            cObj=onCleanup(@()fclose(fid));

            currentVersion=ver('MATLAB');

            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
            fprintf(fid,'<linksdata rev="1.4">\n');
            fprintf(fid,'  <matlab version="%s" path="%s" codegen="%s"/>\n',currentVersion.Version,matlabroot,codeGenName);
            for ii=1:numel(dataLinkInfo)
                data=dataLinkInfo(ii);
                fprintf(fid,'  <model name="%s" source="%s" path="%s" version="%s">\n',...
                data.name,data.source,data.model,...
                polyspace.util.XmlHelper.escapeCharacterForXml(data.version,false));
                fprintf(fid,'    <files>\n');
                for jj=1:numel(data.sourcefile)
                    fprintf(fid,'      <filename>%s</filename>\n',nReplaceCharforXML(data.sourcefile{jj}));
                end
                fprintf(fid,'    </files>\n');
                for jj=1:numel(data.info)
                    blkName=nReplaceCharforXML(data.info(jj).name);
                    rtwName=nReplaceCharforXML(data.info(jj).codename);
                    rtwName=regexprep(rtwName,'\n',' ');
                    pathName=nReplaceCharforXML(data.info(jj).path);
                    sid=nReplaceCharforXML(data.info(jj).sid);
                    fprintf(fid,'    <link>\n');
                    fprintf(fid,'      <blockname>%s</blockname>\n',blkName);
                    fprintf(fid,'      <rtwname>%s</rtwname>\n',rtwName);
                    fprintf(fid,'      <pathname>%s</pathname>\n',pathName);
                    fprintf(fid,'      <sid>%s</sid>\n',sid);
                    fprintf(fid,'    </link>\n');
                end
                if isfield(data,'ctmRec')
                    for jj=1:numel(data.ctmRec)
                        token=nReplaceCharforXML(data.ctmRec(jj).token);
                        locFile=nReplaceCharforXML(data.ctmRec(jj).file);
                        locLine=num2str(data.ctmRec(jj).line);
                        beginCol=num2str(data.ctmRec(jj).beginCol);
                        sid=nReplaceCharforXML(data.ctmRec(jj).sid{1});
                        fprintf(fid,'    <codetomodel>\n');
                        fprintf(fid,'      <token>%s</token>\n',token);
                        fprintf(fid,'      <file>%s</file>\n',locFile);
                        fprintf(fid,'      <line>%s</line>\n',locLine);
                        fprintf(fid,'      <begin>%s</begin>\n',beginCol);
                        fprintf(fid,'      <sidlink>%s</sidlink>\n',sid);
                        fprintf(fid,'    </codetomodel>\n');
                    end
                end
                fprintf(fid,'  </model>\n');
            end
            fprintf(fid,'</linksdata>\n');

            function str=nReplaceCharforXML(str)
                str=strrep(str,'&','&amp;');
                str=strrep(str,'<','&lt;');
                str=strrep(str,'>','&gt;');
            end
        end
    end

end



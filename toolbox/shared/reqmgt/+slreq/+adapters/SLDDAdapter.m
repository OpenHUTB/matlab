classdef SLDDAdapter<slreq.adapters.BaseAdapter



    properties(Constant)
        icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','DictionaryIcon.png');
    end

    properties



temporaryDisabledDD
    end

    methods
        function this=SLDDAdapter()
            this.domain='linktype_rmi_data';
            this.temporaryDisabledDD='';
        end



        function out=getIcon(this,artifact,id)
            if this.isResolved(artifact,id)
                out=this.icon;
            else
                out=slreq.gui.IconRegistry.instance.warning;
            end
        end



        function tf=isResolved(this,artifact,id)

            try







                ddFile=this.getOpenedTargetDDFileForResolving(artifact);

                if~isempty(ddFile)
                    tf=~isempty(rmide.getEntryPath(ddFile,id));
                else
                    tf=false;
                end
            catch ex %#ok<NASGU>
                tf=false;
            end
        end

        function success=select(this,artifactUri,id,~)
            success=true;
            try
                rmi.navigate(this.domain,artifactUri,id);
            catch
                success=false;
            end
        end

        function success=highlight(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            success=this.select(artifact,id,caller);
        end

        function label=getSummary(this,artifact,id)
            if nargin<3



                [~,label]=rmide.getObjInfo(artifact);
                return;
            end
            [~,baseName]=fileparts(artifact);

            targetArtifact=this.getOpenedTargetDDFileForResolving(artifact);
            if isempty(targetArtifact)
                label=sprintf('%s:%s',baseName,'??');
            else
                try
                    label=rmide.getEntryPath(targetArtifact,id);
                    if isempty(label)
                        label=[obj.artifactUri,':',obj.id];
                    end
                catch ex %#ok<NASGU>

                    label=sprintf('%s:%s',baseName,'??');
                end
            end
        end

        function navCmd=getExternalNavCmd(~,artifact,id)
            if nargin<3



                navCmd=rmide.getObjInfo(artifact,'none');
            else
                shortNameExt=slreq.uri.getShortNameExt(artifact);
                navCmd=['rmiobjnavigate(''',shortNameExt,''',''',id,''');'];
            end
        end

        function tooltip=getTooltip(this,artifact,id)
            targetArtifact=this.getOpenedTargetDDFileForResolving(artifact);
            if isempty(targetArtifact)
                tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForSLDD'));
            else
                try
                    label=rmide.getEntryPath(targetArtifact,id);
                    if isempty(label)
                        tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForSLDD'));
                    else
                        tooltip=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',label,artifact));
                    end
                catch ex %#ok<NASGU>

                    tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForSLDD'));
                end
            end
        end

        function apiObj=getSourceObject(this,artifact,id)%#ok<INUSL>

            [entryPath,msg]=rmide.getEntryPath(artifact,id);
            if isempty(entryPath)
                error('Slreq:structToObj:SLDDError',msg)
            end



            entryName=extractAfter(entryPath,'.');

            ddObj=Simulink.data.dictionary.open(artifact);



            sections={'Design Data','Configuration'};
            for n=1:length(sections)
                secObj=ddObj.getSection(sections{n});
                apiObj=secObj.getEntry(entryName);
                if~isempty(apiObj)
                    break;
                end
            end
        end

        function success=onClickHyperlink(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            this.select(artifact,id,caller);
            success=true;
        end

        function cmdStr=getClickActionCommandString(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            cmdStr=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''',''%s'')',this.domain,artifact,id,caller);
        end

        function path=getFullPathToArtifact(~,artifact,~)
            path=which(artifact);
        end

        function targetArtifact=getOpenedTargetDDFileForResolving(this,ddFileName)
            targetArtifact=this.findOpenDD(ddFileName);
            if isempty(targetArtifact)
                targetArtifact=rmide.getReferencingDDFile(ddFileName);
            end
        end

        function ddFile=findOpenDD(this,artifact)
            ddFile=findLoadedDD(artifact);
            if isempty(ddFile)
                return;
            else




                if~isempty(this.temporaryDisabledDD)&&strcmp(this.temporaryDisabledDD,ddFile)
                    ddFile='';
                end
            end
        end
    end
end

function ddPath=findLoadedDD(ddFileName)
    [dirName,ddName,ddExt]=fileparts(ddFileName);
    if isempty(ddExt)||~strcmpi(ddExt,'.sldd')
        ddExt='.sldd';
    end











    ddPaths=Simulink.dd.getOpenDictionaryPaths([ddName,ddExt]);
    switch length(ddPaths)
    case 0
        ddPath='';
    case 1
        ddPath=ddPaths{1};
    otherwise

        if isempty(dirName)
            ddPath=ddPaths{end};
        else
            fullPathMatch=find(strcmp(ddPaths,ddFileName));
            if~isempty(fullPathMatch)
                ddPath=ddPaths{fullPathMatch(end)};
            else
                ddPath=ddPaths{end};
            end
        end
    end
end


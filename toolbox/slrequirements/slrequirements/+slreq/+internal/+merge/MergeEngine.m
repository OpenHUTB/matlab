

classdef MergeEngine<handle


    properties(SetAccess=immutable)
        InFileBase(1,:)char{mustBeNonempty}=' ';
        InFileTheirs(1,:)char{mustBeNonempty}=' ';
        InFileMine(1,:)char{mustBeNonempty}=' ';
        OutFileTarget(1,:)char{mustBeNonempty}=' ';
    end

    properties(Access=private)

        Token(1,:)char{mustBeNonempty}=' ';
        TargetLinks containers.Map;
        IsInputLoaded(1,1){islogical}=false;
        IsOutputLoaded(1,1){islogical}=false;
        CountAccepts(1,1)int32{mustBeInteger,mustBeNonnegative}=0;
        CountRejects(1,1)int32{mustBeInteger,mustBeNonnegative}=0;

        CachedBase;
        CachedTheirs;
        CachedMine;
        TargetLinkSet;

        NewWorkArea(1,:)char='';
        OldWorkArea(1,:)char='';
        TargetFileBackup(1,:)char='';
        TargetFileFullpath(1,:)char='';
    end


    methods

        function this=MergeEngine(baseFile,mineFile,theirsFile,targetFile)
            this.InFileBase=baseFile;
            this.InFileTheirs=theirsFile;
            this.InFileMine=mineFile;
            this.OutFileTarget=targetFile;
            this.TargetLinks=containers.Map('KeyType','char','ValueType','any');

            this.IsOutputLoaded=false;
            this.IsInputLoaded=false;
        end

    end


    methods(Access=private)

        function[tf,bakFile]=backupFile(~,origFile,Token)
            if isfile(origFile)
                [partPath,partMain,partExt]=fileparts(origFile);
                if isempty(partPath)
                    partPath=pwd;
                end
                bakFile=fullfile(partPath,[partMain,'-',Token,partExt]);
                tf=copyfile(origFile,bakFile);
            else
                bakFile='';
                tf=false;
            end
        end

        function[status,msgs]=cacheInputFiles(this)
            import slreq.internal.merge.*;
            msgs={};

            this.CachedBase=InMemoryLinkSet(this.InFileBase);
            this.CachedTheirs=InMemoryLinkSet(this.InFileTheirs);
            this.CachedMine=InMemoryLinkSet(this.InFileMine);

            [status,msg]=this.CachedBase.loadLinks();
            if~status
                msgs=[msgs,msg];
                return;
            end

            [status,msg]=this.CachedTheirs.loadLinks();
            if~status
                msgs=[msgs,msg];
                return;
            end

            [status,msg]=this.CachedMine.loadLinks();
            if~status
                msgs=[msgs,msg];
                return;
            end

            this.IsInputLoaded=...
            ~isempty(this.CachedBase)&&this.CachedBase.IsSrcLoaded&&...
            ~isempty(this.CachedTheirs)&&this.CachedTheirs.IsSrcLoaded&&...
            ~isempty(this.CachedMine)&&this.CachedMine.IsSrcLoaded;

            status=this.IsInputLoaded;


            if status

                [~,baseMain,baseExt]=fileparts(strrep(this.CachedBase.Artifact,'\','/'));
                [~,mineMain,mineExt]=fileparts(strrep(this.CachedMine.Artifact,'\','/'));
                [~,theirsMain,theirsExt]=fileparts(strrep(this.CachedTheirs.Artifact,'\','/'));

                if~isequal([baseMain,baseExt],[mineMain,mineExt],[theirsMain,theirsExt])
                    msg=sprintf('Input Link Set files correspond to different source artifacts: "%s" "%s" "%s"',...
                    this.CachedBase.Artifact,...
                    this.CachedMine.Artifact,...
                    this.CachedTheirs.Artifact);
                    msgs=[msgs,msg];
                    status=false;
                end
            end

        end

        function[status,msgs]=loadOutputFile(this)
            import slreq.internal.merge.*;
            status=false;
            msgs={};


            w1=warning('off','Slvnv:slreq:ArtifactMismatch');
            wc1=onCleanup(@()warning(w1));
            w2=warning('off','Slvnv:slreq:UnableToLocateReqSetReferencedBy');
            wc2=onCleanup(@()warning(w2));
            w3=warning('off','Slvnv:slreq:LinksAlreadyLoaded');
            wc3=onCleanup(@()warning(w3));
            try
                this.TargetLinkSet=slreq.load(this.TargetFileFullpath);
            catch ME
                msg=sprintf('Unable to load input Link Set file: "%s"',this.TargetFileFullpath);
                msgs=[msgs,msg];
                msgs=[msgs,ME.message];
                return;
            end

            if~isempty(this.TargetLinkSet)


                allLinks=InMemoryLinkSet.getLinks(this.TargetLinkSet);
                for i=1:length(allLinks)
                    theLinkObj=allLinks(i);
                    theLinkKey=InMemoryLink.generateKey(theLinkObj);
                    this.TargetLinks(theLinkKey)=theLinkObj;
                end

                this.IsOutputLoaded=true;
                status=true;

            else

                this.IsOutputLoaded=false;
                msg=sprintf('Unable to load input Link Set file: "%s"',this.TargetFileFullpath);
                msgs=[msgs,msg];

            end

        end

        function[status,msgs]=doPreMerge(this)
            msgs={};


            this.Token=datestr(now,'yyyymmddTHHMMss');
            this.CountAccepts=0;
            this.CountRejects=0;


            [status,msg]=this.cacheInputFiles();
            if~status
                msgs=[msgs,msg];
                msg='Reading input Link Set files failed';
                msgs=[msgs,msg];
                return;
            end


            [copied,this.TargetFileBackup]=this.backupFile(this.OutFileTarget,this.Token);
            if copied
                msg=sprintf('Existing target file found: "%s". It is backed up at: "%s"',...
                this.OutFileTarget,this.TargetFileBackup);
                msgs=[msgs,msg];
            end

            [TargetFileDir,TargetFileMain,TargetFileExt]=fileparts(this.OutFileTarget);
            if isempty(TargetFileDir)
                TargetFileDir=pwd;
            end
            this.TargetFileFullpath=fullfile(TargetFileDir,[TargetFileMain,TargetFileExt]);


            [status,msg]=copyfile(this.InFileTheirs,this.TargetFileFullpath);
            if~status
                msgs=[msgs,msg];
                return;
            end


            this.NewWorkArea=tempname(pwd);
            [status,msg]=mkdir(this.NewWorkArea);
            if~status
                this.NewWorkArea='';
                this.OldWorkArea='';
                msgs=[msgs,msg];
                return;
            end


            this.OldWorkArea=pwd;
            cd(this.NewWorkArea);


            [status,msg]=this.loadOutputFile();
            if~status
                msgs=[msgs,msg];
                msg='Internal error: creating target Link Set file failed';
                msgs=[msgs,msg];
                return;
            end

            status=this.IsInputLoaded&&this.IsOutputLoaded;

        end

        function[status,msgs]=unloadOutputFile(this)
            status=true;
            msgs={};


            if this.IsOutputLoaded

                if this.TargetLinkSet.Dirty

                    try
                        this.TargetLinkSet.save(this.TargetFileFullpath);
                    catch ME
                        msg=sprintf('Unable to save target Link Set file: "%s"',this.TargetFileFullpath);
                        msgs=[msgs,msg];
                        msgs=[msgs,ME.message];
                        status=false;
                    end
                end

                slreq.close(this.TargetFileFullpath);
                slreq.clear();

            else

                status=false;
                msg='Internal error: target Link Set file not loaded';
                msgs=[msgs,msg];

            end

        end

        function msgs=logMessages(this,msgs)

            logFileName=[this.Token,'.log'];
            [logFileId,msg]=fopen(logFileName,'w');

            if logFileId<0
                msg=sprintf('Unable to create log file: %s',msg);
                msgs=[msgs,msg];
                return;
            end

            wc=onCleanup(@()fclose(logFileId));

            for i=1:length(msgs)
                fprintf(logFileId,'%d: %s\n',i,msgs{i});
            end

            msg=sprintf('Log file created: "%s"',logFileName);
            msgs=[msgs,msg];

        end

        function[status,msgs]=doPostMerge(this,msgs)
            status=true;


            [saved,msg]=this.unloadOutputFile();
            if~saved
                status=false;
                msgs=[msgs,msg];
                msg='Internal error: saving target Link Set file failed';
                msgs=[msgs,msg];
            end


            if isfolder(this.OldWorkArea)
                cd(this.OldWorkArea);
            end
            if isfolder(this.NewWorkArea)&&~strcmp(this.NewWorkArea,this.OldWorkArea)
                rmdir(this.NewWorkArea);
            end
            this.OldWorkArea='';
            this.NewWorkArea='';

            msg=sprintf('Total merges: %d',this.CountAccepts);
            msgs=[msgs,msg];

            if saved&&this.CountAccepts>0
                msg=sprintf('Accepted changes can be viewed by command: visdiff ( "%s" , "%s" )',...
                this.InFileTheirs,this.TargetFileFullpath);
                msgs=[msgs,msg];
            end

            if saved&&this.CountRejects>0
                status=false;
                msg=sprintf('Total conflicts: %d',this.CountRejects);
                msgs=[msgs,msg];

                msg=sprintf('Conflicts can be viewed by command: visdiff ( "%s" , "%s" )',...
                this.InFileMine,this.TargetFileFullpath);
                msgs=[msgs,msg];
            end


            msgs=this.logMessages(msgs);


            this.Token=' ';
            this.CountAccepts=0;
            this.CountRejects=0;

        end

    end


    methods(Access=private)






        function[status,msgs]=reportConflictFields(this,~,~,~,~)

            this.CountRejects=this.CountRejects+1;

            status=false;
            msgs={'Merge Error: Conflicts at link field level'};

        end




        function[status,msgs]=reportConflictLink(this,~,~)

            this.CountRejects=this.CountRejects+1;

            status=false;
            msgs={'Merge Error: Conflicts at link level'};

        end




        function[status,msgs]=copyLinkFields(this,linkToCopyFrom,fieldsToCopy)
            status=false;
            msgs={};

            linkInTarget=[];
            linkInTargetKey=linkToCopyFrom.Key;
            if this.TargetLinks.isKey(linkInTargetKey)
                linkInTarget=this.TargetLinks(linkInTargetKey);
            end

            if numel(linkInTarget)>1
                msg='Internal error: more than one link for given search key';
                msgs=[msgs,msg];
            elseif numel(linkInTarget)==0
                msg='Internal error: no link for given search key';
                msgs=[msgs,msg];
            else

                if fieldsToCopy.isKey("Rationale")
                    linkInTarget.Rationale=fieldsToCopy("Rationale");
                end

                if fieldsToCopy.isKey("Description")
                    linkInTarget.Description=fieldsToCopy("Description");
                end

                if fieldsToCopy.isKey("Type")
                    linkInTarget.Type=fieldsToCopy("Type");
                end

                if fieldsToCopy.isKey("Keywords")
                    linkInTarget.Keywords=fieldsToCopy("Keywords");
                end

                if fieldsToCopy.isKey("Source")
                    if ismethod(linkInTarget,'setSource')
                        linkInTarget.setSource(fieldsToCopy("Source"));
                    else
                        msg='Warning: Can not merge changes in "Source".';
                        msgs=[msgs,msg];
                    end
                end

                if fieldsToCopy.isKey("Destination")
                    if ismethod(linkInTarget,'setDestination')
                        linkInTarget.setDestination(fieldsToCopy("Destination"));
                    else
                        msg='Warning: Can not merge changes in "Destination".';
                        msgs=[msgs,msg];
                    end
                end

                status=true;


                this.CountAccepts=this.CountAccepts+1;

            end

        end



        function[status,msgs]=appendLink(this,linkToCopy)
            status=false;
            msgs={};

            newSource=linkToCopy.Source;


            verLessThan18b=verLessThan('matlab','9.5.0');
            verLessThan19b=verLessThan('matlab','9.7.0');
            sourceNeedChange=~verLessThan18b&&verLessThan19b;


            if strcmp(linkToCopy.Source.domain,'linktype_rmi_simulink')...
                &&sourceNeedChange
                [~,modelName,~]=fileparts(strrep(linkToCopy.Source.artifact,'\','/'));
                newBlockId=linkToCopy.Source.id;
                newSource=[modelName,newBlockId];
            end


            if strcmp(linkToCopy.Source.domain,'linktype_rmi_slreq')...
                &&sourceNeedChange
                [~,reqsetbase,reqsetext]=fileparts(strrep(linkToCopy.Source.artifact,'\','/'));
                reqSet=slreq.load([reqsetbase,reqsetext]);
                newSource=reqSet.find('SID',str2num(linkToCopy.Source.id));
            end

            try
                linkToInsert=slreq.createLink(newSource,linkToCopy.Destination);
            catch ME
                switch ME.identifier
                case 'Slvnv:slreq:APIFailedToCreateLink'
                    msgs=[msgs,'Internal error: Unable to copy link to target Link Set file'];
                    msgs=[msgs,ME.message];
                otherwise
                    msgs=[msgs,'Unknown error'];
                    msgs=[msgs,ME.message];
                end
                return;
            end
            if isempty(linkToInsert)
                msg='Internal error: Unable to copy link to target Link Set file';
                msgs=[msgs,msg];
            else








                linkToInsert.Type=linkToCopy.Type;
                linkToInsert.Description=linkToCopy.Description;
                linkToInsert.Rationale=linkToCopy.Rationale;
                linkToInsert.Keywords=linkToCopy.Keywords;

                status=true;


                this.CountAccepts=this.CountAccepts+1;

            end

        end



        function[status,msgs]=removeLink(this,linkToRemove)
            status=false;
            msgs={};

            linkInTarget=[];
            linkInTargetKey=linkToRemove.Key;
            if this.TargetLinks.isKey(linkInTargetKey)
                linkInTarget=this.TargetLinks(linkInTargetKey);
            end

            if numel(linkInTarget)>1
                msg='Internal error: more than one link for given search key';
                msgs=[msgs,msg];
            elseif numel(linkInTarget)==0
                msg='Internal error: no link for given search key';
                msgs=[msgs,msg];
            else
                remove(linkInTarget);

                status=true;


                this.CountAccepts=this.CountAccepts+1;

            end

        end

    end


    methods

        function[status,msgs]=threeWayCompareMerge(this)


            [status0,msgs]=doPreMerge(this);



            if status0
                [status1,msg]=doMergeDestToTarget(this,false,this.CachedMine,this.CachedTheirs,this.CachedBase);
                msgs=[msgs,msg];
            else
                status1=false;
            end



            if status1
                [status2,msg]=doMergeDestToTarget(this,true,this.CachedTheirs,this.CachedMine,this.CachedBase);
                msgs=[msgs,msg];
            else
                status2=false;
            end


            [status3,msgs]=doPostMerge(this,msgs);

            status=all([status0,status1,status2,status3]);
        end

    end


    methods(Access=private)





















        function[status,msgs]=doMergeDestToTarget(this,srcIsTarget,theSource,theDestination,theBase)
            import slreq.internal.merge.*;
            status=true;
            msgs={};

            theKeys=theSource.CachedLinks.keys();
            for i=1:length(theKeys)
                theSearchKey=theKeys{i};



                isInBase=theBase.CachedLinks.isKey(theSearchKey);
                isInDst=theDestination.CachedLinks.isKey(theSearchKey);

                srcChanged=false;
                if isInBase

                    srcLink=theSource.CachedLinks(theSearchKey);
                    baseOfSrcLink=theBase.CachedLinks(theSearchKey);
                    if InMemoryLink.isModified(srcLink,baseOfSrcLink)
                        srcChanged=true;
                    end
                end

                dstChanged=false;
                if isInBase&&isInDst

                    dstLink=theDestination.CachedLinks(theSearchKey);
                    baseOfDstLink=theBase.CachedLinks(theSearchKey);
                    if InMemoryLink.isModified(dstLink,baseOfDstLink)
                        dstChanged=true;
                    end
                end

                if~isInBase


                    if srcIsTarget


                    else


                        srcLink1=theSource.CachedLinks(theSearchKey);
                        [status,msg]=this.appendLink(srcLink1);
                        if~status
                            msgs=[msgs,msg];
                            msg='Merge Error: adding link failed';
                            msgs=[msgs,msg];
                            return;
                        end

                    end

                else


                    if srcChanged


                        if isInDst


                            if srcIsTarget


                                if dstChanged



                                    baseLink10=theBase.CachedLinks(theSearchKey);
                                    dstLink10=theDestination.CachedLinks(theSearchKey);
                                    srcLink10=theSource.CachedLinks(theSearchKey);


                                    dstEdits10=baseLink10.findEdits(dstLink10);
                                    dstEdits10Keys=dstEdits10.keys();


                                    srcEdits10=baseLink10.findEdits(srcLink10);
                                    srcEdits10Keys=srcEdits10.keys();


                                    bothEdit10Keys=intersect(dstEdits10Keys,srcEdits10Keys);

                                    if isempty(bothEdit10Keys)



                                        [status,msg]=this.copyLinkFields(dstLink10,dstEdits10);
                                        if~status
                                            msgs=[msgs,msg];
                                            msg='Merge Error: copying link fields failed';
                                            msgs=[msgs,msg];
                                            return;
                                        end

                                    else



                                        [~,msg]=this.reportConflictFields(baseLink10,dstLink10,srcLink10,bothEdit10Keys);
                                        msgs=[msgs,msg];

                                    end


                                else






                                end


                            else





                            end


                        else





                            srcLink7=theSource.CachedLinks(theSearchKey);
                            baseLink7=theBase.CachedLinks(theSearchKey);
                            srcEdits7=baseLink7.findEdits(srcLink7);
                            [~,msg]=this.reportConflictLink(baseLink7,srcEdits7);
                            msgs=[msgs,msg];


                        end


                    else


                        if isInDst


                            if dstChanged




                                if srcIsTarget


                                    baseLink12=theBase.CachedLinks(theSearchKey);
                                    destLink12=theDestination.CachedLinks(theSearchKey);
                                    destEdits12=baseLink12.findEdits(destLink12);
                                    [status,msg]=this.copyLinkFields(destLink12,destEdits12);
                                    if~status
                                        msgs=[msgs,msg];
                                        msg='Merge Error: copying link fields failed';
                                        msgs=[msgs,msg];
                                        return;
                                    end
                                else


                                end


                            else






                            end


                        else




                            if srcIsTarget


                                srcLink4=theSource.CachedLinks(theSearchKey);
                                [status,msg]=this.removeLink(srcLink4);
                                if~status
                                    msgs=[msgs,msg];
                                    msg='Merge Error: removing link failed';
                                    msgs=[msgs,msg];
                                    return;
                                end

                            else


                            end


                        end


                    end


                end

            end

        end

    end
end



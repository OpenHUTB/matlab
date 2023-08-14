

classdef InMemoryLinkSet<handle


    properties(SetAccess=immutable)
        InputFile(1,:)char{mustBeNonempty}=' ';
    end

    properties
        CachedLinks containers.Map;
        IsSrcLoaded(1,1){islogical}=false;


        Filename(1,:)char{mustBeNonempty}=' ';
        Description(:,:)char;
        Domain(1,:)char{mustBeNonempty}=' ';
        Revision(1,1)int32{mustBeInteger,mustBePositive}=1;
        Artifact(1,:)char{mustBeNonempty}=' ';
    end


    methods
        function this=InMemoryLinkSet(theFile)
            this.InputFile=theFile;
            this.IsSrcLoaded=false;
            this.CachedLinks=containers.Map('KeyType','char','ValueType','any');
        end
    end


    methods(Access=private)

        function CleanupFun(~,tempFileFullPath,earlierWorkArea,temporaryWorkArea)


            if isfile(tempFileFullPath)
                delete(tempFileFullPath);
            end


            cd(earlierWorkArea);


            if isfolder(temporaryWorkArea)
                rmdir(temporaryWorkArea)
            end

        end

    end


    methods

        function[status,msgs]=loadLinks(this)
            import slreq.internal.merge.*;

            status=false;
            msgs={};

            if~isfile(this.InputFile)
                msg=sprintf('Link Set file not found: "%s"',this.InputFile);
                msgs=[msgs,msg];
                return;
            end

            [inFileFolder,inFileBase,inFileExt]=fileparts(this.InputFile);
            if isempty(inFileFolder)
                inFileFolder=pwd;
            end


            temporaryWorkArea=tempname(inFileFolder);
            [status,msg]=mkdir(temporaryWorkArea);
            if~status
                msgs=[msgs,msg];
                return;
            end


            [status,msg]=copyfile(this.InputFile,temporaryWorkArea);
            if~status
                msgs=[msgs,msg];
                return;
            end

            tempFileFullPath=fullfile(temporaryWorkArea,[inFileBase,inFileExt]);


            earlierWorkArea=pwd;
            cd(temporaryWorkArea);
            wc0=onCleanup(@()this.CleanupFun(tempFileFullPath,earlierWorkArea,temporaryWorkArea));

            w1=warning('off','Slvnv:slreq:ArtifactMismatch');
            wc1=onCleanup(@()warning(w1));
            w2=warning('off','Slvnv:slreq:UnableToLocateReqSetReferencedBy');
            wc2=onCleanup(@()warning(w2));
            w3=warning('off','Slvnv:slreq:LinksAlreadyLoaded');
            wc3=onCleanup(@()warning(w3));
            try




                loaded=slreq.find('type','LinkSet','Name',inFileBase);
                if~isempty(loaded)&&~strcmp(loaded.Filename,tempFileFullPath)


                    slreq.discardLinkSet(loaded.Filename);
                end
                theLinkSet=slreq.load(tempFileFullPath);
            catch ME
                msg=sprintf('Unable to load input Link Set file: "%s"',tempFileFullPath);
                msgs=[msgs,msg];
                msgs=[msgs,ME.message];
                status=false;
                return
            end
            if isempty(theLinkSet)
                msg=sprintf('Unable to load input Link Set file: "%s"',tempFileFullPath);
                msgs=[msgs,msg];
                status=false;
                return;
            end
            if~isa(theLinkSet,'slreq.LinkSet')
                msg=sprintf('"%s" is not a Link Set file',tempFileFullPath);
                msgs=[msgs,msg];
                status=false;
                return;
            end

            this.Filename=theLinkSet.Filename;
            this.Description=theLinkSet.Description;
            this.Domain=theLinkSet.Domain;
            this.Revision=theLinkSet.Revision;
            this.Artifact=theLinkSet.Artifact;

            if ismethod(theLinkSet,'getLinks')

                links=theLinkSet.getLinks();
            else
                links=InMemoryLinkSet.getLinks(theLinkSet);
            end

            for i=1:length(links)
                theLinkObj=InMemoryLink(links(i));
                this.CachedLinks(theLinkObj.Key)=theLinkObj;
            end

            slreq.discardLinkSet(tempFileFullPath);
            slreq.clear();

            this.IsSrcLoaded=true;
            msgs={};
            status=true;

        end

    end


    methods(Static)






        function links=getLinks(theLinkSet)

            srcs=sources(theLinkSet);
            links=struct([]);

            for i=1:length(srcs)
                outLinks=slreq.outLinks(srcs(i));
                for j=1:length(outLinks)


                    links=[links,outLinks(j)];
                end
            end

        end

    end

end

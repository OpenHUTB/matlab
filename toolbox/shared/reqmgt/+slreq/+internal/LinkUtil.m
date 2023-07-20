classdef LinkUtil<handle


    properties(Constant)
        EmbeddedReqIdDelimiter='~';
    end
    methods(Static)

        function tf=isEmbeddedReqSet(dataReqSet)
            tf=false;
            if~isempty(dataReqSet.parent)

                [~,~,fExt]=fileparts(dataReqSet.parent);

                if strcmpi(fExt,'.slx')
                    tf=true;
                end
            end
        end

        function compositeId=makeCompositeId(reqSetName,reqId)
            compositeId=[reqSetName,slreq.internal.LinkUtil.EmbeddedReqIdDelimiter,reqId];
        end

        function artPath=artifactPathToCheck(artifactPath)
            artPath=artifactPath;

            [fPath,fName,~]=fileparts(artifactPath);
            reqData=slreq.data.ReqData.getInstance();
            reqSet=reqData.getReqSet(fName);
            if~isempty(reqSet)&&~isempty(reqSet.parent)

                artPath=fullfile(fPath,reqSet.parent);
            end
        end

        function tf=isEmbededReqId(rId)
            tf=false;
            [~,reqSet]=slreq.utils.getShortIdFromLongId(rId);
            [~,~,fExt]=fileparts(reqSet);
            if strcmp(fExt,'.slreqx')
                tf=true;
            end
        end

        function[linkSetUri,reqId]=getLinkSetUri(reqSet,rId)
            linkSetUri=reqSet.filepath;
            reqId=num2str(rId);
            if~isempty(reqSet.parent)
                [fPath,fName,fExt]=fileparts(reqSet.filepath);
                linkSetUri=fullfile(fPath,reqSet.parent);
                reqId=[fName,fExt,slreq.internal.LinkUtil.EmbeddedReqIdDelimiter,reqId];
            end
        end

        function[reqSetUri,reqId]=getReqSetUri(artifactUri,id)
            reqSetUri=artifactUri;
            reqId=id;


            [rId,reqSet]=slreq.utils.getShortIdFromLongId(id);
            [~,~,fExt]=fileparts(reqSet);
            if strcmp(fExt,'.slreqx')
                fpath=fileparts(artifactUri);
                reqSetUri=fullfile(fpath,reqSet);
                reqId=rId;
            end
        end

        function fpath=getParentPath(dataReqSet)
            fpath=dataReqSet.filepath;
            if~isempty(dataReqSet.parent)
                pathF=fileparts(dataReqSet.filepath);
                fpath=fullfile(pathF,dataReqSet.parent);
            end
        end

        function regPath=makeReqSetRegisterPath(dataReqSet,expectedPath)
            if isempty(dataReqSet.parent)
                regPath=expectedPath;
            else
                [fPath,fName,fExt]=fileparts(expectedPath);
                regPath=fullfile(fPath,...
                [dataReqSet.parent,slreq.internal.LinkUtil.EmbeddedReqIdDelimiter,fName,fExt]);
            end
        end

        function[uri,eReqSet]=extractArtifactUri(regPath)















            uri=regPath;
            eReqSet=[];
            [fPath,fName,fExt]=fileparts(regPath);
            tokens=strsplit(fName,slreq.internal.LinkUtil.EmbeddedReqIdDelimiter);
            if length(tokens)==2
                [~,~,fExt1]=fileparts(tokens{1});
                if strcmp(fExt1,'.slx')
                    uri=fullfile(fPath,tokens{1});
                    eReqSet=[tokens{2},fExt];
                end
            end
        end
    end
end
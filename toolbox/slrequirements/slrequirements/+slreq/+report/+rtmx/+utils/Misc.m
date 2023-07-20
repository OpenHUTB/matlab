classdef Misc
    methods(Static)
        function out=getAllLinkTypes(needrefresh)
            persistent allTypeNames

            if isempty(allTypeNames)||needrefresh
                allTypes=slreq.utils.getAllLinkTypes;
                allTypeNames={allTypes.typeName};
            end
            out=allTypeNames;
        end

        function out=getLinkStatsStruct()
            persistent typeStruct
            if isempty(typeStruct)
                allTypes=slreq.report.rtmx.utils.Misc.getAllLinkTypes();
                for cIndex=1:length(allTypes)
                    typeStruct.(allTypes{cIndex})=0;
                end
                typeStruct.Total=0;
            end
            out=typeStruct;
            out.Details=containers.Map('KeyType','char','ValueType','any');
        end

        function out=getChildrenIDsStruct(idList)
            out=cell(size(idList));
            for index=1:length(idList)
                idInfo=containers.Map('KeyType','char','ValueType','any');
                idInfo('_reference')=idList{index};
                out{index}=idInfo;
            end
        end

        function targetInfo=getTargetStruct(domain,artifact,artifactID,isCreatingID)

            if nargin<4

                isCreatingID=false;
            end

            adapterDomain=slreq.report.rtmx.utils.Misc.getDomain(domain);

            if strcmpi(artifactID,artifact)
                artifactID='';
            elseif isempty(artifact)
                artifact=artifactID;
                artifactID='';
            end










            targetInfo.artifact=artifact;
            targetInfo.domain=adapterDomain;
            if strcmpi(domain,'matlabcode')&&isCreatingID
                range=sscanf(artifactID,'%d-%d');
                targetInfo.id=slreq.getRangeId(artifact,range,true);
            else
                targetInfo.id=artifactID;
            end
        end


        function out=getDomain(domainName)
            matrixDomains={'slreq','sltest','sldd','matlabcode','simulink'};

            if~ismember(domainName,matrixDomains)
                out=domainName;
                return;
            end
            adapterDomains={'linktype_rmi_slreq','linktype_rmi_testmgr','linktype_rmi_data','linktype_rmi_matlab','linktype_rmi_simulink'};
            domainMap=containers.Map(matrixDomains,adapterDomains);

            out=domainMap(domainName);
        end
    end
end


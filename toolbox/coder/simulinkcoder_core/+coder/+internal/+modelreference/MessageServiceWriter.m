


classdef MessageServiceWriter<handle

    properties(Access=private)
ModelInterfaceUtils
ModelInterface
CodeInfo
Writer
ServicePort
infoNameMap
    end

    methods(Access=private)

        function getServiceInfo(this,portIdx,isOutport)
            svcPort=this.ServicePort;




            if~isfield(svcPort,'ProvidingService')
                return
            end

            providingServices=svcPort.ProvidingService;
            if(~iscell(svcPort.ProvidingService))
                providingServices={svcPort.ProvidingService};
            end

            getInfoFcn='ssGetOutputServiceInfo';
            if~isOutport
                getInfoFcn='ssGetInputServiceInfo';
            end

            for svcIndex=1:length(providingServices)
                svc=providingServices{svcIndex};
                if isFiltered(svc.Name)
                    continue;
                end

                dworkPath=svc.DWorkPath;
                if this.ModelInterfaceUtils.isMultiInstance
                    dworkPath=strcat('dw->',dworkPath);
                end

                matches=ExtractDWorkName(dworkPath);
                infoName=[matches.name,'_info'];




                if isKey(this.infoNameMap,infoName)
                    continue;
                else
                    this.infoNameMap(infoName)=1;
                end



                this.Writer.writeLine("ssExecServiceInfo %s = %s(S, %d, ""%s"");",...
                infoName,getInfoFcn,portIdx,svc.Name);


                this.Writer.writeLine("%s.%s = %s.host;",...
                dworkPath,'host',infoName);







                this.Writer.writeLine("*(void**)(&%s.%s) = %s.fcn;",...
                dworkPath,svc.Name,infoName);
            end
        end


        function setServiceInfo(this,portIdx,isOutport)
            svcPort=this.ServicePort;




            if~isfield(svcPort,'RequestingService')
                return
            end

            requestingServices=svcPort.RequestingService;
            if(~iscell(svcPort.RequestingService))
                requestingServices={svcPort.RequestingService};
            end

            setInfoFcn='ssSetOutputServiceInfo';
            if~isOutport
                setInfoFcn='ssSetInputServiceInfo';
            end

            for svcIndex=1:length(requestingServices)
                svc=requestingServices{svcIndex};

                if isFiltered(svc.Name)
                    continue;
                end

                dworkPath=svc.DWorkPath;
                if this.ModelInterfaceUtils.isMultiInstance
                    dworkPath=strcat('dw->',dworkPath);
                end

                matches=ExtractDWorkName(dworkPath);
                infoName=[matches.name,'_info'];




                if isKey(this.infoNameMap,infoName)
                    continue;
                else
                    this.infoNameMap(infoName)=1;
                end


                this.Writer.writeLine("ssExecServiceInfo %s;",infoName);

                if(isempty(svc.DelegatedHost))


                    if this.ModelInterfaceUtils.isMultiInstance
                        this.Writer.writeLine("%s.host = (void*)dw;",...
                        infoName);
                    else
                        matches=ExtractHostPath(svc.DWorkPath);
                        selfDworkPath=matches.host;
                        this.Writer.writeLine("%s.host = (void*)&%s;",...
                        infoName,selfDworkPath);
                    end
                else

                    this.Writer.writeLine("%s.host = (void*)%s.%s;",...
                    infoName,dworkPath,'host');
                end






                this.Writer.writeLine("%s.fcn = *(void**)&%s.%s;",...
                infoName,dworkPath,svc.Name);


                this.Writer.writeLine("%s(S, %d, ""%s"", &%s);",...
                setInfoFcn,portIdx,svc.Name,infoName);
            end
        end


    end


    methods(Access=public)

        function this=MessageServiceWriter(modelInterfaceUtils,codeInfo,writer,svcPort)
            this.ModelInterfaceUtils=modelInterfaceUtils;
            this.ModelInterface=modelInterfaceUtils.getModelInterface;
            this.CodeInfo=codeInfo;
            this.Writer=writer;
            this.ServicePort=svcPort;
            this.infoNameMap=containers.Map;
        end

        function write(this,isProviding)

            Inports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Inports');
            Outports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Outports');
            svcPort=this.ServicePort;


            for inportIdx=1:length(Inports)
                if Inports{inportIdx}.IsMessage
                    if svcPort.ExternalPortIdx<0||...
                        1~=strcmp(svcPort.ServicePortType,'SVC_OUT_PORT')||...
                        inportIdx-1~=svcPort.ExternalPortIdx
                        continue;
                    end

                    if isProviding
                        this.setServiceInfo(inportIdx-1,false);
                    else
                        this.getServiceInfo(inportIdx-1,false);
                    end
                end
            end


            for outportIdx=1:length(Outports)
                if Outports{outportIdx}.IsMessage
                    if svcPort.ExternalPortIdx<0||...
                        1~=strcmp(svcPort.ServicePortType,'SVC_IN_PORT')||...
                        outportIdx-1~=svcPort.ExternalPortIdx
                        continue;
                    end

                    if isProviding
                        this.setServiceInfo(outportIdx-1,true);
                    else
                        this.getServiceInfo(outportIdx-1,true);
                    end
                end
            end



            if isProviding&&isfield(svcPort,'ProvidingService')
                providingServices=svcPort.ProvidingService;
                if(~iscell(svcPort.ProvidingService))
                    providingServices={svcPort.ProvidingService};
                end
                for svcIndex=1:length(providingServices)
                    svc=providingServices{svcIndex};




                    if-2~=svc.DelegatedDworkIdx||...
                        isFiltered(svc.Name)
                        continue;
                    end

                    stmt=svc.DelegatedDworkPath;


                    if this.ModelInterfaceUtils.isMultiInstance
                        if this.ModelInterface.rtmAllocateInParent

                            dwPrefix='dw->rtm.';
                        else
                            dwPrefix='dw->rtdw.';
                        end
                        stmt=strcat(dwPrefix,stmt,'.host = (void*)dw;');

                    else
                        matches=ExtractHostPath(stmt);



                        if strcmp(matches.host,svc.DelegatedHost)

                            stmt=strcat(stmt,'.host = (void*)&',...
                            matches.host,';');
                        else
                            stmt=strcat(matches.dworkPath,'.host = (void*)&',...
                            matches.host,';');
                        end
                    end

                    this.Writer.writeLine(stmt);
                end
            end

        end

    end

end

function matches=ExtractHostPath(str)
    pattern='(?<host>\w+)[.](?<dworkPath>.+)';
    matches=regexp(str,pattern,'names');
end

function matches=ExtractDWorkName(str)
    pattern='\w+[.](?<name>\w+)$';
    matches=regexp(str,pattern,'names');
end

function result=isFiltered(svcName)
    result=false;
    if 1~=strcmp(svcName,'SendData')&&...
        1~=strcmp(svcName,'RecvData')&&...
        1~=strcmp(svcName,'TakeData')&&...
        1~=strcmp(svcName,'NotifyAvail')
        result=true;
    end
end

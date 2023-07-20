classdef ComponentInterface<rtw.report.CodeInterfaceBase




    properties(Transient,Access=private)
TimerServicesMap
    end


    methods
        function obj=ComponentInterface(modelName,buildDir,varargin)

            obj=obj@rtw.report.CodeInterfaceBase(modelName,buildDir,varargin{:});
            obj.constructTimerServicesMap;
        end

        function out=getShortTitle(~)

            out=message('RTW:report:CodeInterfaceLink').getString;
        end

        function out=getTitle(obj)

            out=message('RTW:codeInfo:reportTitle',obj.ModelName).getString;
        end

        function execute(obj)



            obj.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwshrink.js"></script>');
            obj.AddSectionNumber=false;
            obj.AddSectionShrinkButton=true;
            obj.AddSectionToToc=false;
            br='<br><br>';

            h2={'Tag','h2'};

            [title,introduction,contents]=obj.getIntroductionSection;
            obj.addSection('sec_introduction',title,introduction,contents,...
            h2{:},'Collapse',true);


            [title,introduction,contents]=obj.getExecutionSection;
            obj.addSection('sec_execution',title,[introduction,br],contents,...
            h2{:});


            [title,introduction,contents]=obj.getServicesSection;
            obj.addSection('sec_services',title,[introduction,br],contents,...
            h2{:});
        end

        function out=getFunctionDescription(~,f)


            if isa(f,'coder.descriptor.TimerFunction')
                out=char(f.ServiceType);
            else
                out='';
            end
        end
    end


    methods


        function[title,introduction,contents]=getIntroductionSection(obj)

            title=message('RTW:codeInfo:reportIntroductionSection').getString;
            introduction=Advisor.Element('p');
            introduction.setContent(message('RTW:codeInfo:reportComponentInterfaceIntroduction').getString);
            contents=obj.getFunctionComponentImage;
        end



        function[title,introduction,contents]=getExecutionSection(obj)

            title=message('RTW:codeInfo:reportExecutionSection').getString;
            introduction=message('RTW:codeInfo:reportExecutionIntroduction').getString;
            contents=[...
            obj.getInitializeFunctionsSubSection,...
            obj.getTerminateFunctionsSubSection,...
            obj.getResetFunctionsSubSection,...
            obj.getPeriodicFunctionsSubSection,...
            obj.getAperiodicFunctionsSubSection];
        end

        function out=getPeriodicFunctionsSubSection(obj)




            timingMode='PERIODIC';
            out=getFunctionsSubSection(obj,...
            obj.getOutputFunctions(timingMode),...
            'RTW:codeInfo:reportPeriodicFunctions',...
            obj.getOutputFunctionDescriptions(timingMode));
        end

        function out=getAperiodicFunctionsSubSection(obj)





            timingMode='ASYNCHRONOUS';
            out=getFunctionsSubSection(obj,...
            obj.getOutputFunctions(timingMode),...
            'RTW:codeInfo:reportAperiodicFunctions',...
            obj.getOutputFunctionDescriptions(timingMode));
        end

        function out=getInitializeFunctionsSubSection(obj)





            out=getFunctionsSubSection(obj,obj.getInitializeFunctions,...
            'RTW:codeInfo:reportInitializeFunctions',...
            message('RTW:codeInfo:reportInitializationDescription').getString);
        end

        function out=getResetFunctionsSubSection(obj)





            out=getFunctionsSubSection(obj,obj.getResetFunctions,...
            'RTW:codeInfo:reportResetFunctions',...
            message('RTW:codeInfo:reportResetDescription').getString);
        end

        function out=getTerminateFunctionsSubSection(obj)





            out=getFunctionsSubSection(obj,obj.getTerminateFunctions,...
            'RTW:codeInfo:reportTerminateFunctions',...
            message('RTW:codeInfo:reportTerminationDescription').getString);
        end

        function out=getInitializeFunctions(obj)

            out=obj.getInterfaceFunctions('InitializeFunctions');
        end

        function out=getResetFunctions(obj)

            out=getOutputFunctions(obj,'RESET');
        end

        function out=getTerminateFunctions(obj)

            out=obj.getInterfaceFunctions('TerminateFunctions');
        end

        function out=getReceiverTable(obj,exportFunctionName)

            out=obj.getReceiverSenderTables(...
            obj.getReceiverServices(exportFunctionName),...
            exportFunctionName,...
            'RTW:codeInfo:reportReceiverServicesTitle');
        end

        function out=getSenderTable(obj,exportFunctionName)

            out=obj.getReceiverSenderTables(...
            obj.getSenderServices(exportFunctionName),...
            exportFunctionName,...
            'RTW:codeInfo:reportSenderServicesTitle');
        end

        function out=getTimerServicesTable(obj,exportFunctionName)


            services=obj.getTimerServices(exportFunctionName);
            if isempty(services)
                out=[];
                return
            end
            title=Advisor.Element('h5');
            title.setContent(message('RTW:codeInfo:reportTimerServicesTitle',exportFunctionName).getString);
            out=[title,obj.getTimerFunctionsContents(services)];
        end



        function[title,introduction,contents]=getServicesSection(obj)

            title=message('RTW:codeInfo:reportServicesSection').getString;
            introduction=message('RTW:codeInfo:reportServicesIntroduction').getString;
            contents=[obj.getDataTransferServicesSection,...
            obj.getParameterTuningServicesSection];
        end

        function out=getDataTransferServicesSection(obj)

            services=obj.getDataTransferElements;
            if isempty(services)
                contents={Advisor.Paragraph(message('RTW:codeInfo:reportNoDataTransferServices').getString)};
            else
                contents=arrayfun(@(x)obj.getDataTransferServiceContents(x),...
                services,'UniformOutput',false);
            end
            out=[obj.newSectionTitle('h3','RTW:codeInfo:reportDataTransferServicesSection'),...
            Advisor.Text(message('RTW:codeInfo:reportDataTransferServicesIntroduction').getString),...
            contents{:}];
        end

        function out=getDataTransferServiceContents(obj,element)

            title=Advisor.Element('h4');
            title.setContent([message('RTW:codeInfo:reportDataTransferService').getString,': ',element.Name]);
            receiverServices=obj.getDataTransferFunctions(element,'Get');
            senderServices=obj.getDataTransferFunctions(element,'Set');
            contents={...

            message('RTW:codeInfo:reportReceiverServicePrototype').getString,...
            strjoin(arrayfun(@(x)obj.getPrototype(x),receiverServices,...
            'UniformOutput',false),'<br/>');

            message('RTW:codeInfo:reportSenderServicePrototype').getString,...
            strjoin(arrayfun(@(x)obj.getPrototype(x),senderServices,...
            'UniformOutput',false),'<br/>');

            message('RTW:codeInfo:reportDataCommunicationMethod').getString,...
            obj.getDataCommunicationMethod(element);...

            message('RTW:codeInfo:reportReceivingFunction').getString,...
            strjoin(obj.getCallingFunctions(receiverServices),'<br/>');...

            message('RTW:codeInfo:reportSendingFunction').getString,...
            strjoin(obj.getCallingFunctions(senderServices),'<br/>');...

            message('RTW:codeInfo:reportEntryHeaderFile').getString,...
            obj.getServiceInterface.getServicesHeaderFileName;
            };
            table=obj.newTable(contents,[1,3]);
            out=[title,table];
        end

        function out=getDataTransferFunctions(~,element,type)

            f=element.Functions.toArray;
            out=f(arrayfun(@(x)strcmp(x.FunctionType,type),f));
        end

        function out=getDataCommunicationMethodEnumValue(obj,service)

            if ischar(service)

                mode=char(obj.getServiceInterface.getServiceDataCommMethod(service));
            else
                mode=char(service.DataCommunicationMethod);
            end
            out=mode;
        end

        function out=getDataCommunicationMethodMessage(~,enumValue)

            switch enumValue
            case 'OutsideExecution'
                id='RTW:codeInfo:reportOutsideExecution';
            case 'DuringExecution'
                id='RTW:codeInfo:reportDuringExecution';
            case 'DirectAccess'
                id='RTW:codeInfo:reportDirectAccess';
            end
            out=message(id).getString;
        end

        function out=getDataCommunicationMethod(obj,service)
            out=obj.getDataCommunicationMethodMessage(...
            obj.getDataCommunicationMethodEnumValue(service));
        end

        function out=getTimerFunctionsContents(obj,timerFunctions)

            services=[cellfun(@(f)obj.getTimerFunctionServiceTypeHeader(f),...
            timerFunctions,'UniformOutput',false)',...
            cellfun(@(f)obj.getPrototype(...
            struct('Prototype',obj.getPrototypeObject(f))),timerFunctions,...
            'UniformOutput',false)'];
            p=obj.getPrototypeObject(timerFunctions{1});
            communicationMethod={
            message('RTW:codeInfo:reportDataCommunicationMethod').getString,...
            obj.getDataCommunicationMethod(p.Name);
            };
            header={
            message('RTW:codeInfo:reportEntryHeaderFile').getString,...
            char(p.HeaderFile);
            };
            out=obj.newTable([services;communicationMethod;header],[1,3]);
        end

        function out=getTimerFunctionServiceTypeHeader(obj,name)

            f=obj.TimerServicesMap(name);
            switch char(f.ServiceType)
            case 'Resolution'
                id='RTW:codeInfo:reportTimerServicesResolutionPrototype';
            case 'AbsoluteTime'
                id='RTW:codeInfo:reportTimerServicesAbsoluteTimePrototype';
            case 'FunctionClockTick'
                id='RTW:codeInfo:reportTimerServicesFunctionClockTickPrototype';
            case 'FunctionStepSize'
                id='RTW:codeInfo:reportTimerServicesFunctionStepSizePrototype';
            case 'FunctionStepTick'
                id='RTW:codeInfo:reportTimerServicesFunctionStepTickPrototype';
            end
            out=message(id).getString;
        end

        function out=getParameterTuningServicesSection(obj)

            out=obj.getCommunicationSubSection(@getParameterTable,...
            'RTW:codeInfo:reportParameterTuningServicesSection',...
            'RTW:codeInfo:reportNoInterfaceParameters');
        end

        out=getFunctionComponentImage(obj);
    end


    methods(Access=private)
        function out=getCommunicationSubSection(obj,tableFunction,title,none)

            contents=tableFunction(obj);
            if isempty(contents)
                contents=Advisor.Paragraph(message(none).getString);
            end
            out=[obj.newSectionTitle('h3',title),contents];
        end

        function out=getOutputFunctionDescriptions(obj,timingMode)



            interface=obj.getCodeDescriptor.getFullComponentInterface;
            f=interface.OutputFunctions.toArray;
            out=cell(0,1);
            expInports=obj.getCodeDescriptor.getExpInports;
            for k=1:length(f)
                if strcmp(f(k).Timing.TimingMode,timingMode)
                    if isempty(expInports)
                        out{end+1,1}=message('RTW:codeInfo:reportOutputDescription').getString;%#ok<AGROW>
                    else
                        out{end+1,1}=coder.internal.codeinfo('getExportedFunctionDescription',...
                        obj,expInports,obj.ModelName,k);%#ok<AGROW>
                    end
                end
            end
        end

        function out=getOutputFunctions(obj,timingMode)


            interface=obj.getCodeDescriptor.getFullComponentInterface;
            outputFunctions=interface.OutputFunctions.toArray;
            out=outputFunctions(arrayfun(@(x)strcmp(x.Timing.TimingMode,timingMode)&&...
            ~isempty(x.Prototype.HeaderFile),outputFunctions));
        end

        function out=getInterfaceFunctions(obj,field)



            interface=obj.getCodeDescriptor.getFullComponentInterface;
            out=interface.(field).toArray;
        end

        function out=getCallingFunctions(obj,services)


            out=arrayfun(@(x)obj.getServiceInterface.getCallableFunctionsThatCallServiceFunction(...
            x.Prototype.Name),...
            services,'UniformOutput',false);
            out=[out{:}];
        end

        function out=newSectionTitle(~,tag,key)

            out=Advisor.Element(tag);
            out.setContent(message(key).getString);
        end

        function out=getFunctionsSubSection(obj,f,title,description)







            h=Advisor.Element('h3');
            h.setContent(message(title).getString);
            if isempty(f)
                out=[];
                return
            else
                if iscell(description)

                    descriptionIndex=1:length(f);
                else

                    description={description};
                    descriptionIndex=ones(size(f));
                end
                contents=arrayfun(@(x,y)obj.getFunctionInterfaceTable(x,description{y}),...
                f,descriptionIndex,'UniformOutput',false);

                contents=[contents{:}];
            end
            out=[h,contents];
        end

        function out=getFunctionInterfaceTable(obj,f,description)




            name=f.Prototype.Name;
            title=Advisor.Element('h4');
            title.setContent(message('RTW:codeInfo:reportFunctionHeading',...
            obj.getCodeHyperlink(name)).getString);
            contents={

            message('RTW:codeInfo:reportEntryPrototype').getString,...
            obj.getPrototype(f);...

            message('RTW:codeInfo:reportEntryDescription').getString,...
            description;
            };

            if f.Timing.TimingMode=="PERIODIC"
                contents(end+1,:)={
                message('RTW:codeInfo:reportSampleTime').getString,...
                num2str(f.Timing.SamplePeriod)...
                };
            end
            contents(end+1,:)={

            message('RTW:codeInfo:reportEntryHeaderFile').getString,...
            char(f.Prototype.HeaderFile);...
            };
            table=obj.newTable(contents,[1,3]);
            out=[title,table];

            receivers=obj.getReceiverTable(name);

            senders=obj.getSenderTable(name);

            timerServices=obj.getTimerServicesTable(name);
            out=[out,receivers,senders,timerServices];
        end

        function constructTimerServicesMap(obj)


            services=obj.getCodeDescriptor.getServices;
            timerFunctions=services.getServiceInterface('Timer').TimerFunctions.toArray;
            map=containers.Map;
            for k=1:length(timerFunctions)
                map(timerFunctions(k).Prototype.Name)=timerFunctions(k);
            end
            obj.TimerServicesMap=map;
        end

        function out=getReceiverSenderTables(obj,services,exportFunctionName,titleMsgId)





            if isempty(services)
                out=[];
                return
            end

            p=Advisor.Paragraph;

            title=Advisor.Element('div');
            title.setContent(message(titleMsgId,exportFunctionName).getString);
            p.addItem(title);

            enum=?coder.descriptor.DataCommunicationMethodEnum;
            cellfun(@(x)p.addItem(obj.getReceiverSenderTable(services,x)),...
            {enum.EnumerationMemberList.Name});
            out=p;
        end

        function out=getReceiverSenderTable(obj,services,dataCommunicationMethod)




            services=services(cellfun(@(x)strcmp(obj.getDataCommunicationMethodEnumValue(x),...
            dataCommunicationMethod),services));
            if isempty(services)
                out=Advisor.Element.empty;
                return
            end

            prototypeObjects=cellfun(@obj.getPrototypeObject,services);
            prototype=arrayfun(@(x)obj.getPrototype(struct('Prototype',x)),prototypeObjects,...
            'UniformOutput',false);
            headerFile=arrayfun(@(x)x.HeaderFile,prototypeObjects,'UniformOutput',false);
            contents={

            message('RTW:codeInfo:reportEntryPrototype').getString,...
            strjoin(prototype,'<br/>');

            message('RTW:codeInfo:reportDataCommunicationMethod').getString,...
            obj.getDataCommunicationMethodMessage(dataCommunicationMethod);

            message('RTW:codeInfo:reportEntryHeaderFile').getString,...
            strjoin(unique(headerFile,'stable'),'<br/>');
            };
            out=obj.newTable(contents,[1,3]);

            out.setAttribute('style','margin-bottom: 1px;')
        end

        function out=getServicesInfo(obj,exportFunctionName,serviceType)

            serviceFunctions=obj.getServiceInterface.getCalledServiceFunctions(exportFunctionName);
            if isempty(serviceFunctions)
                out=[];
            else
                out=serviceFunctions.(serviceType).toArray;
            end
        end

        function out=getReceiverServices(obj,exportFunctionName)

            out=obj.getServicesInfo(exportFunctionName,'ReceiverFunctions');
        end

        function out=getSenderServices(obj,exportFunctionName)

            out=obj.getServicesInfo(exportFunctionName,'SenderFunctions');
        end

        function out=getTimerServices(obj,exportFunctionName)

            out=obj.getServicesInfo(exportFunctionName,'TimerFunctions');
        end

        function out=getPrototypeObject(obj,name)

            out=obj.getCodeDescriptor.getServiceFunctionPrototype(name);
        end

        function out=getDataTransferElements(obj)

            services=obj.getCodeDescriptor.getServices;
            out=services.getServiceInterface('DataTransfer').DataTransferElements.toArray;
        end

        function out=getServiceInterface(obj)

            out=obj.getCodeDescriptor.getServices;
        end

        function out=getPrototype(obj,f)

            out=obj.getCodeDescriptor.getServiceFunctionDeclaration(f.Prototype);
        end
    end
end



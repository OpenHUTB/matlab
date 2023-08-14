classdef FMUObject<handle



    properties(Access=private)
        fmuFile;
        fmuFullPathFileName;
        fmuModelDescription;
        fmuMode;
        fmuVersion;
        fmuIdentifier;
        fmuDynLibFile;
        fmuGUID;
        fmuInstantiationToken;
        fmuResourceDir;
        fmuInstance;
        fmuUnzipBase;
        fmuUnzipDir;



        realInputMap;
        realOutputMap;
        integerInputMap;
        integerOutputMap;
        booleanInputMap;
        booleanOutputMap;
        stringInputMap;
        stringOutputMap;


        unifiedInputMap;
        unifiedOutputMap;

        valRefVarNameMap;
        componentEnvironment;
        instanceEnvironment;
    end

    methods(Static,Access=public,Hidden=true)

        function LoggerCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:LoggerCallbackError',varargin{2}));
                msg.reportAsWarning;
            end
        end

        function StepFinishedCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:StepFinishedCallbackErrorNoArg'));
                msg.reportAsWarning;
            end
        end


        function LogMessageCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:CustomCallbackErrorNoArg','logMessageCallback'));
                msg.reportAsWarning;
            end
        end
        function IntermediateUpdateCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:CustomCallbackErrorNoArg','intermediateUpdateCallback'));
                msg.reportAsWarning;
            end
        end
        function LockPreemptionCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:CustomCallbackErrorNoArg','lockPreemptionCallback'));
                msg.reportAsWarning;
            end
        end
        function UnlockPreemptionCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:CustomCallbackErrorNoArg','unlockPreemptionCallback'));
                msg.reportAsWarning;
            end
        end
        function ClockUpdateCallback(callback,varargin)
            try
                assert(isa(callback,'function_handle'),'callback is not valid function handle');
                feval(callback,varargin{:});
            catch ex
                MSLDiagnostic(ex).reportAsWarning;
                msg=MSLDiagnostic(message('FMUBlock:Command:CustomCallbackErrorNoArg','clockUpdateCallback'));
                msg.reportAsWarning;
            end
        end
    end

    methods(Access=private,Hidden=true)
        function CheckAndUnzipFMU(fmuObject)

            [found,fileInfo]=fileattrib(fmuObject.fmuFile);
            if found
                fmuObject.fmuFullPathFileName=fileInfo.Name;
            end

            if exist(fmuObject.fmuFullPathFileName,'file')~=2
                throw(MException(message('FMUBlock:Command:FMUFileNotExist',fmuObject.fmuFile)));
            end



            try

                fmuObject.fmuUnzipBase=Simulink.fileGenControl('get','CacheFolder');
                fmuObject.fmuUnzipDir=tempname(fullfile(fmuObject.fmuUnzipBase,'slprj','_fmu'));

                mkdir(fmuObject.fmuUnzipDir);
                unzip(fmuObject.fmuFullPathFileName,fmuObject.fmuUnzipDir);
            catch ex
                throw(MException(message('FMUBlock:Command:CannotUnzipFMU',ex.message)));
            end
        end

        function[archStr,libExt]=GetArchLibExt(fmuObject)
            if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                if ispc
                    archStr='win64';libExt='.dll';
                elseif ismac
                    archStr='darwin64';libExt='.dylib';
                else
                    archStr='linux64';libExt='.so';
                end
            else

                if ispc
                    archStr='x86_64-windows';libExt='.dll';
                elseif ismac
                    archStr='x86_64-darwin';libExt='.dylib';
                else
                    archStr='x86_64-linux';libExt='.so';
                end
            end
        end

        function LoadModelDescriptionXML(fmuObject,userOptionMode)


            try
                parser=internal.fmudialog.xmlParser.load(...
                fullfile(fmuObject.fmuUnzipDir,'modelDescription.xml'));
                fmuObject.fmuModelDescription=parser.xmlFile;

                rootNode=fmuObject.fmuModelDescription.getElementsByTagName('fmiModelDescription').item(0);


                verStr=strtrim(char(rootNode.getAttribute('fmiVersion')));
                if startsWith(verStr,'1.0')
                    fmuObject.fmuVersion='1.0';
                elseif startsWith(verStr,'2.0')
                    fmuObject.fmuVersion='2.0';
                elseif startsWith(verStr,'3.0')
                    fmuObject.fmuVersion='3.0';
                else
                    throw(MException(message('FMUBlock:Command:InvalidFMUVersion',verStr)));
                end


                if strcmp(userOptionMode,'')

                    if strcmp(fmuObject.fmuVersion,'1.0')
                        impNode=fmuObject.getXMLChildNode(rootNode,'Implementation');
                        if isempty(impNode)
                            fmuObject.fmuMode='Model Exchange';
                        else
                            fmuObject.fmuMode='Co-Simulation';
                        end
                    elseif strcmp(fmuObject.fmuVersion,'2.0')
                        csNode=fmuObject.getXMLChildNode(rootNode,'CoSimulation');
                        meNode=fmuObject.getXMLChildNode(rootNode,'ModelExchange');
                        if isempty(csNode)&&~isempty(meNode)
                            fmuObject.fmuMode='Model Exchange';
                        elseif isempty(meNode)&&~isempty(csNode)
                            fmuObject.fmuMode='Co-Simulation';
                        elseif~isempty(meNode)&&~isempty(csNode)
                            throw(MException(message('FMUBlock:Command:CannotDetermineFMUMode')));
                        else
                            throw(MException(message('FMUBlock:Command:NoValidFMUMode')));
                        end
                    elseif strcmp(fmuObject.fmuVersion,'3.0')
                        csNode=fmuObject.getXMLChildNode(rootNode,'CoSimulation');
                        meNode=fmuObject.getXMLChildNode(rootNode,'ModelExchange');
                        seNode=fmuObject.getXMLChildNode(rootNode,'ScheduledExecution');
                        if isempty(csNode)&&~isempty(meNode)&&isempty(seNode)
                            fmuObject.fmuMode='Model Exchange';
                        elseif isempty(meNode)&&~isempty(csNode)&&isempty(seNode)
                            fmuObject.fmuMode='Co-Simulation';
                        elseif isempty(meNode)&&isempty(csNode)&&~isempty(seNode)
                            fmuObject.fmuMode='Scheduled Execution';
                        elseif~isempty(meNode)&&~isempty(csNode)
                            throw(MException(message('FMUBlock:Command:CannotDetermineFMUMode')));
                        else
                            throw(MException(message('FMUBlock:Command:NoValidFMUMode')));
                        end
                    else
                        assert(false,['Invalid FMU version: ',fmuObject.fmuVersion]);
                    end
                elseif strcmp(userOptionMode,'Co-Simulation')
                    fmuObject.fmuMode='Co-Simulation';
                elseif strcmp(userOptionMode,'Model Exchange')
                    fmuObject.fmuMode='Model Exchange';
                elseif strcmp(userOptionMode,'Scheduled Execution')
                    fmuObject.fmuMode='Scheduled Execution';
                else
                    throw(MException(message('FMUBlock:Command:InvalidSpecifiedFMUMode',userOptionMode)));
                end


                if strcmp(fmuObject.fmuVersion,'1.0')
                    fmuObject.fmuIdentifier=char(rootNode.getAttribute('modelIdentifier'));
                elseif strcmp(fmuObject.fmuVersion,'2.0')
                    if strcmp(fmuObject.fmuMode,'Model Exchange')
                        fmuObject.fmuIdentifier=char(fmuObject.getXMLChildNode(rootNode,'ModelExchange').getAttribute('modelIdentifier'));
                    elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                        fmuObject.fmuIdentifier=char(fmuObject.getXMLChildNode(rootNode,'CoSimulation').getAttribute('modelIdentifier'));
                    else
                        assert(false,['Invalid FMU mode: ',fmuObject.fmuMode]);
                    end
                elseif strcmp(fmuObject.fmuVersion,'3.0')
                    if strcmp(fmuObject.fmuMode,'Model Exchange')
                        fmuObject.fmuIdentifier=char(fmuObject.getXMLChildNode(rootNode,'ModelExchange').getAttribute('modelIdentifier'));
                    elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                        fmuObject.fmuIdentifier=char(fmuObject.getXMLChildNode(rootNode,'CoSimulation').getAttribute('modelIdentifier'));
                    elseif strcmp(fmuObject.fmuMode,'Scheduled Execution')
                        fmuObject.fmuIdentifier=char(fmuObject.getXMLChildNode(rootNode,'ScheduledExecution').getAttribute('modelIdentifier'));
                    else
                        assert(false,['Invalid FMU mode: ',fmuObject.fmuMode]);
                    end
                else
                    assert(false,['Invalid FMU version: ',fmuObject.fmuVersion]);
                end

                [archStr,libExt]=fmuObject.GetArchLibExt;
                fmuObject.fmuDynLibFile=fullfile(fmuObject.fmuUnzipDir,'binaries',archStr,[fmuObject.fmuIdentifier,libExt]);
                if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                    fmuObject.fmuGUID=char(rootNode.getAttribute('guid'));
                elseif strcmp(fmuObject.fmuVersion,'3.0')
                    fmuObject.fmuInstantiationToken=char(rootNode.getAttribute('instantiationToken'));
                else
                    assert(false,['Invalid FMU version: ',fmuObject.fmuVersion]);
                end
                fmuObject.fmuResourceDir=fullfile(fmuObject.fmuUnzipDir,'resources');
            catch ex
                if contains(ex.identifier,'FMUBlock:Command')
                    rethrow(ex);
                else
                    throw(MException(message('FMUBlock:Command:CannotParseXML',ex.message)));
                end
            end
        end

        function childNode=getXMLChildNode(~,rootNode,childNodeName)
            childNode=[];
            node=rootNode.getFirstChild;
            while~isempty(node)
                if strcmp(char(node.getNodeName),childNodeName)
                    childNode=node;
                    return;
                end
                node=node.getNextSibling;
            end
        end

        function exportedBySimulink=isExportedBySimulink(fmuObject)
            xmlNode=fmuObject.fmuModelDescription;
            genToolStr=char(xmlNode.getElementsByTagName('fmiModelDescription').item(0).getAttribute('generationTool'));
            exportedBySimulink=~isempty(regexp(genToolStr,'^Simulink \(R[0-9]{4}[a-z]\)$','once'));
        end

        function annotationIndex=findSimulinkAnnotation(fmuObject)
            xmlNode=fmuObject.fmuModelDescription;
            vaList=xmlNode.getElementsByTagName('VendorAnnotations');
            if vaList.getLength==1
                toolList=vaList.item(0).getElementsByTagName('Tool');
                for i=0:(toolList.getLength-1)
                    if strcmp(char(toolList.item(i).getAttribute('name')),'Simulink')
                        annotationIndex=i;
                        return;
                    end
                end
            end
            annotationIndex=-1;
        end

        function requiresMATLABOnPath=simulinkAnnotationRequiresMATLABOnPath(fmuObject,annotationIndex)
            xmlNode=fmuObject.fmuModelDescription;
            slNodeList=xmlNode.getElementsByTagName('VendorAnnotations').item(0).getElementsByTagName('Tool').item(annotationIndex).getElementsByTagName('Simulink');
            if slNodeList.getLength()==1
                slNode=slNodeList.item(0);
                if slNode.getElementsByTagName('ImportCompatibility').getLength()==1
                    reqStr=char(slNode.getElementsByTagName('ImportCompatibility').item(0).getAttribute('requireMATLABOnPath'));
                    if strcmp(reqStr,'yes')
                        requiresMATLABOnPath=true;
                        return;
                    end
                end
            end
            requiresMATLABOnPath=false;
        end

        function requiresMATLABEnv=simulinkAnnotationRequiresMATLABEnv(fmuObject,annotationIndex)
            xmlNode=fmuObject.fmuModelDescription;
            slNodeList=xmlNode.getElementsByTagName('VendorAnnotations').item(0).getElementsByTagName('Tool').item(annotationIndex).getElementsByTagName('Simulink');
            if slNodeList.getLength()==1
                slNode=slNodeList.item(0);
                if slNode.getElementsByTagName('ImportCompatibility').getLength()==1
                    requiresMATLABEnv=char(slNode.getElementsByTagName('ImportCompatibility').item(0).getAttribute('requireMATLABEnv'));
                    return;

                end
            end
            requiresMATLABEnv='';
        end

        function isCompatible=simulinkAnnotationIsCompatible(fmuObject,annotationIndex)
            stx1='^R[0-9]{4}[a-z]\+$';
            stx2='^R[0-9]{4}[a-z]$';
            currentVer=ver('MATLAB');
            CURRENT_MATLAB_RELEASE=currentVer.Release(2:7);

            xmlNode=fmuObject.fmuModelDescription;
            slNodeList=xmlNode.getElementsByTagName('VendorAnnotations').item(0).getElementsByTagName('Tool').item(annotationIndex).getElementsByTagName('Simulink');
            if slNodeList.getLength()==1
                slNode=slNodeList.item(0);
                if slNode.getElementsByTagName('ImportCompatibility').getLength()==1
                    strToSplit=char(slNode.getElementsByTagName('ImportCompatibility').item(0).getAttribute('requireRelease'));
                    if isempty(strToSplit)
                        isCompatible=true;
                        return;
                    end

                    ranges=split(strToSplit,',');
                    for i=1:length(ranges)
                        ranges{i}=strtrim(ranges{i});
                        if isempty(ranges{i})
                            continue;
                        end


                        tokens=split(ranges{i},'-');
                        if length(tokens)==1
                            tokens{1}=strtrim(tokens{1});
                            if~isempty(regexp(tokens{1},stx1,'once'))

                                verStr=tokens{1}(1:6);
                                [~,idx]=sort({verStr,CURRENT_MATLAB_RELEASE});
                                if idx(1)==1
                                    isCompatible=true;
                                    return;
                                else
                                    continue;
                                end
                            elseif~isempty(regexp(tokens{1},stx2,'once'))

                                verStr=tokens{1};
                                if strcmp(verStr,CURRENT_MATLAB_RELEASE)
                                    isCompatible=true;
                                    return;
                                else
                                    continue;
                                end
                            else
                                isCompatible=true;
                                return
                            end
                        elseif length(tokens)==2

                            tokens=strtrim(tokens);

                            if~isempty(regexp(tokens{1},stx2,'once'))&&~isempty(regexp(tokens{2},stx2,'once'))

                                [~,idx1]=sort({tokens{1},CURRENT_MATLAB_RELEASE});
                                [~,idx2]=sort({CURRENT_MATLAB_RELEASE,tokens{2}});
                                if(idx1(1)==1&&idx2(1)==1)
                                    isCompatible=true;
                                    return;
                                else
                                    continue;
                                end
                            else
                                isCompatible=true;
                                return;
                            end
                        else
                            isCompatible=true;
                            return;
                        end
                    end
                    isCompatible=false;
                    return;
                end
            end

            isCompatible=true;
        end

        function ValidateModelDescriptionXML(fmuObject)




            slAnnotationIndex=fmuObject.findSimulinkAnnotation;
            isExportedFromSimulink=fmuObject.isExportedBySimulink;

            if slAnnotationIndex>=0&&isExportedFromSimulink&&...
                (fmuObject.simulinkAnnotationRequiresMATLABOnPath(slAnnotationIndex)||...
                ~isempty(fmuObject.simulinkAnnotationRequiresMATLABEnv(slAnnotationIndex)))

                if matlab.engine.isEngineShared
                    throw(MException(message('FMUBlock:Command:CannotImportToolCouplingFMU')));
                end
            end

            if slAnnotationIndex>=0&&...
                ~fmuObject.simulinkAnnotationIsCompatible(slAnnotationIndex)
                if isExportedFromSimulink

                    throw(MException(message('FMUBlock:Command:ExportedFMUIncompatibleRelease')));
                else

                    throw(MException(message('FMUBlock:Command:FMUIncompatibleRelease')));
                end
            end

        end

        function CreateVariableMaps(fmuObject)

            if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                fmuObject.realInputMap=containers.Map;
                fmuObject.realOutputMap=containers.Map;
                fmuObject.integerInputMap=containers.Map;
                fmuObject.integerOutputMap=containers.Map;
                fmuObject.booleanInputMap=containers.Map;
                fmuObject.booleanOutputMap=containers.Map;
                fmuObject.stringInputMap=containers.Map;
                fmuObject.stringOutputMap=containers.Map;
            else
                fmuObject.unifiedInputMap=containers.Map;
                fmuObject.unifiedOutputMap=containers.Map;
            end


            fmuObject.valRefVarNameMap=containers.Map;

            rootNode=fmuObject.fmuModelDescription.getElementsByTagName('fmiModelDescription').item(0);
            mvNode=fmuObject.getXMLChildNode(rootNode,'ModelVariables');
            if isempty(mvNode)

                return;
            end

            dupNameMap=containers.Map;

            if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                svList=mvNode.getElementsByTagName('ScalarVariable');
                for i=0:svList.getLength-1


                    causality=char(svList.item(i).getAttribute('causality'));
                    name=char(svList.item(i).getAttribute('name'));
                    vr=uint32(str2double(char(svList.item(i).getAttribute('valueReference'))));

                    if dupNameMap.isKey(name)
                        throw(MException(message('FMUBlock:Command:DuplicateScalarVariableName',name)));
                    else
                        dupNameMap(name)=i;
                    end


                    if~isempty(svList.item(i).getElementsByTagName('Real').item(0))
                        valRefName=['r',num2str(vr)];
                        if~fmuObject.valRefVarNameMap.isKey(valRefName)
                            fmuObject.valRefVarNameMap(valRefName)=name;
                        end

                        if strcmp(causality,'input')
                            fmuObject.realInputMap(name)=vr;
                        elseif strcmp(causality,'output')
                            fmuObject.realOutputMap(name)=vr;
                        end
                    elseif~isempty(svList.item(i).getElementsByTagName('Integer').item(0))
                        valRefName=['i',num2str(vr)];
                        if~fmuObject.valRefVarNameMap.isKey(valRefName)
                            fmuObject.valRefVarNameMap(valRefName)=name;
                        end

                        if strcmp(causality,'input')
                            fmuObject.integerInputMap(name)=vr;
                        elseif strcmp(causality,'output')
                            fmuObject.integerOutputMap(name)=vr;
                        end
                    elseif~isempty(svList.item(i).getElementsByTagName('Boolean').item(0))
                        valRefName=['b',num2str(vr)];
                        if~fmuObject.valRefVarNameMap.isKey(valRefName)
                            fmuObject.valRefVarNameMap(valRefName)=name;
                        end

                        if strcmp(causality,'input')
                            fmuObject.booleanInputMap(name)=vr;
                        elseif strcmp(causality,'output')
                            fmuObject.booleanOutputMap(name)=vr;
                        end
                    elseif~isempty(svList.item(i).getElementsByTagName('String').item(0))
                        valRefName=['s',num2str(vr)];
                        if~fmuObject.valRefVarNameMap.isKey(valRefName)
                            fmuObject.valRefVarNameMap(valRefName)=name;
                        end

                        if strcmp(causality,'input')
                            fmuObject.stringInputMap(name)=vr;
                        elseif strcmp(causality,'output')
                            fmuObject.stringOutputMap(name)=vr;
                        end
                    end
                end
            else
                nodeList=mvNode.getChildNodes;
                nodeListLen=nodeList.getLength;
                for i=0:nodeListLen-1
                    node=nodeList.item(i);
                    if node.getNodeType~=node.ELEMENT_NODE
                        continue;
                    end

                    switch char(node.getNodeName)
                    case 'Float32'
                    case 'Float64'
                    case 'Int8'
                    case 'UInt8'
                    case 'Int16'
                    case 'UInt16'
                    case 'Int32'
                    case 'UInt32'
                    case 'Int64'
                    case 'UInt64'
                    case 'Boolean'
                    case 'String'
                    case 'Binary'
                    case 'Enumeration'
                    case 'Clock'
                    otherwise
                        assert(false,'Unknown modelVariable node type');
                    end


                    causality=char(node.getAttribute('causality'));
                    name=char(node.getAttribute('name'));
                    vr=uint32(str2double(char(node.getAttribute('valueReference'))));

                    if dupNameMap.isKey(name)
                        throw(MException(message('FMUBlock:Command:DuplicateScalarVariableName',name)));
                    else
                        dupNameMap(name)=i;
                    end


                    if strcmp(char(node.getNodeName),'Clock')
                        dims=1;
                    else
                        dims=[];
                        dimsList=node.getElementsByTagName('Dimension');
                        for j=1:dimsList.getLength-1
                            dimsNode=dimsList.itm(j);
                            dimsStr=char(dimsNode.getAttribute('start'));
                            if~isempty(dimsStr)
                                dims(end+1)=uint32(dimsStr);
                            else
                                assert(false,'dimension start value with valueReference is not supported');
                            end
                        end
                        if isempty(dims)

                            dims=1;
                        end
                    end


                    valRefName=num2str(vr);
                    if~fmuObject.valRefVarNameMap.isKey(valRefName)
                        varInfo=struct('name',name,'dimension',dims);
                        fmuObject.valRefVarNameMap(valRefName)=varInfo;
                    end

                    if strcmp(causality,'input')
                        fmuObject.unifiedInputMap(name)=vr;
                    elseif strcmp(causality,'output')
                        fmuObject.unifiedOutputMap(name)=vr;
                    end
                end
            end
        end

        function CreateComponentOrInstanceEnvironment(fmuObject)






            if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                fmuObject.componentEnvironment=struct(...
                'FMUUnzipDirectory',fmuObject.fmuUnzipDir,...
                'FMUFile',fmuObject.fmuFullPathFileName,...
                'ValueReferenceToVariableNameTable',{[fmuObject.valRefVarNameMap.keys',fmuObject.valRefVarNameMap.values']},...
                'UserData',containers.Map('KeyType','char','ValueType','any'));
            else

                fmuObject.instanceEnvironment=struct(...
                'FMUUnzipDirectory',fmuObject.fmuUnzipDir,...
                'FMUFile',fmuObject.fmuFullPathFileName,...
                'ValueReferenceToVariableNameTable',{[fmuObject.valRefVarNameMap.keys',fmuObject.valRefVarNameMap.values']},...
                'UserData',containers.Map('KeyType','char','ValueType','any'));
            end
        end

        function ret=IsSetRealInputDerivativesSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'1.0'));
            assert(~isempty(fmuObject.fmuMode));
            ret=false;

            rootNode=fmuObject.fmuModelDescription.getElementsByTagName('fmiModelDescription').item(0);
            impNode=fmuObject.getXMLChildNode(rootNode,'Implementation');
            if isempty(impNode)
                return;
            end
            capNodeList=impNode.getElementsByTagName('Capabilities');
            for i=1:capNodeList.getLength
                capNode=capNodeList.item(i-1);
                if strcmp(char(capNode.getAttribute('canInterpolateInputs')),'true')
                    ret=true;
                    return;
                end
            end
        end

        function ret=IsGetRealOutputDerivativesSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'1.0'));
            assert(~isempty(fmuObject.fmuMode));
            ret=false;

            rootNode=fmuObject.fmuModelDescription.getElementsByTagName('fmiModelDescription').item(0);
            impNode=fmuObject.getXMLChildNode(rootNode,'Implementation');
            if isempty(impNode)
                return;
            end
            capNodeList=impNode.getElementsByTagName('Capabilities');
            for i=1:capNodeList.getLength
                capNode=capNodeList.item(i-1);
                outOrder=str2double(char(capNode.getAttribute('maxOutputDerivativeOrder')));
                if~isnan(outOrder)&&outOrder>0
                    ret=true;
                    return;
                end
            end
        end

        function ret=IsFMUStateSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'2.0')||strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                node=fmuObject.fmuModelDescription.getElementsByTagName('ScheduledExecution').item(0);
            end
            value=char(node.getAttribute('canGetAndSetFMUstate'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUSerializationSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'2.0')||strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                node=fmuObject.fmuModelDescription.getElementsByTagName('ScheduledExecution').item(0);
            end
            value=char(node.getAttribute('canSerializeFMUstate'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUDirectionalDerivativeSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'2.0')||strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                node=fmuObject.fmuModelDescription.getElementsByTagName('ScheduledExecution').item(0);
            end
            if strcmp(fmuObject.fmuVersion,'2.0')
                value=char(node.getAttribute('providesDirectionalDerivative'));
            else

                value=char(node.getAttribute('providesDirectionalDerivatives'));
            end
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUAdjointDerivativeSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                node=fmuObject.fmuModelDescription.getElementsByTagName('ScheduledExecution').item(0);
            end
            value=char(node.getAttribute('providesAdjointDerivatives'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUOutputDerivativeSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                ret=false;
                return;
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                ret=false;
                return;
            end
            value=str2double(char(node.getAttribute('maxOutputDerivativeOrder')));
            if~isnan(value)&&value>0
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUElementDependencySupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                node=fmuObject.fmuModelDescription.getElementsByTagName('ScheduledExecution').item(0);
            end
            value=char(node.getAttribute('providesPerElementDependencies'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUFractionSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));

            rootNode=fmuObject.fmuModelDescription.getElementsByTagName('fmiModelDescription').item(0);
            mvNode=fmuObject.getXMLChildNode(rootNode,'ModelVariables');
            if isempty(mvNode)

                ret=false;
                return;
            end
            nodeList=mvNode.getChildNodes;
            nodeListLen=nodeList.getLength;

            for i=0:nodeListLen-1
                node=nodeList.item(i);
                if node.getNodeType~=node.ELEMENT_NODE
                    continue;
                end
                if strcmp(char(node.getNodeName),'Clock')
                    supportsFraction=char(svList.item(i).getAttribute('supportsFraction'));
                    if strcmp(supportsFraction,'true')

                        ret=true;
                        return;
                    end
                end
            end
            ret=false;
        end

        function ret=IsFMUEvaluateDiscreteStateSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                node=fmuObject.fmuModelDescription.getElementsByTagName('ModelExchange').item(0);
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                ret=false;
                return;
            end
            value=char(node.getAttribute('providesEvaluateDiscreteStates'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function ret=IsFMUEventModeSupported(fmuObject)
            assert(strcmp(fmuObject.fmuVersion,'3.0'));
            assert(~isempty(fmuObject.fmuMode));
            if strcmp(fmuObject.fmuMode,'Model Exchange')
                ret=false;
                return;
            elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                node=fmuObject.fmuModelDescription.getElementsByTagName('CoSimulation').item(0);
            else
                ret=false;
                return;
            end
            value=char(node.getAttribute('hasEventMode'));
            if strcmp(value,'true')
                ret=true;
            else
                ret=false;
            end
        end

        function CreateFMUInstance(fmuObject,userOption)
            try









































                opt=[];
                opt.loggingMethod=userOption.loggingMethod;
                opt.loggingLevel=userOption.loggingLevel;
                opt.loggerFile=userOption.loggerFile;
                if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                    opt.loggerCallback=userOption.loggerCallback;
                    opt.stepFinishedCallback=userOption.stepFinishedCallback;
                else

                    opt.logMessageCallback=userOption.logMessageCallback;
                    opt.intermediateUpdateCallback=userOption.intermediateUpdateCallback;
                    opt.lockPreemptionCallback=userOption.lockPreemptionCallback;
                    opt.unlockPreemptionCallback=userOption.unlockPreemptionCallback;
                    opt.clockUpdateCallback=userOption.clockUpdateCallback;
                end
                if strcmp(fmuObject.fmuVersion,'1.0')
                    if isempty(userOption.loadSetRealInputDerivativesFunction)
                        opt.loadSetRealInputDerivativesFunction=fmuObject.IsSetRealInputDerivativesSupported();
                    else
                        opt.loadSetRealInputDerivativesFunction=userOption.loadSetRealInputDerivativesFunction;
                    end
                    if isempty(userOption.loadGetRealOutputDerivativesFunction)
                        opt.loadGetRealOutputDerivativesFunction=fmuObject.IsGetRealOutputDerivativesSupported();
                    else
                        opt.loadGetRealOutputDerivativesFunction=userOption.loadGetRealOutputDerivativesFunction;
                    end
                elseif strcmp(fmuObject.fmuVersion,'2.0')
                    if isempty(userOption.loadFMUStateFunction)
                        opt.loadFMUStateFunction=fmuObject.IsFMUStateSupported();
                    else
                        opt.loadFMUStateFunction=userOption.loadFMUStateFunction;
                    end
                    if isempty(userOption.loadSerializationFunction)
                        opt.loadSerializationFunction=fmuObject.IsFMUSerializationSupported();
                    else
                        opt.loadSerializationFunction=userOption.loadSerializationFunction;
                    end
                    if isempty(userOption.loadDirectionalDerivativeFunction)
                        opt.loadDirectionalDerivativeFunction=fmuObject.IsFMUDirectionalDerivativeSupported();
                    else
                        opt.loadDirectionalDerivativeFunction=userOption.loadDirectionalDerivativeFunction;
                    end
                elseif strcmp(fmuObject.fmuVersion,'3.0')
                    if isempty(userOption.loadFMUStateFunction)
                        opt.loadFMUStateFunction=fmuObject.IsFMUStateSupported();
                    else
                        opt.loadFMUStateFunction=userOption.loadFMUStateFunction;
                    end
                    if isempty(userOption.loadSerializationFunction)
                        opt.loadSerializationFunction=fmuObject.IsFMUSerializationSupported();
                    else
                        opt.loadSerializationFunction=userOption.loadSerializationFunction;
                    end
                    if isempty(userOption.loadDirectionalDerivativeFunction)
                        opt.loadDirectionalDerivativeFunction=fmuObject.IsFMUDirectionalDerivativeSupported();
                    else
                        opt.loadDirectionalDerivativeFunction=userOption.loadDirectionalDerivativeFunction;
                    end
                    if isempty(userOption.loadAdjointDerivativeFunction)
                        opt.loadAdjointDerivativeFunction=fmuObject.IsFMUAdjointDerivativeSupported();
                    else
                        opt.loadAdjointDerivativeFunction=userOption.loadAdjointDerivativeFunction;
                    end
                    if isempty(userOption.loadOutputDerivativeFunction)
                        opt.loadOutputDerivativeFunction=fmuObject.IsFMUOutputDerivativeSupported();
                    else
                        opt.loadOutputDerivativeFunction=userOption.loadOutputDerivativeFunction;
                    end
                    if isempty(userOption.loadElementDependencyFunction)
                        opt.loadElementDependencyFunction=fmuObject.IsFMUElementDependencySupported();
                    else
                        opt.loadElementDependencyFunction=userOption.loadElementDependencyFunction;
                    end
                    if isempty(userOption.loadFractionFunction)
                        opt.loadFractionFunction=fmuObject.IsFMUFractionSupported();
                    else
                        opt.loadFractionFunction=userOption.loadFractionFunction;
                    end
                    if isempty(userOption.loadEvaluateDiscreteStateFunction)
                        opt.loadEvaluateDiscreteStateFunction=fmuObject.IsFMUEvaluateDiscreteStateSupported();
                    else
                        opt.loadEvaluateDiscreteStateFunction=userOption.loadEvaluateDiscreteStateFunction;
                    end
                    if isempty(userOption.loadEventModeFunction)
                        opt.loadEventModeFunction=fmuObject.IsFMUEventModeSupported();
                    else
                        opt.loadEventModeFunction=userOption.loadEventModeFunction;
                    end
                else
                    assert(false,['Invalid FMU Version: ',fmuObject.fmuVersion]);
                end
                opt.outOfProcess=userOption.outOfProcess;

                if strcmp(fmuObject.fmuVersion,'1.0')||strcmp(fmuObject.fmuVersion,'2.0')
                    if isequal(userOption.componentEnvironment,[])
                        opt.componentEnvironment=fmuObject.componentEnvironment;
                    else
                        opt.componentEnvironment=userOption.componentEnvironment;
                    end
                else

                    if isequal(userOption.instanceEnvironment,[])
                        opt.instanceEnvironment=fmuObject.componentEnvironment;
                    else
                        opt.instanceEnvironment=userOption.componentEnvironment;
                    end
                end
                opt.valRefVarNameMap=[fmuObject.valRefVarNameMap.keys',fmuObject.valRefVarNameMap.values'];


                if~isfield(userOption,'instanceName')
                    instanceName=fmuObject.fmuIdentifier;
                else
                    instanceName=userOption.instanceName;
                end



                if strcmp(fmuObject.fmuVersion,'1.0')
                    if strcmp(fmuObject.fmuMode,'Model Exchange')
                        fmuObject.fmuInstance=Simulink.FMU1ME(...
                        fmuObject.fmuDynLibFile,...
                        fmuObject.fmuIdentifier,...
                        instanceName,...
                        fmuObject.fmuGUID,...
                        int8(userOption.isLoggingOn),...
                        opt);
                    else
                        assert(strcmp(fmuObject.fmuMode,'Co-Simulation'));
                        fmuObject.fmuInstance=Simulink.FMU1CS(...
                        fmuObject.fmuDynLibFile,...
                        fmuObject.fmuIdentifier,...
                        instanceName,...
                        fmuObject.fmuGUID,...
                        matlab.net.URI(fmuObject.fmuUnzipDir).EncodedPath.char,...
                        'application/x-fmu-sharedlibrary',...
                        userOption.timeout,...
                        int8(userOption.isVisible),...
                        int8(userOption.isInteractive),...
                        int8(userOption.isLoggingOn),...
                        opt);
                    end
                elseif strcmp(fmuObject.fmuVersion,'2.0')
                    args={fmuObject.fmuDynLibFile,...
                    fmuObject.fmuIdentifier,...
                    instanceName,...
                    fmuObject.fmuGUID,...
                    matlab.net.URI(fmuObject.fmuResourceDir).EncodedPath.char,...
                    int32(userOption.isVisible),...
                    int32(userOption.isLoggingOn),...
                    opt};

                    if strcmp(fmuObject.fmuMode,'Model Exchange')
                        fmuObject.fmuInstance=Simulink.FMU2ME(args{:});
                    else
                        assert(strcmp(fmuObject.fmuMode,'Co-Simulation'));
                        fmuObject.fmuInstance=Simulink.FMU2CS(args{:});
                    end
                elseif strcmp(fmuObject.fmuVersion,'3.0')
                    args={fmuObject.fmuDynLibFile,...
                    fmuObject.fmuIdentifier,...
                    instanceName,...
                    fmuObject.fmuInstantiationToken,...
                    matlab.net.URI(fmuObject.fmuResourceDir).EncodedPath.char,...
                    userOption.isVisible,...
                    userOption.isLoggingOn,...
                    opt};



                    if strcmp(fmuObject.fmuMode,'Model Exchange')
                        fmuObject.fmuInstance=Simulink.FMU3ME(args{:});
                    elseif strcmp(fmuObject.fmuMode,'Co-Simulation')
                        fmuObject.fmuInstance=Simulink.FMU3CS(args{:});
                    else
                        assert(fmuObject.fmuMode,'Scheduled Execution')
                        fmuObject.fmuInstance=Simulink.FMU3SE(args{:});
                    end
                else
                    assert(false,['Invalid FMU Version: ',fmuObject.fmuVersion]);
                end
            catch ex
                throw(MException(message('FMUBlock:Command:CannotLoadDyLib',fmuObject.fmuDynLibFile,ex.message)));
            end
        end

        function userOptionMode=ParseUserOptionMode(~,optionalArg)

            userOptionMode='';


            if nargin==1
                return
            end


            if~iscell(optionalArg)
                throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
            end
            for i=1:length(optionalArg)
                if~iscell(optionalArg{i})||~isequal(size(optionalArg{i}),[1,2])||~ischar(optionalArg{i}{1})
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                end

                switch optionalArg{i}{1}
                case 'fmuMode'
                    switch optionalArg{i}{2}
                    case{'Model Exchange','Co-Simulation','Scheduled Execution'}
                        userOptionMode=optionalArg{i}{2};
                    otherwise
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','fmuMode')));
                    end
                end
            end
        end

        function userOption=ValidateUserOption(fmuObject,optionalArg)

            if strcmp(fmuObject.fmuVersion,'1.0')

                userOption=struct(...
                'loggingMethod','display',...
                'loggingLevel',0,...
                'loggerFile',[],...
                'loggerCallback',[],...
                'stepFinishedCallback',[],...
                'loadSetRealInputDerivativesFunction',[],...
                'loadGetRealOutputDerivativesFunction',[],...
                'outOfProcess',false,...
                'componentEnvironment',[],...
...
                'timeout',0,...
                'isVisible',false,...
                'isInteractive',false,...
                'isLoggingOn',false);


                if nargin==1
                    return
                end


                if~iscell(optionalArg)
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                end
                for i=1:length(optionalArg)
                    if~iscell(optionalArg{i})||~isequal(size(optionalArg{i}),[1,2])||~ischar(optionalArg{i}{1})
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                    end

                    switch optionalArg{i}{1}
                    case 'fmuMode'


                    case 'loggingMethod'
                        switch optionalArg{i}{2}
                        case{'display','discard','file','callback'}
                            userOption.loggingMethod=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingMethod')));
                        end

                    case 'loggingLevel'
                        switch optionalArg{i}{2}
                        case{0,1,2}
                            userOption.loggingLevel=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingLevel')));
                        end

                    case 'loggerFile'
                        if~ischar(optionalArg{i}{2})||isempty(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggerFile')));
                        end
                        userOption.loggerFile=optionalArg{i}{2};

                    case 'loggerCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggerCallback')));
                        end
                        userOption.loggerCallback=optionalArg{i}{2};

                    case 'stepFinishedCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','stepFinishedCallback')));
                        end
                        userOption.stepFinishedCallback=optionalArg{i}{2};

                    case 'loadSetRealInputDerivativesFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadSetRealInputDerivativesFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadSetRealInputDerivativesFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadSetRealInputDerivativesFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadSetRealInputDerivativesFunction')));
                        end

                    case 'loadGetRealOutputDerivativesFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadGetRealOutputDerivativesFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadGetRealOutputDerivativesFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadGetRealOutputDerivativesFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadGetRealOutputDerivativesFunction')));
                        end

                    case 'outOfProcess'
                        if islogical(optionalArg{i}{2})
                            userOption.outOfProcess=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.outOfProcess=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.outOfProcess=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','outOfProcess')));
                        end

                    case 'componentEnvironment'







                        userOption.componentEnvironment=optionalArg{i}{2};

                    case 'instanceName'
                        if~ischar(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','instanceName')));
                        else
                            userOption.instanceName=optionalArg{i}{2};
                        end

                    case 'timeout'
                        if~isscalar(optionalArg{i}{2})||~isnumeric(optionalArg{i}{2})||...
                            isinf(optionalArg{i}{2})||isnan(optionalArg{i}{2})||~isreal(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','timeout')));
                        else
                            userOption.timeout=double(optionalArg{i}{2});
                        end

                    case 'isVisible'
                        if islogical(optionalArg{i}{2})
                            userOption.isVisible=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isVisible=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isVisible=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isVisible')));
                        end

                    case 'isInteractive'
                        if islogical(optionalArg{i}{2})
                            userOption.isInteractive=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isInteractive=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isInteractive=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isInteractive')));
                        end

                    case 'isLoggingOn'
                        if islogical(optionalArg{i}{2})
                            userOption.isLoggingOn=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isLoggingOn=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isLoggingOn=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isLoggingOn')));
                        end

                    otherwise
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsName',optionalArg{i}{1})));
                    end
                end

            elseif strcmp(fmuObject.fmuVersion,'2.0')

                userOption=struct(...
                'loggingMethod','display',...
                'loggingLevel',0,...
                'loggerFile',[],...
                'loggerCallback',[],...
                'stepFinishedCallback',[],...
                'loadFMUStateFunction',[],...
                'loadSerializationFunction',[],...
                'loadDirectionalDerivativeFunction',[],...
                'outOfProcess',false,...
                'componentEnvironment',[],...
...
                'isVisible',false,...
                'isLoggingOn',false);


                if nargin==1
                    return
                end


                if~iscell(optionalArg)
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                end
                for i=1:length(optionalArg)
                    if~iscell(optionalArg{i})||~isequal(size(optionalArg{i}),[1,2])||~ischar(optionalArg{i}{1})
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                    end

                    switch optionalArg{i}{1}
                    case 'fmuMode'


                    case 'loggingMethod'
                        switch optionalArg{i}{2}
                        case{'display','discard','file','callback'}
                            userOption.loggingMethod=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingMethod')));
                        end

                    case 'loggingLevel'
                        switch optionalArg{i}{2}
                        case{0,1,2}
                            userOption.loggingLevel=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingLevel')));
                        end

                    case 'loggerFile'
                        if~ischar(optionalArg{i}{2})||isempty(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggerFile')));
                        end
                        userOption.loggerFile=optionalArg{i}{2};

                    case 'loggerCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggerCallback')));
                        end
                        userOption.loggerCallback=optionalArg{i}{2};

                    case 'stepFinishedCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','stepFinishedCallback')));
                        end
                        userOption.stepFinishedCallback=optionalArg{i}{2};

                    case 'loadFMUStateFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadFMUStateFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadFMUStateFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadFMUStateFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadFMUStateFunction')));
                        end

                    case 'loadSerializationFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadSerializationFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadSerializationFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadSerializationFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadSerializationFunction')));
                        end

                    case 'loadDirectionalDerivativeFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadDirectionalDerivativeFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadDirectionalDerivativeFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadDirectionalDerivativeFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadDirectionalDerivativeFunction')));
                        end

                    case 'outOfProcess'
                        if islogical(optionalArg{i}{2})
                            userOption.outOfProcess=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.outOfProcess=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.outOfProcess=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','outOfProcess')));
                        end

                    case 'componentEnvironment'







                        userOption.componentEnvironment=optionalArg{i}{2};

                    case 'instanceName'
                        if~ischar(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','instanceName')));
                        else
                            userOption.instanceName=optionalArg{i}{2};
                        end

                    case 'isVisible'
                        if islogical(optionalArg{i}{2})
                            userOption.isVisible=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isVisible=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isVisible=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isVisible')));
                        end

                    case 'isLoggingOn'
                        if islogical(optionalArg{i}{2})
                            userOption.isLoggingOn=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isLoggingOn=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isLoggingOn=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isLoggingOn')));
                        end

                    otherwise
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsName',optionalArg{i}{1})));
                    end
                end
            elseif strcmp(fmuObject.fmuVersion,'3.0')

                userOption=struct(...
                'loggingMethod','display',...
                'loggingLevel',0,...
                'loggerFile',[],...
                'logMessageCallback',[],...
                'intermediateUpdateCallback',[],...
                'lockPreemptionCallback',[],...
                'unlockPreemptionCallback',[],...
                'clockUpdateCallback',[],...
                'loadFMUStateFunction',[],...
                'loadSerializationFunction',[],...
                'loadDirectionalDerivativeFunction',[],...
                'loadAdjointDerivativeFunction',[],...
                'loadOutputDerivativeFunction',[],...
                'loadElementDependencyFunction',[],...
                'loadFractionFunction',[],...
                'loadEvaluateDiscreteStateFunction',[],...
                'loadEventModeFunction',[],...
                'outOfProcess',false,...
                'instanceEnvironment',[],...
...
                'isVisible',false,...
                'isLoggingOn',false,...
                'eventModeUsed',false,...
                'earlyReturnAllowed',false,...
                'requiredIntermediateVariables',[]);


                if nargin==1
                    return
                end


                if~iscell(optionalArg)
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                end
                for i=1:length(optionalArg)
                    if~iscell(optionalArg{i})||~isequal(size(optionalArg{i}),[1,2])||~ischar(optionalArg{i}{1})
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                    end

                    switch optionalArg{i}{1}
                    case 'fmuMode'


                    case 'loggingMethod'
                        switch optionalArg{i}{2}
                        case{'display','discard','file','callback'}
                            userOption.loggingMethod=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingMethod')));
                        end

                    case 'loggingLevel'
                        switch optionalArg{i}{2}
                        case{0,1,2}
                            userOption.loggingLevel=optionalArg{i}{2};
                        otherwise
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggingLevel')));
                        end

                    case 'loggerFile'
                        if~ischar(optionalArg{i}{2})||isempty(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loggerFile')));
                        end
                        userOption.loggerFile=optionalArg{i}{2};

                    case 'logMessageCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','logMessageCallback')));
                        end
                        userOption.logMessageCallback=optionalArg{i}{2};

                    case 'intermediateUpdateCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','intermediateUpdateCallback')));
                        end
                        userOption.intermediateUpdateCallback=optionalArg{i}{2};

                    case 'lockPreemptionCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','lockPreemptionCallback')));
                        end
                        userOption.lockPreemptionCallback=optionalArg{i}{2};

                    case 'unlockPreemptionCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','unlockPreemptionCallback')));
                        end
                        userOption.unlockPreemptionCallback=optionalArg{i}{2};

                    case 'clockUpdateCallback'
                        if~isa(optionalArg{i}{2},'function_handle')
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','clockUpdateCallback')));
                        end
                        userOption.clockUpdateCallback=optionalArg{i}{2};

                    case 'loadFMUStateFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadFMUStateFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadFMUStateFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadFMUStateFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadFMUStateFunction')));
                        end

                    case 'loadSerializationFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadSerializationFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadSerializationFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadSerializationFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadSerializationFunction')));
                        end

                    case 'loadDirectionalDerivativeFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadDirectionalDerivativeFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadDirectionalDerivativeFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadDirectionalDerivativeFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadDirectionalDerivativeFunction')));
                        end

                    case 'loadAdjointDerivativeFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadAdjointDerivativeFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadAdjointDerivativeFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadAdjointDerivativeFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadAdjointDerivativeFunction')));
                        end

                    case 'loadOutputDerivativeFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadOutputDerivativeFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadOutputDerivativeFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadOutputDerivativeFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadOutputDerivativeFunction')));
                        end

                    case 'loadElementDependencyFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadElementDependencyFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadElementDependencyFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadElementDependencyFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadElementDependencyFunction')));
                        end

                    case 'loadFractionFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadFractionFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadFractionFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadFractionFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadFractionFunction')));
                        end

                    case 'loadEvaluateDiscreteStateFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadEvaluateDiscreteStateFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadEvaluateDiscreteStateFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadEvaluateDiscreteStateFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadEvaluateDiscreteStateFunction')));
                        end

                    case 'loadEventModeFunction'
                        if islogical(optionalArg{i}{2})
                            userOption.loadEventModeFunction=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.loadEventModeFunction=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.loadEventModeFunction=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','loadEventModeFunction')));
                        end

                    case 'outOfProcess'
                        if islogical(optionalArg{i}{2})
                            userOption.outOfProcess=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.outOfProcess=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.outOfProcess=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','outOfProcess')));
                        end

                    case 'instanceEnvironment'







                        userOption.instanceEnvironment=optionalArg{i}{2};

                    case 'instanceName'
                        if~ischar(optionalArg{i}{2})
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','instanceName')));
                        else
                            userOption.instanceName=optionalArg{i}{2};
                        end

                    case 'isVisible'
                        if islogical(optionalArg{i}{2})
                            userOption.isVisible=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isVisible=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isVisible=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isVisible')));
                        end

                    case 'isLoggingOn'
                        if islogical(optionalArg{i}{2})
                            userOption.isLoggingOn=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.isLoggingOn=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.isLoggingOn=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','isLoggingOn')));
                        end

                    case 'eventModeUsed'
                        if islogical(optionalArg{i}{2})
                            userOption.eventModeUsed=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.eventModeUsed=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.eventModeUsed=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','eventModeUsed')));
                        end

                    case 'earlyReturnAllowed'
                        if islogical(optionalArg{i}{2})
                            userOption.earlyReturnAllowed=optionalArg{i}{2};
                        elseif strcmp(optionalArg{i}{2},'on')
                            userOption.earlyReturnAllowed=true;
                        elseif strcmp(optionalArg{i}{2},'off')
                            userOption.earlyReturnAllowed=false;
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','earlyReturnAllowed')));
                        end

                    case 'requiredIntermediateVariables'
                        if isempty(optionalArg{i}{2})||(isvector(optionalArg{i}{2})&&isa(optionalArg{i}{2},'uint32'))
                            userOption.requiredIntermediateVariables=optionalArg{i}{2};
                        else
                            throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','requiredIntermediateVariables')));
                        end

                    otherwise
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsName',optionalArg{i}{1})));
                    end
                end


            else
                assert(false,['Invalid FMU version: ',fmuObject.fmuVersion]);
            end
        end

        function simOption=ValidateSimOption(~,optionalArg)

            simOption=struct(...
            'tolerance',[],...
            'callResetAfterSim',true);


            if nargin==1
                return
            end


            if~iscell(optionalArg)
                throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
            end
            for i=1:length(optionalArg)
                if~iscell(optionalArg{i})||~isequal(size(optionalArg{i}),[1,2])||~ischar(optionalArg{i}{1})
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgs')));
                end

                switch optionalArg{i}{1}
                case 'tolerance'
                    if isempty(optionalArg{i}{2})
                        simOption.tolerance=[];
                    elseif isscalar(optionalArg{i}{2})&&isreal(optionalArg{i}{2})...
                        &&isa(optionalArg{i}{2},'double')&&~isnan(optionalArg{i}{2})&&~isinf(optionalArg{i}{2})
                        simOption.tolerance=optionalArg{i}{2};
                    else
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue','tolerance')));
                    end
                case 'callResetAfterSim'
                    if islogical(optionalArg{i}{2})
                        userOption.(optionalArg{i}{1})=optionalArg{i}{2};
                    elseif strcmp(optionalArg{i}{2},'on')
                        userOption.(optionalArg{i}{1})=true;
                    elseif strcmp(optionalArg{i}{2},'off')
                        userOption.(optionalArg{i}{1})=false;
                    else
                        throw(MException(message('FMUBlock:Command:InvalidOptionalArgsValue',optionalArg{i}{1})));
                    end
                otherwise
                    throw(MException(message('FMUBlock:Command:InvalidOptionalArgsName',optionalArg{i}{1})));
                end
            end

        end

        function isAsync=CheckErrorStatusForSimulate(fmuObject,retStatus,fcnName,needReset)








            switch retStatus
            case{0,1}
                isAsync=false;
                return
            case 2
                warning(message('FMUBlock:Command:ReturnStatusDiscard',fcnName));
                isAsync=false;
                return
            case 3
                if needReset
                    fmuObject.fmuInstance.reset();
                end
                throw(MException(message('FMUBlock:Command:ReturnStatusError',fcnName)));
            case 4
                throw(MException(message('FMUBlock:Command:ReturnStatusFatal',fcnName)));
            case 5
                isAsync=true;
                return
            end
        end
    end

    methods(Static,Access=public)
        function fmuObject=Load(fmuFileName,varargin)

            narginchk(1,2);


            fmuObject=Simulink.FMUObject();


            userOption=[];
            userOption.fmuMode=fmuObject.ParseUserOptionMode(varargin{:});


            if~ischar(fmuFileName)&&~isstring(fmuFileName)
                throw(MException(message('FMUBlock:Command:RequireString',1)));
            end
            fmuObject.fmuFile=fmuFileName;


            fmuObject.CheckAndUnzipFMU();


            fmuObject.LoadModelDescriptionXML(userOption.fmuMode);


            userOption=fmuObject.ValidateUserOption(varargin{:});


            fmuObject.ValidateModelDescriptionXML();


            fmuObject.CreateVariableMaps();


            fmuObject.CreateComponentOrInstanceEnvironment();


            fmuObject.CreateFMUInstance(userOption);


        end
    end

    methods(Static,Access=private)
        function PauseFor(sec)
            pauseFlag=pause('on');
            pauseFlagObj=onCleanup(@()pause(pauseFlag));
            pause(sec);
        end
    end


    methods(Access=protected)
        function obj=FMUObject()


        end
    end


    methods(Access=public)
        function delete(obj)



            if isa(obj.fmuInstance,'handle')
                obj.fmuInstance.delete;
            end


            obj.fmuModelDescription=[];

            try

                rmdir(obj.fmuUnzipDir,'s');
            catch




                try
                    Simulink.FMUObject.PauseFor(1);
                    rmdir(obj.fmuUnzipDir,'s');
                catch
                end
            end
            try

                rmdir(fullfile(obj.fmuUnzipBase,'slprj','_fmu'));
                rmdir(fullfile(obj.fmuUnzipBase,'slprj'));
            catch
            end
        end


        function output=Simulate(fmuObject,time,input,varargin)


            narginchk(2,4);

            if nargin==2
                input=containers.Map;
            end

            if~isa(time,'double')||~isrow(time)||~isreal(time)
                throw(MException(message('FMUBlock:Command:InvalidTimeVector')));
            end

            if~isvalid(fmuObject.fmuInstance)

                throw(MException(message('FMUBlock:Command:InvalidFMUInstance')));
            end

            if~isa(input,'containers.Map')
                throw(MException(message('FMUBlock:Command:InvalidInput')));
            end


            simOption=fmuObject.ValidateSimOption(varargin{:});


            comp=fmuObject.fmuInstance;
            if isempty(simOption.tolerance)
                hasRelTol=0;relTol=0.001;
            else
                hasRelTol=1;relTol=simOption.tolerance;
            end
            retStatus=comp.setupExperiment(hasRelTol,relTol,time(1),1,time(end));
            fmuObject.CheckErrorStatusForSimulate(retStatus,'SetupExperiment',simOption.callResetAfterSim);


            retStatus=comp.enterInitializationMode;
            fmuObject.CheckErrorStatusForSimulate(retStatus,'EnterInitializationMode',simOption.callResetAfterSim);

            retStatus=comp.exitInitializationMode;
            fmuObject.CheckErrorStatusForSimulate(retStatus,'ExitInitializationMode',simOption.callResetAfterSim);



            inputKeys=input.keys;
            inputValues=input.values;

            numRKeys=0;
            numIKeys=0;
            numBKeys=0;
            numSKeys=0;
            inputDataTypeMap=char(zeros(1,length(inputKeys)));
            inputListIndexMap=zeros(1,length(inputKeys));
            for i=1:length(inputKeys)
                if fmuObject.realInputMap.isKey(inputKeys{i})
                    numRKeys=numRKeys+1;
                    inputDataTypeMap(i)='r';
                    inputListIndexMap(i)=numRKeys;
                elseif fmuObject.integerInputMap.isKey(inputKeys{i})
                    numIKeys=numIKeys+1;
                    inputDataTypeMap(i)='i';
                    inputListIndexMap(i)=numIKeys;
                elseif fmuObject.booleanInputMap.isKey(inputKeys{i})
                    numBKeys=numBKeys+1;
                    inputDataTypeMap(i)='b';
                    inputListIndexMap(i)=numBKeys;
                elseif fmuObject.stringInputMap.isKey(inputKeys{i})
                    numSKeys=numSKeys+1;
                    inputDataTypeMap(i)='s';
                    inputListIndexMap(i)=numSKeys;
                else

                end
            end



            inputRList=uint32(zeros(1,numRKeys));
            inputIList=uint32(zeros(1,numIKeys));
            inputBList=uint32(zeros(1,numBKeys));
            inputSList=uint32(zeros(1,numSKeys));
            inputRBuffer=double(zeros(length(inputRList),length(time)));
            inputIBuffer=int32(zeros(length(inputIList),length(time)));
            inputBBuffer=int32(zeros(length(inputBList),length(time)));
            inputSBuffer=cell(length(inputSList),length(time));


            for i=1:length(inputDataTypeMap)
                if inputDataTypeMap(i)=='r'
                    inputRList(inputListIndexMap(i))=fmuObject.realInputMap(inputKeys{i});
                    inputRBuffer(inputListIndexMap(i),:)=inputValues{i};
                elseif inputDataTypeMap(i)=='i'
                    inputIList(inputListIndexMap(i))=fmuObject.integerInputMap(inputKeys{i});
                    inputIBuffer(inputListIndexMap(i),:)=inputValues{i};
                elseif inputDataTypeMap(i)=='b'
                    inputBList(inputListIndexMap(i))=fmuObject.booleanInputMap(inputKeys{i});
                    inputBBuffer(inputListIndexMap(i),:)=inputValues{i};
                elseif inputDataTypeMap(i)=='s'
                    inputSList(inputListIndexMap(i))=fmuObject.stringInputMap(inputKeys{i});
                    inputSBuffer(inputListIndexMap(i),:)=inputValues{i};
                else
                    assert(false,'Unrecognized type');
                end
            end





            outputRList=cell2mat(fmuObject.realOutputMap.values);
            outputIList=cell2mat(fmuObject.integerOutputMap.values);
            outputBList=cell2mat(fmuObject.booleanOutputMap.values);
            outputSList=cell2mat(fmuObject.stringOutputMap.values);
            outputRBuffer=double(zeros(length(outputRList),length(time)));
            outputIBuffer=int32(zeros(length(outputIList),length(time)));
            outputBBuffer=int32(zeros(length(outputBList),length(time)));
            outputSBuffer=cell(length(outputSList),length(time));




            if~isempty(outputRList)
                [retStatus,outputRBuffer(:,1)]=comp.getReal(outputRList,length(outputRList));
                fmuObject.CheckErrorStatusForSimulate(retStatus,'GetReal',simOption.callResetAfterSim);
            end
            if~isempty(outputIList)
                [retStatus,outputIBuffer(:,1)]=comp.getInteger(outputIList,length(outputIList));
                fmuObject.CheckErrorStatusForSimulate(retStatus,'GetInteger',simOption.callResetAfterSim);
            end
            if~isempty(outputBList)
                [retStatus,outputBBuffer(:,1)]=comp.getBoolean(outputBList,length(outputBList));
                fmuObject.CheckErrorStatusForSimulate(retStatus,'GetBoolean',simOption.callResetAfterSim);
            end
            if~isempty(outputSList)
                [retStatus,outputSBuffer(:,1)]=comp.getString(outputSList,length(outputSList));
                fmuObject.CheckErrorStatusForSimulate(retStatus,'GetString',simOption.callResetAfterSim);
            end


            for t=1:length(time)-1

                if~isempty(inputRList)
                    retStatus=comp.setReal(inputRList,length(inputRList),inputRBuffer(:,t));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'SetReal',simOption.callResetAfterSim);
                end
                if~isempty(inputIList)
                    retStatus=comp.setInteger(inputIList,length(inputIList),inputIBuffer(:,t));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'SetInteger',simOption.callResetAfterSim);
                end
                if~isempty(inputBList)
                    retStatus=comp.setBoolean(inputBList,length(inputBList),inputBBuffer(:,t));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'SetBoolean',simOption.callResetAfterSim);
                end
                if~isempty(inputSList)
                    retStatus=comp.setString(inputSList,length(inputSList),inputSBuffer(:,t));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'SetString',simOption.callResetAfterSim);
                end


                retStatus=comp.doStep(time(t),time(t+1)-time(t),1);
                isAsync=fmuObject.CheckErrorStatusForSimulate(retStatus,'DoStep',simOption.callResetAfterSim);
                if isAsync




                    while isAsync
                        [retStatus,isAsync]=comp.getStatus(0);
                        fmuObject.CheckErrorStatusForSimulate(retStatus,'GetStatus',simOption.callResetAfterSim);
                    end
                end


                if~isempty(outputRList)
                    [retStatus,outputRBuffer(:,t+1)]=comp.getReal(outputRList,length(outputRList));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'GetReal',simOption.callResetAfterSim);
                end
                if~isempty(outputIList)
                    [retStatus,outputIBuffer(:,t+1)]=comp.getInteger(outputIList,length(outputIList));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'GetInteger',simOption.callResetAfterSim);
                end
                if~isempty(outputBList)
                    [retStatus,outputBBuffer(:,t+1)]=comp.getBoolean(outputBList,length(outputBList));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'GetBoolean',simOption.callResetAfterSim);
                end
                if~isempty(outputSList)
                    [retStatus,outputSBuffer(:,t+1)]=comp.getString(outputSList,length(outputSList));
                    fmuObject.CheckErrorStatusForSimulate(retStatus,'GetString',simOption.callResetAfterSim);
                end
            end


            retStatus=comp.terminate();
            fmuObject.CheckErrorStatusForSimulate(retStatus,'Terminate',simOption.callResetAfterSim);

            if simOption.callResetAfterSim
                retStatus=comp.reset();
                fmuObject.CheckErrorStatusForSimulate(retStatus,'Reset',false);
            end


            outputKeys=[fmuObject.realOutputMap.keys,fmuObject.integerOutputMap.keys,fmuObject.booleanOutputMap.keys,fmuObject.stringOutputMap.keys];
            outputValues=[mat2cell(outputRBuffer,ones(1,length(outputRList)),length(time))',...
            mat2cell(outputIBuffer,ones(1,length(outputIList)),length(time))',...
            mat2cell(outputBBuffer,ones(1,length(outputBList)),length(time))',...
            mat2cell(outputSBuffer,ones(1,length(outputSList)),length(time))'];
            output=containers.Map(outputKeys,outputValues);
        end


        function Reset(fmuObject)
            retStatus=fmuObject.fmuInstance.reset();
            fmuObject.CheckErrorStatusForSimulate(retStatus,'Reset',false);
        end
    end

    methods(Access=public,Hidden=true)
        function ret=getInstance(obj)
            ret=obj.fmuInstance;
        end
        function ret=getModelDescription(obj)
            ret=obj.fmuModelDescription;
        end
        function ret=getUnzipDirectory(obj)
            ret=obj.fmuUnzipDir;
        end
    end
end


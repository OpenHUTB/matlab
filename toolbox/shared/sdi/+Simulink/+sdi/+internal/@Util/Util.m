classdef Util




    properties(Constant=true)

        Interp={'zoh','linear'};
        Sync={'union','intersection','uniform'};
    end

    methods(Static=true)

        function result=isSimscapeLoggingNode(var)
            result=isa(var,'simscape.logging.Node');
        end

        function result=isMATLABTimeseries(var)
            result=isa(var,'timeseries');
        end

        function result=isSimulinkTimeseries(var)
            result=isa(var,'Simulink.Timeseries');
        end

        function result=isModelDataLogs(var)
            result=isa(var,'Simulink.ModelDataLogs');
        end

        function result=isSubsysDataLogs(var)
            result=isa(var,'Simulink.SubsysDataLogs');
        end

        function result=isScopeDataLogs(var)
            result=isa(var,'Simulink.ScopeDataLogs');
        end

        function result=isStateflowDataLogs(var)
            result=isa(var,'Simulink.StateflowDataLogs');
        end

        function result=isStateflowSimulationData(var)
            result=isa(var,'Stateflow.SimulationData.Data');
        end

        function result=isTSArray(var)
            result=isa(var,'Simulink.TsArray');
        end

        function result=isSimulationOutput(var)
            result=isa(var,'Simulink.SimulationOutput');
        end

        function result=isStructureWithTime(var)
            result=isstruct(var)...
            &&isfield(var,'time')...
            &&isfield(var,'signals')...
            &&~isempty(var.time)...
            &&isfield(var.signals,'values')...
            &&isfield(var.signals,'label')...
            &&isfield(var.signals,'dimensions');
        end

        function result=isStructureWithoutTime(var)
            result=isstruct(var)...
            &&isfield(var,'time')...
            &&isfield(var,'signals')...
            &&isempty(var.time)...
            &&isfield(var.signals,'values')...
            &&isfield(var.signals,'label')...
            &&isfield(var.signals,'dimensions');
        end

        function result=isSimulationDataSet(var)
            result=isa(var,'Simulink.SimulationData.Dataset');
        end

        function result=isSimulationDataElement(var)
            result=isa(var,'Simulink.SimulationData.Element');
        end

        function result=isCoderExecutionTimeSection(var)
            result=isa(var,'coder.profile.ExecutionTimeSection');
        end

        function result=isCoderExecutionTime(var)
            result=isa(var,'coder.profile.ExecutionTime')...
            &&feval('isTimeSeriesDataAvailable',var);
        end

        function result=isSDISupportedType(var)
            import Simulink.sdi.internal.Util;


            result=Util.isMATLABTimeseries(var)...
            ||Util.isSimulinkTimeseries(var)...
            ||Util.isModelDataLogs(var)...
            ||Util.isSubsysDataLogs(var)...
            ||Util.isScopeDataLogs(var)...
            ||Util.isTSArray(var)...
            ||Util.isSimulationOutput(var)...
            ||Util.isStructureWithTime(var)...
            ||Util.isStructureWithoutTime(var)...
            ||Util.isSimulationDataSet(var)...
            ||Util.isCoderExecutionTime(var)...
            ||Util.isCoderExecutionTimeSection(var)...
            ||Util.isSimscapeLoggingNode(var);
        end


        function result=IsSDISupportedType(var)
            result=Simulink.sdi.internal.Util.isSDISupportedType(var);
        end

        function VarValues=baseWorkspaceValuesForNames(VarNames)

            VarCount=length(VarNames);


            VarValues=cell(1,VarCount);
            for i=1:VarCount

                if~isstruct(VarNames{i})
                    varName=VarNames{i};
                else
                    if isfield(VarNames{i},'VarName')
                        varName=VarNames{i}.VarName;
                    else

                        continue;
                    end
                end

                try
                    VarValues{i}=evalin('base',varName);
                catch ME %#ok
                    VarValues{i}=[];
                end
            end
        end



        function result=validateType(value,type)
            result=isa(value,type);
        end

        function validatedValue=validateTolerance(value)
            validatedValue=Simulink.sdi.internal.Util.validateScalarNumericValue(value);
            if validatedValue<0
                error(message('SDI:sdi:NOT_POSITIVE',validatedValue));
            end
        end

        function validatedValue=validateScalarNumericValue(value)


            validatedValue=0;%#ok<NASGU>

            if(isempty(value))
                error(message('SDI:sdi:EmptyValue'));
            end




            if(ischar(value)||~isscalar(value)||~isreal(value))
                error(message('SDI:sdi:ValidateDataType',...
                'scalar numeric','real'));
            end


            if(isnan(value))
                error(message('SDI:sdi:ValAreNaNs'));
            end


            if isinf(value)
                error(message('SDI:sdi:ValAreInf'));
            end


            if(isa(value,'embedded.fi'))
                error(message('SDI:sdi:ValAreFi'));
            end


            if(value>0&&value<eps)
                error(message('SDI:sdi:ValAreSmallerEpsGraterZero'));
            end

            validatedValue=value;
        end

        function validatedInterpMtd=validateInterpMethod(value)

            validatedInterpMtd=[];%#ok<NASGU>

            if(~ischar(value))
                error(message('SDI:sdi:ValidateDataType',...
                'interp method','char'));
            end

            value=lower(value);

            if(~(strcmp(value,'linear')||strcmp(value,'zoh')))
                error(message('SDI:sdi:ValidateInterpOpts',value));
            end

            validatedInterpMtd=value;

        end

        function validatedSyncMtd=validateSyncMethod(value)

            validatedSyncMtd=[];%#ok<NASGU>

            if(~ischar(value))
                error(message('SDI:sdi:ValidateDataType',...
                'sync method','char'));
            end

            value=lower(value);

            if(~(strcmp(value,'union')||...
                strcmp(value,'intersection')||...
                strcmp(value,'uniform')))
                error(message('SDI:sdi:ValidateSyncOpts',value));
            end

            validatedSyncMtd=value;

        end

        function validatedInterval=validateInterval(value)
            validatedInterval=Simulink.sdi.internal.Util.validateScalarNumericValue(value);
        end

        function OnOff=boolToOnOff(bool)
            if bool,OnOff='on';
            else OnOff='off';
            end
        end

        function clearAxes(hAxes)

            funcHandle=get(hAxes,'ButtonDownFcn');
            xCol=get(hAxes,'XColor');
            yCol=get(hAxes,'YColor');
            lineWidth=get(hAxes,'LineWidth');
            boxOnOff=get(hAxes,'Box');
            cla(hAxes,'reset');
            set(hAxes,'ButtonDownFcn',funcHandle,'XColor',xCol,...
            'YColor',yCol,'LineWidth',lineWidth,'Box',boxOnOff);
        end


        function out=isField(object,fieldname)
            t=fieldnames(object);
            out=~isempty(find(strcmp(t,fieldname),1));
        end


        function[pieces2,tempBlkPath,blkName]=helperSplitString(blkPath)

            tempBlkPath=strrep(blkPath,'//','_dBl_sLaSh_');

            pieces2=regexp(tempBlkPath,'\/','split');

            pieces2=cellfun(@(x)strrep(x,'_dBl_sLaSh_','//'),pieces2,...
            'UniformOutput',false);
            blkName=pieces2{end};
        end

        function list=helperFixVarNameOneObject(list,outName)
            count=length(list);
            for i=1:count
                list{i}=[outName,'.find(''',list{i},''')'];
            end
        end

        function markerNum=resolveMarker(markerStrOrNum)
            baseMarkers={'none','+','o','*','.','x','s','d',...
            '^','v','>','<','p','h'};
            if(isnumeric(markerStrOrNum))
                if~(markerStrOrNum<length(baseMarkers)+1)
                    markerStrOrNum=1;
                end
                markerNum=baseMarkers{markerStrOrNum};
            else
                index=find(cellfun(@(x)strcmp(x,markerStrOrNum),baseMarkers),...
                1);
                if isempty(index)
                    markerNum=1;
                else
                    markerNum=index;
                end
            end
        end

        function dlgFilter=uigetfileFilter(filepath,varargin)
            validExtensions={};
            if nargin>1&&strcmp(varargin{1},'import')
                for idx=1:length(varargin{2})
                    validExtensions{idx}=['*',varargin{2}{idx}];%#ok
                end
                validExtensions=validExtensions';
                defFilter=validExtensions;
            else
                defFilter='*.mldatx';
            end

            if~isempty(filepath)
                [pathstr,~,ext]=fileparts(filepath);
                if isempty(ext)


                    defFilter='*.mat';
                elseif Simulink.sdi.internal.Util.isFileExtensionValid(filepath,varargin{2})
                    defFilter=['*',ext];
                end
                if isempty(pathstr)
                    dlgFilter=defFilter;
                else
                    if pathstr(end)~=filesep
                        pathstr=[pathstr,filesep];
                    end
                    dlgFilter=[pathstr,defFilter];
                end
            else
                dlgFilter=defFilter;
            end
        end

        function result=isValidSDIMatFile(filename)

            try
                descriptor=whos('-file',filename,'SDIDescriptor');
                result=~isempty(descriptor);
            catch me %#ok<NASGU>
                result=false;
            end
        end

        function[fname,isMAT]=getFullSessionFilename(fname,varargin)
            validExtensions=varargin{1};


            isMAT=false;
            if isempty(fname)
                return
            end


            if exist(fname,'file')
                isMAT=Simulink.sdi.internal.Util.isFileExtensionValid(fname,validExtensions);
                return
            end
        end

        function isValidFileExt=isFileExtensionValid(fname,validExtensions)
            [~,~,ext]=fileparts(fname);
            isValidFileExt=ismember(lower(ext),validExtensions);
        end

        function[result,filename]=getSDIMatFileVersion(filename,varargin)
            validExtensions={'.mat'};
            if nargin>1
                validExtensions=varargin{1};
            end
            result=0;
            if isempty(filename)
                return
            end
            [filename,isMAT]=Simulink.sdi.internal.Util.getFullSessionFilename(filename,validExtensions);

            if~exist(filename,'file')||exist(filename,'file')==7

                return
            end


            if~isMAT
                result=3;
                return
            end



            [~,~,ext]=fileparts(filename);
            try
                if(isequal(lower(ext),'.mp4')||isequal(lower(ext),'.webm'))
                    return;
                end
                descriptor=whos('-file',filename,'SDRDescriptor');
            catch me %#ok<NASGU>
                return
            end
            if~isempty(descriptor)
                result=2;
                return;
            end


            descriptor=whos('-file',filename,'SDIDescriptor');
            if~isempty(descriptor)
                result=1;
                return;
            end
        end


        function rootSourceElements=createDataHierarchyGroupArray(signalID,eng)

            s=Simulink.sdi.getSignal(signalID);
            rootSource=s.RootSource;
            if~isempty(rootSource)&&rootSource(end)=='.'
                blockPath=eng.getSignalBlockSource(signalID);
                blockPathElements=regexp(blockPath,'/','split');
                rootSource=[rootSource,blockPathElements{end}];
            end
            [rootSourceElements,~]=Simulink.sdi.internal.Util.helperConstructRootSrc(rootSource);
        end


        function[pieces,rootSrc]=helperConstructRootSrc(rootSrc)





            rootSrc1=regexp(rootSrc,sprintf('\n'),'split');
            rootSrc=rootSrc1{1};
            rootSrc1{1}=regexprep(rootSrc1{1},...
            '(\.)([^\.]*?)(\((\s*(\s*\d\s*,\s*)*(\s*\d\s*))?\))','$1$2.$2$3');
            pieces=regexp(rootSrc1{1},'\.','split');

            if length(rootSrc1)>1
                rootSrc1{2}=regexprep(rootSrc1{2},...
                '(\.)([^\.]*?)(\((\s*(\s*\d\s*,\s*)*(\s*\d\s*))?\))','$1$2.$2$3');
                piecesAfterBreak=regexp(rootSrc1{2},'\.','split');
                count=length(pieces);
                numPiecesAfterBreak=length(piecesAfterBreak);
                for i=1:count


                    if i<numPiecesAfterBreak&&~strcmp(pieces{i},piecesAfterBreak{i})


                        [cellSuffix,~,~]=regexp(piecesAfterBreak{3},...
                        'getElement\(.*?\)',...
                        'match','start','end');
                        if length(cellSuffix)==1
                            pieces{i}=[pieces{i},'#',cellSuffix{1}];
                        end
                    end
                end
            end
        end


        function leafIDs_out=findAllLeafSigIDsForThisRoot(rep,rootID,leafIDs_in)
            if rep.isValidSignal(rootID)
                import Simulink.sdi.internal.Util;
                children=rep.getSignalChildren(rootID);
                leafIDs_out=leafIDs_in;
                if~isempty(children)
                    for chIdx=1:length(children)
                        leafIDs_out=...
                        [leafIDs_out,Util.findAllLeafSigIDsForThisRoot(rep,children(chIdx),[])];%#ok<AGROW>
                    end
                else
                    leafIDs_out=[leafIDs_out,rootID];
                end
            else
                leafIDs_out=leafIDs_in;
            end
        end


        function leafIDs_out=findAllLeafSigIDsForAllTheseSignals(rep,rootIDs)
            import Simulink.sdi.internal.Util;
            leafIDs=[];
            for rootIdx=1:length(rootIDs)
                leafIDs=[leafIDs,Util.findAllLeafSigIDsForThisRoot(rep,rootIDs(rootIdx),[])];%#ok<AGROW>
            end
            leafIDs_out=leafIDs;
        end

        function[row,col]=getRowColFromSubPlotIndex(spIndex)
            if spIndex<=0||spIndex>64
                error(message('SDI:sdi:InvalidValue'));
            end
            col=idivide(int32(spIndex-1),8)+1;
            row=int32(mod(spIndex-1,8)+1);
        end


        function client=getConnectedClient(app)
            client=[];
            clients=Simulink.sdi.WebClient.getAllClients(app);
            for idx=1:length(clients)
                if strcmpi(clients(idx).Status,'connected')&&...
                    ~isempty(clients(idx).Axes)
                    client=clients(idx);
                    locWaitForClientLayout(client,app);
                    return
                end
            end
        end


        function waitForTimeSpanUpdate(client,axesIdx,val)
            if size(val)~=size(client.Axes(axesIdx).TimeSpan)
                val=val';
            end

            MAX_RETRIES=20;
            for idx=1:MAX_RETRIES
                if locVerifyEqual(client.Axes(axesIdx).TimeSpan,val)
                    return
                end
                locWait(0.2);
            end
        end


        function waitForYRangeUpdate(client,axesIdx,val)
            if size(val)~=size(client.Axes(axesIdx).YRange)
                val=val';
            end

            MAX_RETRIES=20;
            for idx=1:MAX_RETRIES
                if locVerifyEqual(client.Axes(axesIdx).YRange,val)
                    return
                end
                locWait(0.2);
            end
        end


        function layoutValidationFcn(dimVal)
            validateattributes(dimVal,'numeric',{'scalar'});
            if round(dimVal)~=dimVal
                error(message('SDI:sdi:ValidateDataType','row','integer'));
            end
        end


        function viewValidationFcn(viewVal)
            expectedViewVals={'inspect','compare'};
            validatestring(viewVal,expectedViewVals);
        end


        function client=getClientFromView(view)
            import Simulink.sdi.internal.Util;
            switch view
            case 'inspect'
                if Simulink.sdi.internal.WebGUI.debugMode()
                    client=Util.getConnectedClient('sdi-debug');
                else
                    client=Util.getConnectedClient('sdi');
                end
            case 'compare'
                client=Util.getConnectedClient('SDIComparison');
            end
        end


        function validateLayoutRange(row,col,view)
            switch view
            case 'inspect'
                plotPref=Simulink.sdi.getViewPreferences().plotPref;
                validateattributes(row,'numeric',{'scalar','>=',1,'<=',plotPref.numPlotRows},'','row');
                validateattributes(col,'numeric',{'scalar','>=',1,'<=',plotPref.numPlotCols},'','column');
            case 'compare'
                validateattributes(row,'numeric',{'scalar','>=',1,'<=',2},'','row');
                validateattributes(col,'numeric',{'scalar','>',0,'<',2},'','column');
            end
        end


        function validateVizType(row,col,view,vizTypes)
            switch view
            case 'inspect'
                type=sdi_visuals.getVisualizationName(0,row,col);
                if isempty(type)
                    type='Time Plot';
                end
                if isempty(find(strcmp(vizTypes,type),1))
                    error(message('SDI:sdi:NotATimePlot',row,col));
                end
            end
        end


        function ret=getMaxSigsPref

            if~ispref('sdiinternal','maxplottedsignals')
                addpref('sdiinternal','maxplottedsignals',100);
            end
            ret=getpref('sdiinternal','maxplottedsignals');
            assert(isnumeric(ret));
        end

    end

end


function isLimitEqual=locVerifyEqual(a,b)

    isLimitEqual=false;
    TOL=max(eps(a),eps(b))*10;
    diffLimits=abs(a-b);
    if all(diffLimits<TOL)
        isLimitEqual=true;
    end
end


function locWaitForClientLayout(client,app)

    if~isempty(client)
        MAX_TRIES=20;
        numAxes=2;
        if~strcmpi(app,'SDIComparison')


            plotPref=Simulink.sdi.getViewPreferences().plotPref;
            numAxes=plotPref.numPlotCols*plotPref.numPlotRows;
        end
        numTries=0;
        while numTries<MAX_TRIES
            if numAxes==length(client.Axes)
                break;
            end
            locWait(0.2);
            numTries=numTries+1;
        end
    end
end


function locWait(val)
    pause(val);
drawnow
end



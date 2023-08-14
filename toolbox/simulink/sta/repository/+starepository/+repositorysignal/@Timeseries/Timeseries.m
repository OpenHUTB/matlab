classdef Timeseries<starepository.repositorysignal.LeafSignalInterface






    properties
        SUPPORTED_FORMATS={'timeseries','simulinktimeseries','datasetElement:timeseries','datasetElement:simulinktimeseries'};
    end


    methods

        function bool=isSupported(obj,dbId,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS))||...
            (isempty(dataFormat)&&isempty(obj.repoUtil.getChildrenIds(dbId)))||...
            ~isempty(strfind(dataFormat,'structElementIndex:'));%#ok<STREMP> %g1208293
        end


        function[varValue,varName]=extractValue(obj,dbId,varargin)







            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end


            [Time,Vals]=obj.repoUtil.getSignalTimeAndDataValues(dbId);


            varName=obj.repoUtil.getVariableName(dbId);


            if isempty(Vals)

                theType=obj.repoUtil.getMetaDataByName(dbId,'DataType');


                Time=double.empty(0,1);
                Vals=resolveEmptyValues(obj,Vals,theType);

            end

            castToDt=obj.repoUtil.getMetaDataByName(dbId,'CastToDataType');

            if~isempty(castToDt)&&obj.castData
                Vals=starepository.slCastData(Vals,castToDt);
            end


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');
            fixDtOverride=obj.repoUtil.getMetaDataByName(dbId,'FixDTOverrideType');

            if~isempty(fixDtOverride)
                if~isempty(strfind(fixDtOverride,'fixdt'))%#ok<STREMP>
                    fiType=eval(fixDtOverride);
                    Vals=fi(Vals,fiType);
                else
                    Vals=fi(Vals,fixdt(fixDtOverride));
                end
            end

            isFixdt=obj.repoUtil.getMetaDataByName(dbId,'isFixDT');


            if isFixdt
                if obj.repoUtil.getMetaDataByName(dbId,'isfimathlocal')

                    fiMathStruct=obj.repoUtil.getMetaDataByName(dbId,'fimath');
                    Vals=setFiMathFromStruct(fiMathStruct,Vals);
                end
            end


            if isempty(format)||~isempty(strfind(format,'structElementIndex:'))%#ok<STREMP>
                format='timeseries';
            end


            switch lower(format)
            case 'timeseries'

                varValue=contstructTimeseries(obj,Vals,Time);

            case 'simulinktimeseries'

                varValue=Simulink.Timeseries();
                varValue.Data=Vals;
                varValue.Time=Time;
                varValue.BlockPath=obj.repoUtil.getMetaDataByName(dbId,'signalBlockPath');

                portIndex=obj.repoUtil.getMetaDataByName(dbId,'signalPortIndex');
                if~isempty(portIndex)
                    varValue.PortIndex=portIndex;
                else
                    varValue.PortIndex=[];
                end
                varValue.SignalName=obj.repoUtil.getMetaDataByName(dbId,'signalSignalName');
                varValue.ParentName=obj.repoUtil.getMetaDataByName(dbId,'signalParentName');
            case lower('datasetElement:timeseries')

                varValue=contstructTimeseries(obj,Vals,Time);
            case lower('loggedsignal:timeseries')
                varValue=contstructTimeseries(obj,Vals,Time);
            case lower('loggedstate:timeseries')

                varValue=contstructTimeseries(obj,Vals,Time);
            case lower('datasetElement:loggedsignal:timeseries')
                varValue=contstructTimeseries(obj,Vals,Time);
            case lower('datasetElement:simulinktimeseries')

                varValue=Simulink.Timeseries();
                varValue.Data=Vals;
                varValue.Time=Time;
                varValue.BlockPath=obj.repoUtil.getMetaDataByName(dbId,'signalBlockPath');

                portIndex=obj.repoUtil.getMetaDataByName(dbId,'signalPortIndex');
                if isempty(portIndex)
                    varValue.PortIndex=portIndex;
                else
                    varValue.PortIndex=[];
                end

                varValue.SignalName=obj.repoUtil.getMetaDataByName(dbId,'signalSignalName');
                varValue.ParentName=obj.repoUtil.getMetaDataByName(dbId,'signalParentName');
            end


            varValue.Name=obj.repoUtil.getMetaDataByName(dbId,'TSName');

            if isa(varValue,'timeseries')
                varValue.DataInfo.Units=obj.repoUtil.getUnit(dbId);
            end
            varValue.DataInfo.Interpolation=tsdata.interpolation(obj.repoUtil.getInterpMethod(dbId));

            if~isempty(varargin)&&isstruct(varargin{1})

                varValue.Time=varargin{1}.Time;
                varValue.Data=varargin{1}.Data;
            end
        end



        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)%#ok<INUSL>

            signalType=getMetaDataByName(obj.repoUtil,dbId,'SignalType');

            IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));


            if IS_COMPLEX
                childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);
                editPropStruct(1).id=int32(childSignals(1));
                editPropStruct(2).id=int32(childSignals(1));
            end
        end


        function jsonStruct=jsonStructFromID(obj,dbId)
            jsonStruct={};
            metaStruct=obj.repoUtil.getMetaDataStructure(dbId);


            isReal=strcmpi(metaStruct.SignalType,getString(message('sl_sta_general:common:Real')));






















            parentID=obj.repoUtil.getParent(dbId);

            if parentID==0
                parentID='input';
            end

            if isReal

                itemStruct.Name=getSignalLabel(obj.repoUtil,dbId);

                if isempty(metaStruct.ParentName)
                    metaStruct.ParentName=[];
                end

                itemStruct.ParentName=metaStruct.ParentName;
                itemStruct.ParentID=parentID;

                itemStruct.DataSource=metaStruct.FileName;
                itemStruct.FullDataSource=metaStruct.LastKnownFullFile;
                itemStruct.Icon='signal.gif';
                itemStruct.Type='Signal';


                itemStruct.isEnum=metaStruct.isEnum;
                itemStruct.isString=metaStruct.isString;

                itemStruct.MinTime=metaStruct.MinTime;
                itemStruct.MaxTime=metaStruct.MaxTime;
                itemStruct.MinData='[]';
                itemStruct.MaxData='[]';
                itemStruct.Units=obj.repoUtil.getUnit(dbId);

                itemStruct.DataType=metaStruct.DataType;

                if isa(itemStruct.Units,'Simulink.SimulationData.Unit')
                    itemStruct.Units=itemStruct.Units.Name;
                end

                itemStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);

                if isfield(metaStruct,'BlockPath')

                    itemStruct.BlockPath={metaStruct.BlockPath};
                else
                    itemStruct.BlockPath=[];
                end


                if isfield(metaStruct,'signalBlockPath')
                    itemStruct.BlockPath=metaStruct.signalBlockPath;
                end

                itemStruct.TreeOrder=metaStruct.TreeOrder;
                itemStruct.ID=dbId;


                itemStruct.ExternalSourceID=0;

                jsonStruct{1}=itemStruct;

            else
                containerStruct.Name=getSignalLabel(obj.repoUtil,dbId);
                if isempty(metaStruct.ParentName)
                    containerStruct.ParentName=[];
                else
                    containerStruct.ParentName=metaStruct.ParentName;
                end
                containerStruct.ID=dbId;
                containerStruct.ParentID=parentID;
                containerStruct.DataSource=metaStruct.FileName;
                containerStruct.FullDataSource=metaStruct.LastKnownFullFile;

                containerStruct.Icon='signal.gif';

                containerStruct.Type='ComplexTimeSeries';

                containerStruct.TreeOrder=metaStruct.TreeOrder;
                containerStruct.ID=dbId;

                if isfield(metaStruct,'BlockPath')

                    containerStruct.BlockPath={metaStruct.BlockPath};
                else
                    containerStruct.BlockPath=[];
                end


                if isfield(metaStruct,'signalBlockPath')
                    containerStruct.BlockPath=metaStruct.signalBlockPath;
                end


                containerStruct.ExternalSourceID=0;

                realStruct.ParentName=[];
                realStruct.ParentID=dbId;
                realStruct.DataSource=containerStruct.DataSource;
                realStruct.FullDataSource=containerStruct.FullDataSource;


                realStruct.Icon='signal.gif';
                realStruct.Type='Signal';

                realStruct.MinTime=metaStruct.MinTime;
                realStruct.MaxTime=metaStruct.MaxTime;
                realStruct.DataType=metaStruct.DataType;


                realStruct.MinData='[]';
                realStruct.MaxData='[]';


                containerStruct.Units='';
                containerStruct.Interpolation='linear';

                containerStruct.isString=metaStruct.isString;
                containerStruct.DataType=metaStruct.DataType;

                boolInfo=strcmpi(metaStruct.DataType,'boolean')||strcmpi(metaStruct.DataType,'logical');
                if contains(metaStruct.dataformat,'timeseries')
                    containerStruct.Units=obj.repoUtil.getUnit(dbId);

                    if boolInfo
                        containerStruct.Interpolation='zoh';
                    else
                        containerStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);
                    end
                elseif contains(metaStruct.dataformat,'Simulink.Timeseries')

                    if boolInfo||containerStruct.isString
                        containerStruct.Interpolation='zoh';
                    else
                        containerStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);
                    end
                end

                imagStruct=realStruct;
                realStruct.Units=containerStruct.Units;
                imagStruct.Units=containerStruct.Units;

                realStruct.BlockPath=containerStruct.BlockPath;
                imagStruct.BlockPath=containerStruct.BlockPath;

                realStruct.Interpolation=containerStruct.Interpolation;
                imagStruct.Interpolation=containerStruct.Interpolation;

                realStruct.isString=containerStruct.isString;
                imagStruct.isString=containerStruct.isString;
                imagStruct.DataType=containerStruct.DataType;


                containerStruct.TreeOrder=metaStruct.TreeOrder;
                realStruct.TreeOrder=metaStruct.TreeOrder+1;
                imagStruct.TreeOrder=metaStruct.TreeOrder+2;

                childIDs=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

                realStruct.ID=childIDs(1);
                imagStruct.ID=childIDs(2);

                realStruct.Name=getSignalLabel(obj.repoUtil,childIDs(1));
                imagStruct.Name=getSignalLabel(obj.repoUtil,childIDs(2));%#ok<STRNU>

                containerStruct.MinTime=realStruct.MinTime;
                containerStruct.MaxTime=realStruct.MaxTime;

                containerStruct.ComplexID=containerStruct.ID;
                containerStruct.ID=childIDs(1);
                containerStruct.ImagID=childIDs(2);

                jsonStruct={containerStruct};
            end


        end


        function plottableIDs=getPlottableSignalIDs(obj,rootSigID)

            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if WAS_REAL
                plottableIDs=rootSigID;
            else
                plottableIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
            end
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(obj,rootSigID)

            propertyUpdateIDs=getPlottableSignalIDs(obj,rootSigID);
            propertyUpdateIDs=propertyUpdateIDs(1);

        end


        function dataToSet=getDataForSetByID(obj,signalIDForData)




            varout=obj.extractValue(signalIDForData);
            dataToSet.Time=varout.Time;
            dataToSet.Data=varout.Data;
        end
    end

    methods(Access='protected')


        function ts=contstructTimeseries(~,Vals,Time)

            if isStringScalar(Vals)
                ts=timeseries;
                ts.Time=Time;
                ts.Data=Vals;
            else
                ts=timeseries(Vals,Time);
            end

        end
    end
end


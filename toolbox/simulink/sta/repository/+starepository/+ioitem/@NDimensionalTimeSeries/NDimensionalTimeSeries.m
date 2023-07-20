classdef NDimensionalTimeSeries<starepository.ioitem.Container&starepository.ioitem.DataSetChild&starepository.ioitem.TimeSeriesDataDump



    properties

        isLogged=false;
BlockPath
BlockPathType
SubPath
PortType
PortIndex
LoggedName
SignalName
SLParentName
        isSLTimeseries=false;
        TSName='';
Data
        TSUnits='';
        Interpolation='';
        isDataArrayColumn=0;
    end

    methods


        function obj=NDimensionalTimeSeries(ListItems,BusName,Data)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);
            obj.Data=Data;


            if~isempty(obj.Data)
                obj.isEnum=isenum(obj.Data.Data);
                obj.isBool=islogical(obj.Data.Data);
                obj.isString=isstring(obj.Data.Data);
            end

        end


        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)

            obj.isEnum=isenum(obj.Data.Data);
            obj.isBool=islogical(obj.Data.Data);
            obj.isString=isstring(obj.Data.Data);


            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;


            jsonStruct=ioitem2Structure(obj);



            sigID=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;

            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
            end

            jsonStruct=generateAllJson(obj,sigID,jsonStruct,fileName);

        end


        function jsonStruct=generateAllJson(obj,parentID,parentSigStruct,dataSource)

            [~,dsFileOnly,dsExt]=fileparts(dataSource);


            parentSigStruct{1}.DataSource=[dsFileOnly,dsExt];
            tempStruct=parentSigStruct{1};
            kids=obj.sdiRepo.getSignalChildren(parentID);


            IS_COMPLEX=~isreal(obj.Data.Data)&&~isstring(obj.Data.Data);
            childStruct=cell(1,length(kids));

            treeOrderCount=2;
            kidCount=1;

            siblingOrderCount=1;
            for kKid=1:length(kids)


                staLabel=overrideLabel(obj,kids(kKid));

                tempStruct.Name=staLabel;

                if IS_COMPLEX

                    tempStruct.Type='ComplexTimeSeries';
                else

                    tempStruct.Type='Signal';
                end


                tempStruct.ParentID=parentSigStruct{1}.ID;
                tempStruct.ID=kids(kKid);
                tempStruct.isEnum=parentSigStruct{1}.isEnum;
                tempStruct.DataType=obj.Properties.DataType;
                tempStruct.TreeOrder=treeOrderCount;
                tempStruct.isString=parentSigStruct{1}.isString;

                treeOrderCount=treeOrderCount+1;

                childStruct{kidCount}=tempStruct;
                kidCount=kidCount+1;









                sig=Simulink.sdi.getSignal(kids(kKid));
                metaData_struct=sig.getMetaData();
                metaData_struct.DataType=obj.Properties.DataType;
                metaData_struct.SignalType=obj.Properties.SignalType;
                metaData_struct.SampleTime=obj.Properties.SampleTime;
                metaData_struct.Dimension='[1 1]';

                if obj.isFixDT

                    metaData_struct.isFixDT=1;

                end


                if~isempty(obj.TSUnits)&&~obj.isSLTimeseries

                    unitStr=getUnits(obj,obj.TSUnits);
                    obj.sdiRepo.setUnit(kids(kKid),unitStr);
                end


                sig.setMetaData(metaData_struct);

                if IS_COMPLEX


                    tempChildReal=tempStruct;
                    tempChildImaginary=tempStruct;

                    gKids=obj.sdiRepo.getSignalChildren(kids(kKid));
                    sig2=Simulink.sdi.getSignal(gKids(1));
                    sig3=Simulink.sdi.getSignal(gKids(2));


                    metaData_struct=sig.getMetaData();



                    gKid_metaData_struct=sig2.getMetaData();



                    metaData_struct.NDimIdxStr=gKid_metaData_struct.NDimIdxStr;
                    sig.setMetaData(metaData_struct);



                    realLabel=getString(message('simulation_data_repository:sdr:RealSignalName',tempStruct.Name));
                    imgLabel=getString(message('simulation_data_repository:sdr:ImagSignalName',tempStruct.Name));


                    tempChildReal.Name=realLabel;
                    tempChildReal.Type='Signal';
                    tempChildReal.ParentID=kids(kKid);
                    tempChildReal.ID=gKids(1);
                    childStruct{kidCount-1}.ComplexID=childStruct{kidCount-1}.ID;
                    childStruct{kidCount-1}.ID=gKids(1);


                    tempChildImaginary.Name=imgLabel;
                    tempChildImaginary.Type='Signal';
                    tempChildImaginary.ParentID=kids(kKid);
                    tempChildImaginary.ID=gKids(2);
                    childStruct{kidCount-1}.ImagID=gKids(2);


                    sibOrder=sta.ChildOrder();
                    sibOrder.ParentID=kids(kKid);
                    sibOrder.ChildID=gKids(1);
                    sibOrder.SignalOrder=siblingOrderCount;
                    siblingOrderCount=siblingOrderCount+1;

                    sibOrderImg=sta.ChildOrder();
                    sibOrderImg.ParentID=kids(kKid);
                    sibOrderImg.ChildID=gKids(2);
                    sibOrderImg.SignalOrder=siblingOrderCount;
                    siblingOrderCount=siblingOrderCount+1;


                    metaData_structRealandImg=sig2.getMetaData();
                    metaData_structRealandImg.DataType=obj.Properties.DataType;
                    metaData_structRealandImg.SignalType=obj.Properties.SignalType;
                    metaData_structRealandImg.SampleTime=obj.Properties.SampleTime;
                    metaData_structRealandImg.Dimension='[1 1]';

                    if obj.isFixDT

                        metaData_structRealandImg.isFixDT=obj.isFixDT;
                    end


                    if~isempty(obj.TSUnits)&&~obj.isSLTimeseries
                        unitStr=getUnits(obj,obj.TSUnits);
                        obj.sdiRepo.setUnit(gKids(1),unitStr);
                        obj.sdiRepo.setUnit(gKids(2),unitStr);
                    end

                    sig2.setMetaData(metaData_structRealandImg);
                    sig3.setMetaData(metaData_structRealandImg);

                else

                    sibOrder=sta.ChildOrder();
                    sibOrder.ParentID=parentSigStruct{1}.ID;
                    sibOrder.ChildID=kids(kKid);
                    sibOrder.SignalOrder=siblingOrderCount;

                    siblingOrderCount=siblingOrderCount+1;
                end

            end

            jsonStruct=[parentSigStruct,childStruct];

        end


        function setFixedPointProperties(obj)

            obj.isFixDT=false;
            if~isempty(strfind(obj.Properties.DataType,'fixdt'))

                obj.isFixDT=true;








                isIntegerType=(obj.Data.Data.Slope==1)&&(obj.Data.Data.Bias==0);
                isStoredInt8=isIntegerType&&obj.Data.Data.WordLength==8;
                isStoredInt16=isIntegerType&&obj.Data.Data.WordLength==16;
                isStoredInt32=isIntegerType&&obj.Data.Data.WordLength==32;
                isStoredInt64=isIntegerType&&obj.Data.Data.WordLength==64;

                isSignedStoredInt8=isStoredInt8&&obj.Data.Data.Signed;
                isUnSignedStoredInt8=isStoredInt8&&~obj.Data.Data.Signed;
                isSignedStoredInt16=isStoredInt16&&obj.Data.Data.Signed;
                isUnSignedStoredInt16=isStoredInt16&&~obj.Data.Data.Signed;
                isSignedStoredInt32=isStoredInt32&&obj.Data.Data.Signed;
                isUnSignedStoredInt32=isStoredInt32&&~obj.Data.Data.Signed;
                isSignedStoredInt64=isStoredInt64&&obj.Data.Data.Signed;
                isUnSignedStoredInt64=isStoredInt64&&~obj.Data.Data.Signed;




                if obj.Data.Data.isdouble

                    obj.isFixDTOverride=true;
                    obj.overrideType='double';
                    return;
                elseif obj.Data.Data.issingle

                    obj.isFixDTOverride=true;
                    obj.overrideType='single';
                    return;
                elseif obj.Data.Data.isboolean

                    obj.isFixDTOverride=true;
                    obj.overrideType='boolean';
                    return;
                elseif isSignedStoredInt8

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isSignedStoredInt16

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isSignedStoredInt32

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isSignedStoredInt64

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isUnSignedStoredInt8

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isUnSignedStoredInt16

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isUnSignedStoredInt32

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                elseif isUnSignedStoredInt64

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;
                end
            end
        end


        function numSignals=getNumSignals(~)

            numSignals=1;

        end

    end


    methods(Access='protected')


        function getDataInCallWS(~,evalStr,idx)
            evalin('caller',sprintf(evalStr,idx));
        end


        function staLabel=overrideLabel(obj,id)


            staLabel=obj.sdiRepo.getSignalLabel(id);




            staLabel=strrep(staLabel,')',',1,:)');

            NDimIdxStr=obj.staRepoUtil.getMetaDataByName(id,'NDimIdxStr');
            idxOpenParenth=strfind(staLabel,'(');
            idxParen=idxOpenParenth(end);
            staLabel=[staLabel(1:idxParen-1),NDimIdxStr];







        end

    end

end


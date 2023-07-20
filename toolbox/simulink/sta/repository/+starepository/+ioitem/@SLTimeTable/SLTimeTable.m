classdef SLTimeTable<starepository.ioitem.Item...
    &starepository.ioitem.DataSetChild...
    &starepository.ioitem.TimeTableDataDump




    properties
Data
        isLogged=false
        isLoggedState=false


BlockPath
SubPath
BlockPathType
    end



    methods


        function obj=SLTimeTable()
            obj=obj@starepository.ioitem.Item;
            obj=obj@starepository.ioitem.DataSetChild;
            obj.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end




        function isitemequalflag=isItemEqual(obj,aItem)


            isitemequalflag=false;

        end

        function flag=isBus(~)
            flag=false;
        end


        function itemstruct=ioitem2Structure(obj)







            if strcmp(obj.Properties.SignalType,getString(message('sl_sta_general:common:Real')))

                itemName=obj.Name;

                if isempty(obj.Name)&&~ischar(obj.Name)
                    itemName='';
                end
                itemstruct.Name=itemName;

                itemstruct.ParentName=obj.ParentName;
                itemstruct.ParentID='input';
                itemstruct.DataSource=obj.FileName;
                itemstruct.FullDataSource=obj.LastKnownFullFile;
                if~isempty(obj.ParentID)
                    itemstruct.ParentID=obj.ParentID;
                end

                [~,name,ext]=fileparts(obj.UIProperties.Icon);
                itemstruct.Icon=[name,ext];
                itemstruct.Type=strrep(class(obj),'starepository.ioitem.','');

                timeAndDataVals=getTimeAndDataVals(obj);

                obj.isEnum=isenum(timeAndDataVals.Data);
                obj.isBool=islogical(timeAndDataVals.Data);
                obj.isString=isstring(timeAndDataVals.Data);
                itemstruct.isString=obj.isString;
                itemstruct.isEnum=obj.isEnum;
                itemstruct.DataType=obj.Properties.DataType;
                if~isempty(timeAndDataVals.Time)
                    itemstruct.MinTime=timeAndDataVals.Time(1);
                    itemstruct.MaxTime=timeAndDataVals.Time(end);

                    if~isreal(timeAndDataVals.Data)&&isinteger(timeAndDataVals.Data)||isstring(timeAndDataVals.Data)

                        itemstruct.MinData=[];
                        itemstruct.MaxData=[];
                    else
                        itemstruct.MinData='[]';
                        itemstruct.MaxData='[]';
                    end
                else
                    itemstruct.MinTime=[];
                    itemstruct.MaxTime=[];
                    itemstruct.MinData=[];
                    itemstruct.MaxData=[];
                end


                itemstruct.Units='';
                itemstruct.BlockPath=obj.BlockPath;

                if isempty(itemstruct.BlockPath)
                    itemstruct.BlockPath=[];
                end
                itemstruct.Units=getUnit(obj);

                enumInfo=[];
                IS_STRING=isstring(timeAndDataVals.Data);

                if~isstring(timeAndDataVals.Data)
                    enumInfo=enumeration(timeAndDataVals.Data);
                end
                boolInfo=islogical(timeAndDataVals.Data);

                if~isempty(enumInfo)||boolInfo||IS_STRING
                    itemstruct.Interpolation='zoh';
                else
                    itemstruct.Interpolation=getInterpolation(obj);
                end

                if~isempty(enumInfo)
                    itemstruct.isEnum=true;
                end




                itemstruct.TreeOrder=1;

                itemstruct={itemstruct};
            else

                itemstruct=initJsonForComplex(obj);

            end

        end








        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)

            timeAndDataVals=getTimeAndDataVals(obj);

            obj.isEnum=~isempty(timeAndDataVals.Data)&&isenum(timeAndDataVals.Data);
            obj.isBool=~isempty(timeAndDataVals.Data)&&islogical(timeAndDataVals.Data);


            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;

            if~isempty(timeAndDataVals.Data)&&...
                (~isreal(timeAndDataVals.Data)&&~isstring(timeAndDataVals.Data))
                jsonStruct=initJsonForComplex(obj);
            else
                jsonStruct=ioitem2Structure(obj);
            end

            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
                obj.RepoParentID=parentSigID;
            end

            [sigID,leafSigs,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;
            jsonStruct{1}.MinTime=runTimeRange.Start;
            jsonStruct{1}.MaxTime=runTimeRange.Stop;

            ONE_LEAF=length(leafSigs)==1;

            IS_SIG=false;

            if~isempty(leafSigs)
                IS_SIG=leafSigs(1)==sigID;
            end

            ONE_AND_SAME=ONE_LEAF&&IS_SIG;


            if~isempty(leafSigs)&&~ONE_AND_SAME


                if strcmp(obj.Properties.Dimension,'1')

                    jsonStruct{1}.ID=leafSigs(1);
                    jsonStruct{1}.ComplexID=sigID;
                    jsonStruct{1}.ImagID=leafSigs(2);
                    tmpJson{1}=jsonStruct{1};
                    jsonStruct=tmpJson;
                else



                    jsonStruct=ioitem2Structure(obj);
                    if parentSigID~=0
                        jsonStruct{1}.ParentID=parentSigID;
                        obj.RepoParentID=parentSigID;
                    end
                    jsonStruct{1}.isEnum=obj.isEnum;
                    jsonStruct{1}.ID=sigID;
                    jsonStruct{1}.Type='NonScalarSLTimeTable';
                    jsonStruct{1}.DataType=obj.Properties.DataType;
                    jsonStruct=generateAllJson(obj,sigID,{jsonStruct{1}},fileName);

                end

            end


        end







        function setFixedPointProperties(obj)
            obj.isFixDT=false;
            if~isempty(strfind(obj.Properties.DataType,'fixdt'))
                obj.isFixDT=true;

                timeAndDataVals=getTimeAndDataVals(obj);









                isIntegerType=(timeAndDataVals.Data.Slope==1)&&(timeAndDataVals.Data.Bias==0);
                isStoredInt8=isIntegerType&&timeAndDataVals.Data.WordLength==8;
                isStoredInt16=isIntegerType&&timeAndDataVals.Data.WordLength==16;
                isStoredInt32=isIntegerType&&timeAndDataVals.Data.WordLength==32;

                isSignedStoredInt8=isStoredInt8&&timeAndDataVals.Data.Signed;
                isUnSignedStoredInt8=isStoredInt8&&~timeAndDataVals.Data.Signed;
                isSignedStoredInt16=isStoredInt16&&timeAndDataVals.Data.Signed;
                isUnSignedStoredInt16=isStoredInt16&&~timeAndDataVals.Data.Signed;
                isSignedStoredInt32=isStoredInt32&&timeAndDataVals.Data.Signed;
                isUnSignedStoredInt32=isStoredInt32&&~timeAndDataVals.Data.Signed;




                if timeAndDataVals.Data.isdouble

                    obj.isFixDTOverride=true;
                    obj.overrideType='double';
                    return;
                elseif timeAndDataVals.Data.issingle

                    obj.isFixDTOverride=true;
                    obj.overrideType='single';
                    return;
                elseif timeAndDataVals.Data.isboolean

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

                end
            end
        end


        function jsonStruct=generateAllJson(obj,parentID,parentSigStruct,dataSource)

            [~,dsFileOnly,dsExt]=fileparts(dataSource);


            parentSigStruct{1}.DataSource=[dsFileOnly,dsExt];
            tempStruct=parentSigStruct{1};
            kids=obj.sdiRepo.getSignalChildren(parentID);

            timeAndDataVals=getTimeAndDataVals(obj);

            IS_COMPLEX=~isreal(timeAndDataVals.Data)&&~isstring(timeAndDataVals.Data);


            childStruct=cell(1,length(kids));

            treeOrderCount=2;
            kidCount=1;

            [~,name,ext]=fileparts(obj.UIProperties.Icon);
            siblingOrderCount=1;
            for kKid=1:length(kids)


                staLabel=overrideLabel(obj,kids(kKid));

                tempStruct.Name=staLabel;

                if IS_COMPLEX

                    tempStruct.Type='ComplexTimeSeries';
                else

                    tempStruct.Type='SLTimeTable';
                end


                tempStruct.ParentID=parentSigStruct{1}.ID;
                tempStruct.ID=kids(kKid);
                tempStruct.isEnum=parentSigStruct{1}.isEnum;
                tempStruct.DataType=obj.Properties.DataType;
                tempStruct.TreeOrder=treeOrderCount;
                treeOrderCount=treeOrderCount+1;

                childStruct{kidCount}=tempStruct;
                kidCount=kidCount+1;









                sig=Simulink.sdi.getSignal(kids(kKid));
                metaData_struct=sig.getMetaData();
                metaData_struct.DataType=obj.Properties.DataType;
                metaData_struct.SignalType=obj.Properties.SignalType;
                metaData_struct.SampleTime=obj.Properties.SampleTime;
                metaData_struct.dataformat='sl_timetable';
                metaData_struct.Dimension='[1 1]';

                if obj.isFixDT

                    metaData_struct.isFixDT=1;

                end


                if~isempty(getUnit(obj))

                    unitStr=getUnit(obj);
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
                    sig2.setMetaData(metaData_struct);



                    realLabel=getString(message('simulation_data_repository:sdr:RealSignalName',tempStruct.Name));
                    imgLabel=getString(message('simulation_data_repository:sdr:ImagSignalName',tempStruct.Name));


                    tempChildReal.Name=realLabel;
                    tempChildReal.Type='SLTimeTable';
                    tempChildReal.ParentID=kids(kKid);
                    tempChildReal.ID=gKids(1);
                    tempChildReal.TreeOrder=treeOrderCount;

                    childStruct{kidCount-1}.ComplexID=childStruct{kidCount-1}.ID;
                    childStruct{kidCount-1}.ID=gKids(1);


                    tempChildImaginary.Name=imgLabel;
                    tempChildImaginary.Type='SLTimeTable';
                    tempChildImaginary.ParentID=kids(kKid);
                    tempChildImaginary.ID=gKids(2);
                    tempChildImaginary.TreeOrder=treeOrderCount;

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


                    if~isempty(getUnit(obj))
                        unitStr=getUnit(obj);
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


        function numSignals=getNumSignals(obj)

            dataSize=size(obj.Data.(obj.Data.Properties.VariableNames{1}));
            if length(dataSize)>2

                numSignals=prod(dataSize(2:end));
            else
                if any(dataSize==1)
                    numSignals=1;
                else
                    numSignals=dataSize(2);
                end
            end

        end
    end

    methods(Access='protected')


        function itemstruct=initJsonForComplex(obj)

            itemstruct={};

            itemName=obj.Name;

            if isempty(obj.Name)&&~ischar(obj.Name)
                itemName='';
            end

            containerStruct.Name=itemName;
            containerStruct.ParentName=obj.ParentName;
            containerStruct.ParentID='input';
            containerStruct.DataSource=obj.FileName;
            containerStruct.FullDataSource=obj.LastKnownFullFile;
            if~isempty(obj.ParentID)
                containerStruct.ParentID=obj.ParentID;
            end

            [~,name,ext]=fileparts(obj.UIProperties.Icon);
            containerStruct.Icon=[name,ext];

            containerStruct.Type='ComplexTimeSeries';

            timeAndDataVals=getTimeAndDataVals(obj);







            realStruct.ParentName=obj.ParentName;
            realStruct.ParentID=[];
            realStruct.DataSource=obj.FileName;
            realStruct.FullDataSource=obj.LastKnownFullFile;

            [~,name,ext]=fileparts(obj.UIProperties.Icon);
            realStruct.Icon=[name,ext];
            realStruct.Type=strrep(class(obj),'starepository.ioitem.','');

            realStruct.MinTime=timeAndDataVals.Time(1);
            realStruct.MaxTime=timeAndDataVals.Time(end);

            if~isstring(timeAndDataVals.Data)

                realStruct.MinData='[]';
                realStruct.MaxData='[]';
            else
                realStruct.MinData=[];
                realStruct.MaxData=[];
            end






            imagStruct.ParentName=obj.ParentName;
            imagStruct.ParentID=[];
            imagStruct.DataSource=obj.FileName;
            imagStruct.FullDataSource=obj.LastKnownFullFile;

            [~,name,ext]=fileparts(obj.UIProperties.Icon);
            imagStruct.Icon=[name,ext];
            imagStruct.Type=strrep(class(obj),'starepository.ioitem.','');

            imagStruct.MinTime=timeAndDataVals.Time(1);
            imagStruct.MaxTime=timeAndDataVals.Time(end);




            imagStruct.MinData='[]';
            imagStruct.MaxData='[]';



            containerStruct.Units='';
            containerStruct.Interpolation='linear';
            containerStruct.BlockPath=obj.BlockPath;

            containerStruct.Units=getUnit(obj);
            enumInfo=enumeration(timeAndDataVals.Data);
            boolInfo=islogical(timeAndDataVals.Data);
            if~isempty(enumInfo)||boolInfo
                containerStruct.Interpolation='zoh';
            else
                containerStruct.Interpolation='linear';
            end


            realStruct.Units=containerStruct.Units;
            imagStruct.Units=containerStruct.Units;

            realStruct.BlockPath=containerStruct.BlockPath;
            imagStruct.BlockPath=containerStruct.BlockPath;

            realStruct.Interpolation=containerStruct.Interpolation;
            imagStruct.Interpolation=containerStruct.Interpolation;

            realStruct.isString=obj.isString;
            imagStruct.isString=obj.isString;
            containerStruct.isString=obj.isString;


            containerStruct.TreeOrder=1;
            containerStruct.MinTime=realStruct.MinTime;
            containerStruct.MaxTime=realStruct.MaxTime;

            containerStruct.DataType=obj.Properties.DataType;
            realStruct.DataType=obj.Properties.DataType;
            imagStruct.DataType=obj.Properties.DataType;

            realStruct.TreeOrder=1;
            imagStruct.TreeOrder=1;

            itemstruct=[itemstruct,containerStruct,realStruct,imagStruct];

        end


        function staLabel=overrideLabel(obj,id)


            staLabel=obj.sdiRepo.getSignalLabel(id);




            staLabel(end:end+2)=',:)';

            NDimIdxStr=obj.staRepoUtil.getMetaDataByName(id,'NDimIdxStr');
            idxOpenParenth=strfind(staLabel,'(');
            idxParen=idxOpenParenth(end);
            staLabel=[staLabel(1:idxParen-1),NDimIdxStr];







        end
    end

end


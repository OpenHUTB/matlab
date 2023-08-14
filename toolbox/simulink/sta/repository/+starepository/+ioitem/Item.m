classdef Item<staItem.Item






    properties(SetAccess=public,GetAccess=public)

ID
isFixDT
        isFixDTOverride=false
overrideType
        isEnum=false;
        isBool=false;
        isString=false;
FileName
OnFileIndex

LastKnownFullFile

RepoParentID
        DataSetIdx=1;
ParentName
        ParentID=[]

FileModifiedDate
    end

    properties(SetAccess=private)





        Selected=false;



    end

    properties(Access='protected')

RepoDataType
RepoDims
RepoSignalType
RepoIsDiscrete

SignalSource
RepoSignal

itemstruct
        ParentSignal=[]
        sdiRepo=sdi.Repository(true);
hQueue


staRepoUtil
    end

    properties
Name
Properties
UIProperties
        isDataSetElement=false

BlockDataProperties
        isStructSignal=false
    end

    events
ParameterChanged
    end

    methods(Abstract)


        isBus(obj)


        isItemEqual(obj)

    end





    methods


        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)


            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;

            if~isa(obj,'starepository.ioitem.EmptyLoggedVariant')
                tsDataVals=obj.Data.Data;
                istsDataValEmpty=isempty(tsDataVals);
                obj.isEnum=~istsDataValEmpty&&isenum(tsDataVals);
                obj.isBool=~istsDataValEmpty&&islogical(tsDataVals);
                obj.isString=~istsDataValEmpty&&isstring(tsDataVals);

                if~istsDataValEmpty&&(~isreal(tsDataVals)&&isnumeric(tsDataVals))
                    jsonStruct=initJsonForComplex(obj);
                else
                    jsonStruct=ioitem2Structure(obj);
                end


            else
                obj.isEnum=false;
                obj.isBool=false;
                jsonStruct=ioitem2Structure(obj);
            end

            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
                obj.RepoParentID=parentSigID;
            end

            [sigID,leafSigs,timeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;
            jsonStruct{1}.MinTime=timeRange.Start;
            jsonStruct{1}.MaxTime=timeRange.Stop;
            ONE_LEAF=length(leafSigs)==1;

            IS_SIG=false;

            if~isempty(leafSigs)
                IS_SIG=leafSigs(1)==sigID;
            end

            ONE_AND_SAME=ONE_LEAF&&IS_SIG;

            if~isempty(leafSigs)&&~ONE_AND_SAME
                jsonStruct{1}.ID=leafSigs(1);
                jsonStruct{1}.ComplexID=sigID;
                if length(leafSigs)==2
                    jsonStruct{1}.ImagID=leafSigs(2);
                end
            end
        end

    end

    methods(Access='protected')
        function obj=Item
            obj.ID=matlab.lang.internal.uuid;
            obj.staRepoUtil=starepository.RepositoryUtility(obj.sdiRepo);
        end


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


            containerStruct.Units='';
            containerStruct.Interpolation='linear';
            containerStruct.BlockPath=obj.BlockPath;
            containerStruct.DataType=obj.Properties.DataType;
            enumInfo=[];

            tsDataVals=obj.Data.Data;
            IS_STRING=isstring(tsDataVals);
            if isa(obj.Data,'timeseries')
                containerStruct.Units=getUnits(obj,obj.Data.DataInfo.Units);

                if~IS_STRING
                    enumInfo=enumeration(tsDataVals);
                end

                boolInfo=islogical(tsDataVals);
                if~isempty(enumInfo)||boolInfo
                    containerStruct.Interpolation='zoh';
                else
                    containerStruct.Interpolation=obj.Data.getinterpmethod;
                end
            elseif isa(obj.Data,'Simulink.Timeseries')

                if~IS_STRING
                    enumInfo=enumeration(tsDataVals);
                end

                boolInfo=islogical(tsDataVals);
                if~isempty(enumInfo)||boolInfo||IS_STRING
                    containerStruct.Interpolation='zoh';
                else
                    containerStruct.Interpolation=obj.Data.getInterpMethod;
                end
            end


            containerStruct.isString=obj.isString;


            containerStruct.TreeOrder=1;


            itemstruct=[itemstruct,containerStruct];
        end
    end

    methods

        function setName(obj,Name)
            obj.Name=Name;
        end

        function setParentName(obj,ParentName)
            obj.ParentName=ParentName;
        end

        function setParentID(obj,ParentID)


            obj.ParentID=ParentID;
        end


        function parentid=getParentID(obj)
            parentid=obj.ParentID;
        end

        function FullName=getFullName(obj)
            if~isempty(obj.ParentName)
                FullName=[obj.ParentName,'.',obj.Name];
            else
                FullName=obj.Name;
            end
        end

        function FullName=getDisplayName(obj)


            FullName=obj.getFullName;

        end

        function setSelected(obj,state)
            obj.Selected=state;
        end


        function itemstruct=ioitem2Structure(obj)












            isReal=isa(obj.Properties,'starepository.ioitem.BusProperties')||...
            isa(obj.Properties,'starepository.ioitem.ArrayOfBusProperties')||...
            isa(obj.Properties,'starepository.ioitem.SaveToWorkspaceFormatArrayProperties')||...
            isa(obj.Properties,'starepository.ioitem.FunctionCallProperties')||...
            obj.isBus;


            if isReal||strcmp(obj.Properties.SignalType,getString(message('sl_sta_general:common:Real')))

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

                itemstruct.Icon=obj.UIProperties.Icon;
                itemstruct.Type=strrep(class(obj),'starepository.ioitem.','');

                itemstruct.isEnum=obj.isEnum;
                itemstruct.isString=obj.isString;
                enumInfo=[];
                if~obj.isBus||strcmp(itemstruct.Type,'NDimensionalTimeSeries')

                    tsDataVals=obj.Data.Data;
                    tsTimeVals=obj.Data.Time;

                    if~isempty(tsTimeVals)
                        itemstruct.MinTime=tsTimeVals(1);
                        itemstruct.MaxTime=tsTimeVals(end);

                        if~isreal(tsDataVals)&&isinteger(tsDataVals)||isstring(tsDataVals)

                            itemstruct.MinData='[]';
                            itemstruct.MaxData='[]';
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
                    itemstruct.Interpolation='linear';
                    itemstruct.BlockPath=obj.BlockPath;
                    itemstruct.DataType=obj.Properties.DataType;
                    if isa(obj.Data,'timeseries')


                        if isempty(itemstruct.BlockPath)
                            itemstruct.BlockPath=[];
                        end
                        itemstruct.Units=getUnits(obj,obj.Data.DataInfo.Units);

                        if~obj.isString
                            enumInfo=enumeration(tsDataVals);
                        end

                        boolInfo=islogical(tsDataVals);
                        if~isempty(enumInfo)||boolInfo||obj.isString
                            itemstruct.Interpolation='zoh';
                        else
                            itemstruct.Interpolation=obj.Data.getinterpmethod;

                            if isempty(itemstruct.Interpolation)
                                itemstruct.Interpolation=obj.Data.DataInfo.Interpolation.Name;
                            end
                        end

                        if~isempty(enumInfo)
                            itemstruct.isEnum=true;
                        end
                    elseif isa(obj.Data,'Simulink.Timeseries')

                        if~obj.isString
                            enumInfo=enumeration(tsDataVals);
                        end
                        boolInfo=islogical(tsDataVals);
                        if~isempty(enumInfo)||boolInfo||obj.isString
                            itemstruct.Interpolation='zoh';
                        else
                            itemstruct.Interpolation=obj.Data.getInterpMethod;
                        end

                        if~isempty(enumInfo)
                            itemstruct.isEnum=true;
                        end
                    end
                end

                itemstruct.isString=obj.isString;
                itemstruct.TreeOrder=1;

                itemstruct={itemstruct};
            else

                itemstruct=initJsonForComplex(obj);
            end

        end


        function numSignals=getNumSignals(obj)

            numSignals=0;


            if~obj.isBus
                numSignals=1;
            else


                for kItem=1:length(obj.ListItems)
                    numSignals=numSignals+obj.ListItems{kItem}.getNumSignals();
                end

            end

        end


        function val=filterJsonValues(~,val)

            if isreal(val)
                if isinf(val)
                    if val>0
                        val='Infinite';
                    else
                        val='-Infinite';
                    end
                end
            else
                val=num2str(val);
            end
        end


        function setUnits(obj,unitsVal)


            if ischar(unitsVal)
                obj.RepoSignal.addMetaData('UnitsIsObject',false);
                obj.sdiRepo.setUnit(obj.RepoSignal.ID,unitsVal);
            elseif isa(unitsVal,'Simulink.SimulationData.Unit')
                obj.RepoSignal.addMetaData('UnitsIsObject',true);
                obj.sdiRepo.setUnit(obj.RepoSignal.ID,unitsVal.Name);
            end

        end


        function outStr=getUnits(~,unitsVal)

            outStr='';

            if ischar(unitsVal)
                outStr=unitsVal;
                return;
            end

            if isa(unitsVal,'Simulink.SimulationData.Unit')
                outStr=unitsVal.Name;
            end
        end

    end

    methods(Sealed)

        function id=getID(obj)
            id=obj.ID;
        end
    end

end


classdef Signal<starepository.ioitem.Item&starepository.ioitem.DataSetChild&starepository.ioitem.TimeSeriesDataDump



    properties

Data
        isLogged=false
        isLoggedState=false
BlockPath
SubPath
BlockPathType
PortType
PortIndex
SignalName
SLParentName
LoggedName
        isDataArrayColumn=false
BlockName
        isSLTimeseries=false;
        TSName='';
        DataArrayColNum=1;

    end

    methods

        function obj=Signal()
            obj=obj@starepository.ioitem.Item;
            obj=obj@starepository.ioitem.DataSetChild;
            obj.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end

        function isitemequalflag=isItemEqual(obj,aItem)
            isitemequalflag=false;
            if aItem.isBus()
                return;
            end
            if~isequal(obj.Data,aItem.Data)
                return;
            end
            if~isequal(class(obj.Data),class(aItem.Data))
                return;
            end

            if~isequal(class(obj.Data.Data),class(aItem.Data.Data))
                return;
            end
            if~strcmp(obj.Name,aItem.Name)
                return;
            end
            isitemequalflag=true;

        end

        function flag=isBus(~)
            flag=false;
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
                elseif isUnSignedStoredInt64

                    obj.isFixDTOverride=true;
                    obj.overrideType=obj.Properties.DataType;
                    return;

                end
            end
        end

    end
end

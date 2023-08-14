classdef TimeSeriesItem<starepository.factory.ContainerItem





    properties

TimeSeries
TSValues
TSTime

Name


DefaultFactory


Item
    end

    methods
        function obj=TimeSeriesItem(Name,TimeSeries)

            if isStringScalar(Name)
                Name=char(Name);
            end
            obj=obj@starepository.factory.ContainerItem;
            obj.TimeSeries=TimeSeries;
            obj.Name=Name;
            obj.DefaultFactory=starepository.factory.DefaultItem(obj.Name);

            obj.TSValues=TimeSeries.Data;
            obj.TSTime=TimeSeries.Time;
        end

        function SignalItem=createSignalItemWithoutProperties(obj)


            dataDim=getTSDimension(obj.TimeSeries);

            aTs=obj.TimeSeries;
            aTsDataVals=aTs.Data;
            tsUnits=aTs.DataInfo.Units;
            if~isempty(aTs.DataInfo.Interpolation)
                interpName=aTs.DataInfo.Interpolation.Name;
            else
                interpName='linear';
            end

            IS_COMPLEX=~isreal(aTsDataVals);





            if length(dataDim)>2

                SignalItem=starepository.ioitem.NDimensionalTimeSeries([],obj.Name,obj.TimeSeries);
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
                SignalItem.TSUnits=tsUnits;
                SignalItem.Interpolation=interpName;
                obj.Item=SignalItem;

                return;
            end


            if obj.isMultiDimensional(dataDim)

                rowExtent=dataDim(1);
                if length(dataDim)>1
                    colExtent=dataDim(2);
                else


                    colExtent=1;
                end
                obj.ListItems=cell(1,rowExtent*colExtent);
                id=0;
                for r=1:rowExtent
                    for c=1:colExtent


                        if obj.TimeSeries.IsTimeFirst

                            if(colExtent>1)

                                itemname=sprintf('%s(:,%d,%d)',obj.Name,r,c);
                            else

                                itemname=sprintf('%s(:,%d)',obj.Name,r);
                            end

                            data=aTsDataVals(:,r,c);
                            data=squeeze(data);

                        else
                            itemname=sprintf('%s(%d,%d,:)',obj.Name,r,c);
                            data=aTsDataVals(r,c,:);
                            data=squeeze(data);

                        end
                        if length(obj.TimeSeries.Time)==1

                            itemname=sprintf('%s(%d,%d)',obj.Name,r,c);
                        end







                        if IS_COMPLEX&&isreal(data)
                            data=complex(data,data);
                        end

                        ts=createTimeSeries(data,obj.TimeSeries.Time);
                        theTsDataInfo=obj.TimeSeries.DataInfo;
                        ts.DataInfo.Units=theTsDataInfo.Units;
                        ts.DataInfo.Interpolation=theTsDataInfo.Interpolation;
                        itemFactory=starepository.factory.createSignalItemFactory(itemname,ts);
                        id=id+1;
                        item=itemFactory.createSignalItem();
                        obj.addListItem(item,id);
                        item.UIProperties.isDisplayParentName=false;


                    end
                end

                SignalItem=starepository.ioitem.MultiDimensionalTimeSeries(obj.ListItems,obj.Name);
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;

                SignalItem.TSUnits=tsUnits;
                SignalItem.TimeseriesName=obj.TimeSeries.Name;
                SignalItem.Interpolation=interpName;


            else
                SignalItem=obj.DefaultFactory.createSignalItemWithoutProperties();
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;

                SignalItem.Data=obj.TimeSeries;

                if isstring(aTsDataVals)
                    SignalItem.isString=true;
                end



            end
            SignalItem.TSName=obj.TimeSeries.Name;
            obj.Item=SignalItem;


        end


        function SignalItem=createSignalItemWithoutChildren(obj)
            dataDim=getTSDimension(obj.TimeSeries);

            aTs=obj.TimeSeries;
            tsUnits=aTs.DataInfo.Units;
            if~isempty(aTs.DataInfo.Interpolation)
                interpName=aTs.DataInfo.Interpolation.Name;
            else
                interpName='linear';
            end






            if length(dataDim)>2

                SignalItem=starepository.ioitem.NDimensionalTimeSeries([],obj.Name,obj.TimeSeries);
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
                SignalItem.TSUnits=tsUnits;
                SignalItem.Interpolation=interpName;

                if isstring(obj.TSValues)
                    SignalItem.isString=true;
                end

                obj.Item=SignalItem;

                return;
            end
            if obj.isMultiDimensional(dataDim)
                obj.ListItems=[];
                SignalItem=starepository.ioitem.MultiDimensionalTimeSeries(obj.ListItems,obj.Name);
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;

                SignalItem.TSUnits=tsUnits;
                SignalItem.Interpolation=interpName;
                if isstring(obj.TSValues)
                    SignalItem.isString=true;
                end
            else
                SignalItem=obj.DefaultFactory.createSignalItemWithoutProperties();
                SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;

                SignalItem.Data=obj.TimeSeries;
                if isstring(obj.TSValues)
                    SignalItem.isString=true;
                end
            end
            SignalItem.TSName=obj.TimeSeries.Name;

        end


        function signalproperty=buildProperties(obj)

            signalproperty=obj.DefaultFactory.buildProperties();

            tsDataVals=obj.TSValues;


            signalproperty.DataType=class(tsDataVals);
            var=tsDataVals;

            if isequal(signalproperty.DataType,'embedded.fi')

                numericType=var.numerictype;
                signalproperty.DataType=fixdt(numericType);

                if~license('test','Fixed_Point_Toolbox')
                    try



                        fi;
                    catch err %#ok<NASGU>
                        uiProperties=obj.Item.UIProperties;
                        uiProperties.State=starepository.ioitemproperty.ItemState.Error;
                    end
                end
            end



            dataDim=getTSDimension(obj.TimeSeries);




            if obj.isMultiDimensional(dataDim)&&length(dataDim)<=2

                if~isa(obj.TSValues,'string')
                    IS_ALL_ZERO_ZERO=all(var==0+0i);
                else
                    IS_ALL_ZERO_ZERO=0;
                end

                while numel(IS_ALL_ZERO_ZERO)~=1
                    IS_ALL_ZERO_ZERO=all(IS_ALL_ZERO_ZERO);
                end

                if~isreal(var)&&~isstring(var)
                    signalproperty.SignalType=getString(message('sl_sta_general:common:Complex'));
                else
                    signalproperty.SignalType=getString(message('sl_sta_general:common:Real'));
                end

            else

                if~isreal(var)&&~isstring(var)
                    signalproperty.SignalType=getString(message('sl_sta_general:common:Complex'));
                else
                    signalproperty.SignalType=getString(message('sl_sta_general:common:Real'));
                end
            end





            signalproperty.SampleTime=-1;

            signalproperty.Dimension=mat2str(dataDim);
        end
    end

    methods(Access='private')


        function result=isMultiDimensional(~,SampleDims)
            if length(SampleDims)>1||(length(SampleDims)==1&&SampleDims>1)

                result=true;
            elseif SampleDims>2


                result=true;

            else
                result=false;

            end
        end

    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;


            if isa(dataValue,'timeseries')&&...
                ~isempty(dataValue)&&...
                isscalar(dataValue)
                bool=true;
            end
        end

    end

end




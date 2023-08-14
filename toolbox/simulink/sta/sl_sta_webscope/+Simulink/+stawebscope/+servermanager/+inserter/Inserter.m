classdef Inserter<handle










    properties
InputData
DataToBeInserted
Item
MetaData
InsertedData
ColumnLocation
RowLocation
NumOfColumns
    end

    methods

        function obj=Inserter(item,inputData)

            [rootID,sigID]=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);


            repoUtil=starepository.RepositoryUtility();
            metaData_sig=repoUtil.getMetaDataStructure(sigID);
            metaData_parent=repoUtil.getMetaDataStructure(rootID);

            if metaData_sig.TreeOrder~=metaData_parent.TreeOrder
                obj.ColumnLocation=metaData_sig.TreeOrder-metaData_parent.TreeOrder+1;
            else
                obj.ColumnLocation=2;
            end
            obj.InputData=inputData;
            obj.NumOfColumns=length(inputData{1});
            obj.Item=item;
            obj.MetaData=metaData_sig;
        end

        function preProcess(obj)

            if iscell(obj.InputData{1}{2})||ischar(obj.InputData{1}{2})
                obj.InsertedData=cell(1,obj.NumOfColumns-1);
            else
                obj.InsertedData=zeros(1,obj.NumOfColumns-1);
            end

        end

        function data=extractValue(~,data)
            if ischar(data)
                data=str2double(data);
            end
            if iscell(data)
                data=data{1};
            end
        end

        function interpMethod=getInterpolationMethod(obj,row)
            if strcmp(obj.Item.Interpolation,'linear')
                interpMethod='linear';
            elseif row==1
                interpMethod='next';
            else
                interpMethod='previous';
            end

        end

        function[r1,r2]=getRowIndicesForInterpolation(obj,row)
            if row==1

                r1=row;r2=row+1;
            elseif row>=length(obj.InputData)

                r2=length(obj.InputData);
                r1=r2-1;
            else

                r1=row-1;r2=row;
            end
        end


        function val=getValue(obj,row,col)
            val=obj.extractValue(obj.InputData{row}{col});
        end

        function data=insert(obj,row)
            data=obj.extractValue(obj.DataToBeInserted.y);
            if contains(obj.Item.Type,'Complex')
                realPart=data;

                imagPart=imag(interpolate(obj,row,obj.ColumnLocation));
                data=complex(realPart,imagPart);
            end
        end

        function data=formatData(~,data)


        end

        function data=interpolate(obj,row,col)

            interpMethod=getInterpolationMethod(obj,row);

            if length(obj.InputData)==1

                data=obj.InputData{1}{col};
            else
                [r1,r2]=getRowIndicesForInterpolation(obj,row);
                if ischar(obj.InputData{r1}{1})
                    X=[str2double(obj.InputData{r1}{1}),str2double(obj.InputData{r2}{1})];
                else
                    X=[obj.InputData{r1}{1},obj.InputData{r2}{1}];
                end
                Y=[obj.getValue(r1,col),...
                obj.getValue(r2,col)];
                interpolatedPoint=interp1(...
                X,...
                double(Y),...
                obj.DataToBeInserted.x,...
                interpMethod,'extrap');
                data=interpolatedPoint;
            end

        end

        function copyData(obj)
            if isrow(obj.DataToBeInserted.y)
                obj.InsertedData=obj.DataToBeInserted.y;
            else
                obj.InsertedData=obj.DataToBeInserted.y';
            end
        end

        function insertData(obj,dataToBeInserted,row)
            obj.DataToBeInserted=dataToBeInserted;
            if length(obj.DataToBeInserted.y)>1&&...
                ~ischar(obj.DataToBeInserted.y)
                obj.copyData;
            else
                numDataColumns=obj.NumOfColumns;
                obj.preProcess;
                for col=2:numDataColumns
                    if col==obj.ColumnLocation

                        data=obj.insert(row);
                    else

                        data=obj.interpolate(row,col);
                    end


                    data=formatData(obj,data);
                    if iscell(obj.InsertedData(col-1))
                        obj.InsertedData{col-1}=data;
                    else
                        obj.InsertedData(col-1)=data;
                    end
                end
            end

        end

    end
end


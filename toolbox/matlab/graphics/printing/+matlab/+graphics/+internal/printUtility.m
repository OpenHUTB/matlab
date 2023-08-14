classdef printUtility<handle







    methods(Static)


        function result=getValueHelper(obj,prop)


            result={};
            try
                result=get(obj,prop);
            catch
            end
        end


        function cellArray=getValuesAsCell(obj,prop,allowemptycell)


            obj=num2cell(obj);
            cellArray=cellfun(@(obj)matlab.graphics.internal.printUtility.getValueHelper(obj,prop),...
            obj,'UniformOutput',false);

            if nargin<3
                allowemptycell=0;
            end
            if~iscell(cellArray)&&(allowemptycell||~isempty(cellArray))
                cellArray={cellArray};
            end
        end


        function outData=pushOldData(inData,objs,prop,values)



            if isempty(objs)
                outData=inData;
            else
                outData.objs=[{objs},inData.objs];
                outData.prop=[{prop},inData.prop];
                outData.values=[{values},inData.values];
            end
        end


        function setValues(obj,propName,val)


            if iscell(propName)
                propName=propName{1};
            end
            propName_I='';

            if iscell(val)&&length(val)==1
                val=val{1};
            end



            validx=1;
            for idx=1:length(obj)

                if~isa(obj(idx),'matlab.graphics.shape.internal.ScribeObject')&&...
                    ~isempty(propName_I)&&isprop(obj(idx),propName_I)
                    propToSet=propName_I;
                else
                    propToSet=propName;
                end
                if iscell(val)
                    try
                        set(obj(idx),propToSet,val{validx});
                        validx=validx+1;
                    catch ex




                        if strcmp(ex.identifier,'MATLAB:datatypes:InvalidEnumValue')
                            throw(ex);
                        end
                    end
                else
                    try
                        set(obj(idx),propToSet,val);
                    catch ex




                        if strcmp(ex.identifier,'MATLAB:datatypes:InvalidEnumValue')
                            throw(ex);
                        end
                    end
                end
            end
        end


        function allRulers=getAxesAllRulers(allAxes,dims)


            allRulers=[];
            for n=1:length(allAxes)
                for m=1:length(dims)
                    allRulers=[allRulers;allAxes(n).(dims{m})];%#ok<AGROW>
                end
            end
        end


        function newArray=scaleValues(inArray,scale,minv)



            newArray=cellfun(@(val)max(minv,scale*val),inArray,...
            'UniformOutput',false);
        end


        function gray=mapToGrayScale(color)




            gray=color;
            if ischar(color)
                switch color(1)
                case 'y'
                    color=[1,1,0];
                case 'm'
                    color=[1,0,1];
                case 'c'
                    color=[0,1,1];
                case 'r'
                    color=[1,0,0];
                case 'g'
                    color=[0,1,0];
                case 'b'
                    color=[0,0,1];
                case 'w'
                    color=[1,1,1];
                case 'k'
                    color=[0,0,0];
                end
            end
            if~ischar(color)
                gray=0.30*color(1)+0.59*color(2)+0.11*color(3);


                gray=round(gray,4);
            end
        end
    end
end
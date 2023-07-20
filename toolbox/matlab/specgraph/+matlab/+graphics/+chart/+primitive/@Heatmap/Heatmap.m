classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)Heatmap<...
    matlab.graphics.chart.primitive.ColorGrid %#ok<ATUNK>



    properties(AffectsDataLimits,AbortSet)
        ColorScaling matlab.internal.datatype.matlab.graphics.chart.datatype.HeatmapColorScalingType='scaled'
    end

    methods
        function hObj=Heatmap(varargin)
            hObj=hObj@matlab.graphics.chart.primitive.ColorGrid();


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Hidden)
        function extents=getColorDataExtents(hObj)



            colorData=hObj.ScaledColorData(:);


            finiteData=colorData(isfinite(colorData));

            if ismember(hObj.ColorScaling,{'scaledcolumns','scaledrows'})


                extents=[0,1];
            elseif strncmp(hObj.ColorScaling,'standardized',12)



                if isempty(finiteData)

                    mx=0;
                else

                    mx=max(abs(finiteData));
                end
                extents=[-mx,mx];
            elseif isempty(finiteData)

                extents=[NaN,NaN];
            else


                mn=min(finiteData);
                mx=max(finiteData);
                extents=[mn,mx];
            end
        end

        function hObj=saveobj(hObj)%#ok<MANU>

            error(message('MATLAB:Chart:SavingDisabled',...
            'matlab.graphics.chart.primitive.Heatmap'));
        end
    end

    methods(Access=protected)
        function colorData=calculateScaledColorData(hObj)

            colorData=double(hObj.ColorData);


            origColorData=colorData;
            nonFiniteValues=~isfinite(colorData);
            colorData(nonFiniteValues)=NaN;
            restoreInfs=true;


            scaling=char(hObj.ColorScaling);
            if contains(scaling,'columns')
                dim=1;
            elseif contains(scaling,'rows')
                dim=2;
            else
                dim=0;
            end


            switch scaling
            case{'scaledcolumns','scaledrows'}




                mn=min(colorData,[],dim);
                mx=max(colorData,[],dim);



                uniform=(mn==mx);
                mn=mn-uniform;
                mx=mx+uniform;


                colorData=(colorData-mn)./(mx-mn);
            case{'rankedcolumns','rankedrows'}


                [~,o]=sort(origColorData,dim);
                [~,colorData]=sort(o,dim);
                restoreInfs=false;
            case{'standardized','standardizedcolumns','standardizedrows'}





                if dim==0

                    mn=mean(colorData(:),'omitnan');
                    sd=std(colorData(:),'omitnan');
                else

                    mn=mean(colorData,dim,'omitnan');
                    sd=std(colorData,0,dim,'omitnan');
                end



                sd(sd==0)=1;


                colorData=(colorData-mn)./sd;
            case 'log'

                if all(colorData(:)<=0)&&~all(colorData(:)==0)

                    colorData=-log(-colorData);
                elseif any(colorData(:)<0)


                    warning(message('MATLAB:graphics:heatmap:NegativeColorDataInLogScale'));
                    colorData(colorData<0)=NaN;
                    colorData=log(colorData);
                else

                    colorData=log(colorData);
                end
            end


            if restoreInfs
                colorData(nonFiniteValues)=origColorData(nonFiniteValues);
            else

                colorData(isnan(origColorData))=NaN;
            end
        end
    end

    methods
        function set.ColorScaling(hObj,colorScaling)
            hObj.ColorScaling=colorScaling;


            hObj.ScaledColorDataDirty=true;
        end
    end
end

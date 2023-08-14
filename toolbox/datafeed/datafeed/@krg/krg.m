classdef krg<handle

































    properties(Access=public)
MiData
MiDate
MiCode
TradeDaysInYear
    end

    methods(Access=public)

        function k=krg(miData,miDate,miCode,tradeDaysInYear)


            currentDate=floor(now);
            if(currentDate-datenum(max(miData.b5)))>60
                error(message('datafeed:krg:expiredMiData'))
            end


            k.MiData=miData;
            k.MiData.Date=datetime(k.MiData.Date);


            if nargin>1&&~isempty(miDate)
                if isnumeric(miDate)
                    k.MiDate=datetime(miDate,'ConvertFrom','datenum');
                else
                    k.MiDate=datetime(miDate);
                end
            else
                k.MiDate=datetime('today');
            end


            if nargin>2&&~isempty(miCode)
                k.MiCode=miCode;
            else
                k.MiCode=1;
            end


            if nargin>3&&~isempty(tradeDaysInYear)
                k.TradeDaysInYear=tradeDaysInYear;
            else
                k.TradeDaysInYear=250;
            end

        end


        function ttc=iStar(k,tradeData)






















































            [a1,a2,a3,~,a5]=extractMarketImpactParameters(k);


            sizeFlag=krg.krgDataFlags(tradeData);


            if sizeFlag
                ttc=a1.*tradeData.Size.^a2.*tradeData.Volatility.^a3.*tradeData.Price.^a5;
            else
                ttc=a1.*(tradeData.Shares./tradeData.ADV).^a2.*tradeData.Volatility.^a3.*tradeData.Price.^a5;
            end

        end


        function lf=liquidityFactor(k,tradeData)




















































            [a1,a2,a3,~,a5]=extractMarketImpactParameters(k);


            lf=a1.*(1./tradeData.ADV).^a2.*tradeData.Volatility.^a3.*(1./tradeData.Price).^a2.*tradeData.Price.^a5;

        end


        function[mi,it,ip]=marketImpact(k,tradeData)

























































            [~,~,~,a4,~,b1]=extractMarketImpactParameters(k);


            [sizeFlag,povFlag,timeFlag,tsvpFlag]=krg.krgDataFlags(tradeData);


            if sizeFlag
                Size=tradeData.Size;
            else
                Size=tradeData.Shares./tradeData.ADV;
            end


            if povFlag

            elseif timeFlag
                tradeData.POV=krg.tradetime2pov(tradeData.TradeTime,Size);
            elseif tsvpFlag


                [numRows,numCols]=size(tradeData.TradeSchedule);
                if(numRows>1)&&(numCols>1)
                    bTSMatrix=true;
                else
                    bTSMatrix=false;
                end
                tradeData.POV=tradeData.TradeSchedule./(tradeData.TradeSchedule+tradeData.VolumeProfile);
                if bTSMatrix

                    tradeWeight=tradeData.TradeSchedule./sum(tradeData.TradeSchedule,2);
                else

                    tradeWeight=tradeData.TradeSchedule/sum(tradeData.TradeSchedule);
                end
            end


            ttc=iStar(k,tradeData);


            it=b1.*ttc;
            ip=(1-b1).*ttc;


            if tsvpFlag

                if bTSMatrix
                    mi=(b1.*sum(tradeWeight.*(tradeData.POV.^a4),2)+(1-b1)).*ttc;
                else
                    mi=(b1.*sum(tradeWeight.*(tradeData.POV.^a4))+(1-b1)).*ttc;
                end
            else

                mi=(b1.*tradeData.POV.^a4+(1-b1)).*ttc;
            end

        end

    end

    methods(Access=private)

        function[a1,a2,a3,a4,a5,b1]=extractMarketImpactParameters(k)






            encKey=[...
            210,194,177,264,285,266,169,164,211,190;...
            313,261,223,370,363,424,236,241,292,276;...
            120,129,108,147,156,175,114,94,130,105;...
            264,262,203,322,358,369,253,208,199,208;...
            203,203,205,286,269,345,239,199,193,198;...
            231,155,199,226,252,296,208,214,236,199;...
            227,140,121,239,207,253,124,125,158,178;...
            238,279,255,341,409,402,309,280,284,244;...
            217,203,202,236,318,335,259,248,214,179;...
            245,217,193,242,302,364,275,252,270,212;...
            ];


            miDecrypted=table2array(k.MiData(:,2:end));
            miDates=datenum(k.MiData.Date);
            miDecrypted(:,2:end)=miDecrypted(:,2:end)*inv(encKey);%#ok
            miDecrypted=[miDates,miDecrypted];



            miDecrypted(miDecrypted(:,2)~=k.MiCode,:)=[];
            if isempty(miDecrypted)
                error(message('datafeed:krg:noMatchingRegionCode'))
            end


            targetDate=datenum(k.MiDate);
            miDecrypted((targetDate-miDecrypted(:,1))<0,:)=[];
            dateDiffs=targetDate-miDecrypted(:,1);
            dateIndex=(dateDiffs==min(dateDiffs));
            miParameters=miDecrypted(dateIndex,:);
            a1=miParameters(3);
            a2=miParameters(4);
            a3=miParameters(5);
            a4=miParameters(6);
            a5=miParameters(7);
            b1=miParameters(8);

        end

    end

    methods(Static)

        function tt=pov2tradetime(POV,Size)




            tt=Size.*(1-POV)./POV;

        end


        function pov=tradetime2pov(TradeTime,Size)




            pov=Size./(TradeTime+Size);

        end


        function[sizeFlag,povFlag,timeFlag,tsvpFlag]=krgDataFlags(tradeData)












            sizeFlag=false;
            povFlag=false;
            timeFlag=false;
            tsvpFlag=false;


            switch class(tradeData)

            case 'table'

                if any(strcmpi(properties(tradeData),'size'))
                    sizeFlag=true;
                end
                if any(strcmpi(properties(tradeData),'pov'))
                    povFlag=true;
                elseif any(strcmpi(properties(tradeData),'tradetime'))
                    timeFlag=true;
                elseif any(strcmpi(properties(tradeData),'tradeschedule'))
                    tsvpFlag=true;
                end

            case 'struct'

                if isfield(tradeData,'Size')
                    sizeFlag=true;
                end
                if isfield(tradeData,'POV')
                    povFlag=true;
                elseif isfield(tradeData,'TradeTime')
                    timeFlag=true;
                elseif isfield(tradeData,'TradeSchedule')
                    tsvpFlag=true;
                end

            end

        end

    end

end
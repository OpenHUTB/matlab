classdef SimulinkHelper




    methods(Static=true)





        function flag=slBlockHasOutMinMaxProp(slBlkObj)
            flag=isprop(slBlkObj,'OutMin')&&isprop(slBlkObj,'OutMax');
        end





        function flag=slBlockHasParamMinMaxProp(slBlkObj)
            flag=isprop(slBlkObj,'ParamMin')&&isprop(slBlkObj,'ParamMax');
        end






        function[minVal,maxVal]=getSlBlockOutMinMaxValues(slBlkObj)
            oldFormat=get(0,'format');
            restoreFormat=onCleanup(@()format(oldFormat));
            format('long');

            [minVal,~]=slResolve(slBlkObj.OutMin,slBlkObj.handle);
            [maxVal,~]=slResolve(slBlkObj.OutMax,slBlkObj.handle);
        end






        function[minVal,maxVal]=getSlBlockParamMinMaxValues(slBlkObj)
            oldFormat=get(0,'format');
            restoreFormat=onCleanup(@()format(oldFormat));
            format('long');

            [minVal,~]=slResolve(slBlkObj.ParamMin,slBlkObj.handle);
            [maxVal,~]=slResolve(slBlkObj.ParamMax,slBlkObj.handle);
        end





        function[flag,badMin,badMax]=hasMissingMinMaxValues(minVal,maxVal)








            badMin=isempty(minVal)||isnan(minVal)||isinf(minVal);
            badMax=isempty(maxVal)||isnan(maxVal)||isinf(maxVal);
            flag=badMin||badMax;
        end



        function objH=getHandleFromID(slURL)
            [objH,~,~,~,~]=Simulink.ID.getHandle(slURL);
        end



        function[slH,errTxt]=getHandle(slEntity)
            slH=[];
            errTxt='';
            try
                if isa(slEntity,'double')&&is_simulink_handle(slEntity)
                    slH=slEntity;
                elseif isa(slEntity,'Simulink.Object')
                    slH=slEntity.Handle;
                elseif ischar(slEntity)
                    slH=get_param(slEntity,'Handle');
                elseif iscellstr(slEntity)
                    slH=cell2mat(get_param(slEntity,'Handle'));
                else
                    errTxt='Invalid object';
                end
            catch Me
                errTxt=Me.message;
            end
        end







        function[slPath,errTxt]=getFullName(slEntity)
            slPath=[];
            errTxt='';
            try
                if isa(slEntity,'double')&&is_simulink_handle(slEntity)
                    slPath=getfullname(slEntity);
                elseif isa(slEntity,'Simulink.Object')
                    slPath=slEntity.getFullName();
                elseif ischar(slEntity)||iscellstr(slEntity)
                    slPath=slEntity;
                else
                    errTxt='Invalid object';
                end
            catch Me
                errTxt=Me.message;
            end
        end

    end

end


function hfcns=ext_open_utils()







    hfcns.i_BlockLogEventCompleted=@i_BlockLogEventCompleted;
    hfcns.i_SendBlockExecute=@i_SendBlockExecute;
    hfcns.i_WriteSourceSignal=@i_WriteSourceSignal;
    hfcns.i_WriteSourceMRSignal=@i_WriteSourceMRSignal;
    hfcns.i_WriteSourceDWork=@i_WriteSourceDWork;
    hfcns.i_SendTerminate=@i_SendTerminate;
    hfcns.i_ConvertSIToRWV=@i_ConvertSIToRWV;
    hfcns.i_ConvertRWVToSI=@i_ConvertRWVToSI;





    function glbVars=i_BlockLogEventCompleted(glbVars,upInfoIdx,blkIdx)




        if(~isempty(glbVars.glbUpInfoWired)&&...
            upInfoIdx==glbVars.glbUpInfoWired.index)
            glbVars.glbUpInfoWired.upBlks{blkIdx}.LogEventCompleted=true;
        elseif(~isempty(glbVars.glbUpInfoFloating)&&...
            upInfoIdx==glbVars.glbUpInfoFloating.index)
            glbVars.glbUpInfoFloating.upBlks{blkIdx}.LogEventCompleted=true;
        else
            DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
        end



        function glbVars=i_SendBlockExecute(glbVars,upInfoIdx,blkIdx)







            if(~isempty(glbVars.glbUpInfoWired)&&...
                upInfoIdx==glbVars.glbUpInfoWired.index)
                blkName=glbVars.glbUpInfoWired.upBlks{blkIdx}.Name;
            elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                upInfoIdx==glbVars.glbUpInfoFloating.index)
                blkName=glbVars.glbUpInfoFloating.upBlks{blkIdx}.Name;
            else
                DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
            end

            mat=cell(1,2);
            mat{1}=get_param(blkName,'handle');
            mat{2}=upInfoIdx;
            set_param(glbVars.glbModel,'ExtModeOpenProtocolExecuteBlock',mat);



            function glbVars=i_WriteSourceSignal(glbVars,upInfoIdx,blkIdx,...
                srcSigIdx,time,data)









































































                isTimeFirst=false;
                if length(time)==1
                    dims=size(data);
                    if ndims(data)==1||dims(1)==1
                        isTimeFirst=true;
                    end
                else
                    if ndims(data)<=2
                        isTimeFirst=true;
                    end
                end

                if(~isempty(glbVars.glbUpInfoWired)&&...
                    upInfoIdx==glbVars.glbUpInfoWired.index)
                    glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries=...
                    glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries.init(data,time,[],'isTimeFirst',isTimeFirst);
                elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                    upInfoIdx==glbVars.glbUpInfoFloating.index)
                    glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries=...
                    glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries.init(data,time,[],'isTimeFirst',isTimeFirst);
                else
                    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
                end



                function glbVars=i_WriteSourceMRSignal(glbVars,upInfoIdx,blkIdx,...
                    srcSigIdx,time,data)




                    isTimeFirst=false;
                    if length(time)==1
                        dims=size(data);
                        if ndims(data)==1||dims(1)==1
                            isTimeFirst=true;
                        end
                    else
                        if ndims(data)<=2
                            isTimeFirst=true;
                        end
                    end

                    if(~isempty(glbVars.glbUpInfoWired)&&...
                        upInfoIdx==glbVars.glbUpInfoWired.index)
                        glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcMRSignals{srcSigIdx}.Timeseries=...
                        glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcMRSignals{srcSigIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
                    elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                        upInfoIdx==glbVars.glbUpInfoFloating.index)
                        glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcMRSignals{srcSigIdx}.Timeseries=...
                        glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcMRSignals{srcSigIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
                    else
                        DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
                    end



                    function glbVars=i_WriteSourceDWork(glbVars,upInfoIdx,blkIdx,...
                        srcDWorkIdx,time,data)



                        isTimeFirst=false;
                        if length(time)==1
                            dims=size(data);
                            if ndims(data)==1||dims(1)==1
                                isTimeFirst=true;
                            end
                        else
                            if ndims(data)<=2
                                isTimeFirst=true;
                            end
                        end

                        if(~isempty(glbVars.glbUpInfoWired)&&...
                            upInfoIdx==glbVars.glbUpInfoWired.index)
                            glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries=...
                            glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
                        elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                            upInfoIdx==glbVars.glbUpInfoFloating.index)
                            glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries=...
                            glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
                        else
                            DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
                        end



                        function glbVars=i_SendTerminate(glbVars,upInfoIdx)







                            if(~isempty(glbVars.glbUpInfoWired)&&...
                                upInfoIdx==glbVars.glbUpInfoWired.index)
                                if i_AllBlocksLogEventCompleted(glbVars.glbUpInfoWired)
                                    glbVars=i_ResetBlocksLogEventCompleted(glbVars,glbVars.glbUpInfoWired.index);
                                    if glbVars.glbUpInfoWired.trigger.OneShot==1
                                        glbVars.glbUpInfoWired.trigger_armed=0;
                                        set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',glbVars.glbUpInfoWired.index);
                                    else
                                        set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogEvent',glbVars.glbUpInfoWired.index);
                                    end
                                end
                            elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                                upInfoIdx==glbVars.glbUpInfoFloating.index)
                                if i_AllBlocksLogEventCompleted(glbVars.glbUpInfoFloating)
                                    glbVars=i_ResetBlocksLogEventCompleted(glbVars,glbVars.glbUpInfoFloating.index);
                                    if glbVars.glbUpInfoFloating.trigger.OneShot==1
                                        glbVars.glbUpInfoFloating.trigger_armed=0;
                                        set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',glbVars.glbUpInfoFloating.index);
                                    else
                                        set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogEvent',glbVars.glbUpInfoFloating.index);
                                    end
                                end
                            else
                                DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
                            end



                            function allBlocksLogEventCompleted=i_AllBlocksLogEventCompleted(upInfo)





                                allBlocksLogEventCompleted=true;
                                upBlks=upInfo.upBlks;
                                numUpBlks=length(upBlks);

                                for nUpBlk=1:numUpBlks
                                    if(upInfo.upBlks{nUpBlk}.LogEventCompleted==false)
                                        allBlocksLogEventCompleted=false;
                                        break;
                                    end
                                end



                                function[dtObj,isEnum]=i_GetDTypeObject(dTypeName,blockName)





                                    dtObj=[];
                                    isEnum=false;




                                    if Simulink.data.isSupportedEnumClass(dTypeName)
                                        isEnum=true;
                                        return;
                                    end




                                    try




                                        dtObj=fixdt(dTypeName);
                                    catch
                                        if~isempty(blockName)



                                            try




                                                dtObj=slResolve(dTypeName,blockName);
                                            catch
                                                DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType',dTypeName);
                                            end
                                        else





                                            if evalin('base',['exist(''',dTypeName,''')'])
                                                try








                                                    dtObj=evalin('base',dTypeName);
                                                catch
                                                    try







                                                        dtObj=evalin('base',['?',dTypeName]);
                                                    catch
                                                        DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType',dTypeName);
                                                    end
                                                end
                                            else
                                                DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType',dTypeName);
                                            end
                                        end
                                    end

                                    function RWVs=i_ConvertSIToRWV(dTypeName,blockName,values)

















                                        [dtObj,isEnum]=i_GetDTypeObject(dTypeName,blockName);

                                        persistent isFiExists;
                                        if isempty(isFiExists)
                                            isFiExists=exist('isfi','file');
                                        end

                                        persistent fiExists;
                                        if isempty(fiExists)
                                            fiExists=exist('fi','file');
                                        end

                                        persistent useFi;
                                        if isempty(useFi)
                                            useFi=false;
                                            p=fipref;
                                            if license('test','Fixed_Point_Toolbox')||...
                                                ~strcmp(p.DataTypeOverride,'ForceOff')
                                                useFi=true;
                                                try
                                                    fi(0,fixdt(1,10));
                                                catch
                                                    useFi=false;
                                                end
                                            end
                                        end

                                        if isEnum







                                            RWVs=int32(feval(dTypeName,values));

                                        elseif isFiExists&&isfi(values)











                                            a=values(1);
                                            if length(a.simulinkarray)==1
                                                RWVs=values.data;
                                            else
                                                RWVs=values;
                                            end

                                        else
                                            if fiExists&&useFi












                                                fiVal=fi([],dtObj);
                                                fiVal.int=values;
                                                a=fiVal(1);
                                                if length(a.simulinkarray)==1
                                                    RWVs=fiVal.data;
                                                else
                                                    RWVs=fiVal;
                                                end
                                            else
                                                try

                                                    dtypeFunc=str2func(dTypeName);
                                                    RWVs=dtypeFunc(values);
                                                catch ME
                                                    DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType',dTypeName);
                                                end
                                            end
                                        end



                                        function SIs=i_ConvertRWVToSI(dTypeName,blockName,values)


















                                            [dtObj,isEnum]=i_GetDTypeObject(dTypeName,blockName);

                                            persistent isFiExists;
                                            if isempty(isFiExists)
                                                isFiExists=exist('isFi','file');
                                            end

                                            persistent fiExists;
                                            if isempty(fiExists)
                                                fiExists=exist('fi','file');
                                            end

                                            persistent useFi;
                                            if isempty(useFi)
                                                useFi=false;
                                                p=fipref;
                                                if license('test','Fixed_Point_Toolbox')||...
                                                    ~strcmp(p.DataTypeOverride,'ForceOff')
                                                    useFi=true;
                                                    try
                                                        fi(0,fixdt(1,10));
                                                    catch
                                                        useFi=false;
                                                    end
                                                end
                                            end

                                            if isEnum






                                                SIs=cast(values,values.underlyingType);

                                            elseif isFiExists&&isfi(values)











                                                a=values(1);
                                                if length(a.simulinkarray)==1
                                                    SIs=values.int;
                                                else
                                                    SIs=values;
                                                end
                                            elseif isa(values,'half')

                                                SIs=values.storedInteger;
                                            elseif fiExists&&useFi












                                                fiVal=fi(values,dtObj);
                                                a=fiVal(1);
                                                if length(a.simulinkarray)==1
                                                    SIs=fiVal.int;
                                                else
                                                    SIs=fiVal;
                                                end
                                            else
                                                try

                                                    dtypeFunc=str2func(dTypeName);
                                                    SIs=dtypeFunc(values);
                                                catch ME
                                                    DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType',dTypeName);
                                                end
                                            end



                                            function glbVars=i_ResetBlocksLogEventCompleted(glbVars,upInfoIdx)




                                                if(~isempty(glbVars.glbUpInfoWired)&&...
                                                    upInfoIdx==glbVars.glbUpInfoWired.index)
                                                    numUpBlks=length(glbVars.glbUpInfoWired.upBlks);
                                                    for nUpBlk=1:numUpBlks
                                                        glbVars.glbUpInfoWired.upBlks{nUpBlk}.LogEventCompleted=false;
                                                    end
                                                elseif(~isempty(glbVars.glbUpInfoFloating)&&...
                                                    upInfoIdx==glbVars.glbUpInfoFloating.index)
                                                    numUpBlks=length(glbVars.glbUpInfoFloating.upBlks);
                                                    for nUpBlk=1:numUpBlks
                                                        glbVars.glbUpInfoFloating.upBlks{nUpBlk}.LogEventCompleted=false;
                                                    end
                                                else
                                                    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
                                                end



classdef SolverProfilerCommandLineOptionsManager<handle




















    properties(SetAccess=private)
SaveStates
SaveZCSignals
SaveSimscapeStates
SaveJacobian
StartTime
StopTime
BufferSize
TimeOut
DataFullFile
OpenSP
OptionsMap
    end

    methods



        function obj=SolverProfilerCommandLineOptionsManager(mdl)
            import solverprofiler.util.*
            obj.SaveStates='Off';
            obj.SaveZCSignals='Off';
            obj.SaveSimscapeStates='Off';
            obj.SaveJacobian='Off';
            configSet=getActiveConfigSet(mdl);
            obj.StartTime=configSet.get_param('StartTime');
            obj.StopTime=configSet.get_param('StopTime');
            obj.BufferSize=50000;
            obj.TimeOut=365*24*3600;
            obj.DataFullFile=fullfile(pwd,[mdl,'_@_',utilGetTimeLabel(),'.mat']);
            obj.OpenSP='Off';
            optionNames=fieldnames(obj);
            obj.OptionsMap=containers.Map(lower(optionNames),optionNames);
            obj.OptionsMap.remove({'optionsmap'});
        end


        function delete(~)
        end


        function setOptions(obj,list)
            import solverprofiler.util.*


            if isempty(list)
                return;
            end


            for i=1:2:length(list)
                key=lower(list{i});
                if obj.OptionsMap.isKey(key)
                    name=obj.OptionsMap(key);
                    try
                        val=list{i+1};
                    catch
                        id='Simulink:solverProfiler:InvalidParaValPair';
                        msg=utilDAGetString('InvalidParaValPair');
                        throw(MException(id,msg));
                    end
                    obj.(name)=val;
                else
                    id='Simulink:solverProfiler:NotAnOption';
                    msg=utilDAGetString('NotAnOption',list{i});
                    throw(MException(id,msg));
                end
            end


            if~obj.isOnOff(obj.SaveStates)
                id='Simulink:solverProfiler:OptionCanOnlyBeOnOff';
                msg=utilDAGetString('OptionCanOnlyBeOnOff','SaveStates');
                throw(MException(id,msg));
            end

            if~obj.isOnOff(obj.SaveZCSignals)
                id='Simulink:solverProfiler:OptionCanOnlyBeOnOff';
                msg=utilDAGetString('OptionCanOnlyBeOnOff','SaveZCSignals');
                throw(MException(id,msg));
            end

            if~obj.isOnOff(obj.SaveSimscapeStates)
                id='Simulink:solverProfiler:OptionCanOnlyBeOnOff';
                msg=utilDAGetString('OptionCanOnlyBeOnOff','SaveSimscapeStates');
                throw(MException(id,msg));
            end

            if~obj.isOnOff(obj.SaveJacobian)
                id='Simulink:solverProfiler:OptionCanOnlyBeOnOff';
                msg=utilDAGetString('OptionCanOnlyBeOnOff','SaveJacobian');
                throw(MException(id,msg));
            end

            if~obj.isFileLocationValid(obj.DataFullFile)
                id='Simulink:solverProfiler:InvalidDirectory';
                msg=utilDAGetString('InvalidDirectory',obj.DataFullFile);
                throw(MException(id,msg));
            else

                [path,~,~]=fileparts(obj.DataFullFile);
                if isempty(path)
                    obj.DataFullFile=fullfile(pwd,obj.DataFullFile);
                end
            end

            if~obj.isOnOff(obj.OpenSP)
                id='Simulink:solverProfiler:OptionCanOnlyBeOnOff';
                msg=utilDAGetString('OptionCanOnlyBeOnOff','OpenSP');
                throw(MException(id,msg));
            end

            if~obj.isPositiveDouble(obj.TimeOut)
                id='Simulink:solverProfiler:OptionCanOnlyBePostiveNumber';
                msg=utilDAGetString('OptionCanOnlyBePostiveNumber','TimeOut');
                throw(MException(id,msg));
            end

            if utilGetScalarValue(obj.StartTime)>utilGetScalarValue(obj.StopTime)
                id='failedToStart:startExceedEnd';
                msg=utilDAGetString('startExceedEnd');
                throw(MException(id,msg));
            end

        end


        function flag=SaveStatesOn(obj)
            flag=strcmpi(obj.SaveStates,'On');
        end

        function flag=SaveZCSignalsOn(obj)
            flag=strcmpi(obj.SaveZCSignals,'On');
        end

        function flag=SaveSimscapeStatesOn(obj)
            flag=strcmpi(obj.SaveSimscapeStates,'On');
        end

        function flag=SaveJacobianOn(obj)
            flag=strcmpi(obj.SaveJacobian,'On');
        end

        function flag=openSPAfterProfile(obj)
            flag=strcmpi(obj.OpenSP,'On');
        end

        function val=getStartTime(obj)
            val=num2str(obj.StartTime);
        end

        function val=getStopTime(obj)
            val=num2str(obj.StopTime);
        end

        function val=getBufferSize(obj)
            val=num2str(obj.BufferSize);
        end

        function val=getTimeOut(obj)
            val=num2str(obj.TimeOut);
        end

        function file=getDataFullFile(obj)
            file=obj.DataFullFile;
        end

    end

    methods(Static)


        function flag=isOnOff(str)
            if strcmpi(str,'on')||strcmpi(str,'off')
                flag=true;
            else
                flag=false;
            end
        end


        function flag=isFileLocationValid(file)
            try
                [path,~,~]=fileparts(file);
                if~isempty(path)

                    if exist(path,'dir')==7
                        flag=true;
                    else
                        flag=false;
                    end
                else


                    flag=true;
                end
            catch
                flag=false;
            end
        end


        function flag=isPositiveDouble(valexp)
            import solverprofiler.util.*
            try
                valexp=num2str(valexp);
                value=utilInterpretVal(valexp);
                if value>0
                    flag=true;
                else
                    flag=false;
                end
            catch
                flag=false;
            end
        end

    end
end
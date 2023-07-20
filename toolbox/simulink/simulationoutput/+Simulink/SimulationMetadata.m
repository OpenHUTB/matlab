classdef SimulationMetadata














    properties(SetAccess=private,GetAccess=public)
ModelInfo
TimingInfo
ExecutionInfo
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)
AppInfo
    end

    properties(SetAccess=public,GetAccess=public)
        UserString{Simulink.SimulationMetadata.mustBeValidUserString}=Simulink.SimulationMetadata.DefaultUserString
UserData
    end

    properties(Constant,Hidden=true)
        DefaultUserString=''
    end

    methods(Hidden=true)
        function out=SimulationMetadata(in,checkVersion)
            if nargin==1
                checkVersion=true;
            end
            out.ModelInfo=in.ModelInfo;
            out.TimingInfo=in.TimingInfo;
            getExecutionInfo=true;

            if checkVersion
                try
                    simulinkVersion=strsplit(out.ModelInfo.SimulinkVersion.Version,'.');
                    if str2num(simulinkVersion{1})<8
                        getExecutionInfo=false;
                    elseif str2num(simulinkVersion{1})==8
                        if str2num(simulinkVersion{2})<7
                            getExecutionInfo=false;
                        end
                    end

                    if(isstruct(in)&&isfield(in,'AppInfo'))||isprop(in,'AppInfo')
                        out.AppInfo=in.AppInfo;
                    else
                        out.AppInfo=struct();
                    end
                catch E
                end
            else
                getExecutionInfo=true;
            end

            if getExecutionInfo
                out.ExecutionInfo=in.ExecutionInfo;
            end

            if(isstruct(in)&&isfield(in,'UserString'))||isprop(in,'UserString')
                out.UserString=in.UserString;
            else
                out.UserString=Simulink.SimulationMetadata.DefaultUserString;
            end
        end

        function out=getInternalMetadataStruct(self)
            out=struct('ModelInfo',{self.ModelInfo},...
            'TimingInfo',{self.TimingInfo},...
            'ExecutionInfo',{self.ExecutionInfo},...
            'UserString',{self.UserString},...
            'UserData',{self.UserData});
        end
    end

    methods
        function self=set.UserData(self,userData)
            self.UserData=userData;
        end
    end

    methods(Static,Hidden=true)
        function mustBeValidUserString(userString)
            if~ischar(userString)&&~isstring(userString)
                throwAsCaller(MException(message('Simulink:tools:SimulationMetadataUserStringDatatypeMismatch')));
            end
        end
    end
end


function[harnessHandle,neededVars]=modifyProtectedModel(input,varargin)









































    [harnessHandle,neededVars]=Simulink.ModelReference.ProtectedModel.create(input,'edit',varargin{:});


